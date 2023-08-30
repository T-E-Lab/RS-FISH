// This macro script runs the RS (radial symmetry) FIJI plug-in on all the images in all the sub-directories of the defined dir
// After finding the best parameters using the RS plugin GUI interactive mode on one example image,
// You can run this macro script on the entire dataset.
// Just change the directory path, and the values of the parameters in the begining of the script

// You can run this script either in the ImageJ GUI or headless (also from cluster) using this command (linux):
// <FIJI/DIR/PATH>/ImageJ-linux64 --headless --run </PATH/TO/THIS/SCRIPT>/RS_macro.ijm &> </PATH/TO/WHERE/YOU/WANT/YOUR/LOGFILE>.log

// The detection result table will be saved to the same directory as each image it was calculated for.

// Path the czi files to be processed, searches all sub-directories.
parentSrcDir = "Z:/EASI-FISH/EASI-FISH_data/043021_Dante_PEN2/";
parentDstDir = "Z:/EASI-FISH/EASI-FISH_results/2023-07-31_RS-FISH-run/043021_Dante_PEN2/";

// Location of file where all run times will be saved:
timeFile = "Z:/EASI-FISH/EASI-FISH_results/2023-07-31_RS-FISH-run/043021_Dante_PEN2/RS_Exe_times.txt";

//////// Define RS parameters: //////////

anisotropyCoefficient = 1.0;
ransac = "RANSAC";						// options are "RANSAC" (log value "SIMPLE") / "No RANSAC" / "MULTICONSENSU"
//imMin = 70; 							// img min intensity
//imMax = 20692; 							// max intensity
sigmaDoG = 1.25;
thresholdDoG = 0.005;
supportRadius = 3;
inlierRatio = 0.1;						// meaning: min inlier ratio
maxError = 1.5; 						// meaning: max error range
spot_intensity = "Linear Interpolation";
intensityThreshold = 0;  				// meaning: spot intensity threshold
bsMethod = "No background subtraction";	// Log file 0 / 1 / 2 / 3 / 4 options correspond to "No background subtraction" / "Mean" / "Median" / "RANSAC on Mean" / "RANSAC on Median"
bsMaxError = 0.05;						// background subtraction param
bsInlierRatio = 0.1;					// background subtraction param
//useMultithread = "use_multithreading";	// Not from log file (only in advanced mode)! If you wish to use multithreading "use_multithreading", else "" (empty string)
useMultithread = "";
numThreads = 40;						// multithread param
blockSizX = 128;                     	// multithread param
blockSizY = 128;						// multithread param
blockSizZ = 16;							// multithread param


///////////////////////////////////////////////////

ransac_sub = split(ransac, ' ');
ransac_sub = ransac_sub[0];

bsMethod_sub = split(bsMethod, ' ');
bsMethod_sub = bsMethod_sub[0];

setBatchMode(true);

///////////////////////////////////////////////////

print("starting macro");

// Enable Bio-Formats Macro Extensions in order to read metadata
run("Bio-Formats Macro Extensions");

walkFiles(parentSrcDir);

// Find all files in subdirs:
function walkFiles(srcDir) {
	print("walking "+ srcDir); 
	list = getFileList(srcDir);
	for (i=0; i<list.length; i++) {
		print("item = "+list[i]);
		if (endsWith(list[i], "/"))
		   walkFiles(""+srcDir+"/"+list[i]);

		// If image file
		else if (endsWith(list[i], ".czi"))
		   processChannels(srcDir, list[i]);
	}
}

// Get FISH channels and process them
function processChannels(srcDir, imName) {
	print("processing channels "+imName);
	path = srcDir + imName;
	print("path = " + path);

	bioFormatsParams = "open=[" + srcDir + imName + "]"+
	" color_mode=Default"+
	" rois_import=[ROI manager]"+
	" view=Hyperstack"+
	" stack_order=XYCZT";
	
	// Open image
	run("Bio-Formats Importer", bioFormatsParams);
	print(getTitle());
	// Choose image to work with
	Ext.setId(path);
	// Get Filename
	title = getTitle();
	// Get number of channels
	Ext.getSizeC(sizeC);
	
	run("Split Channels");
	print(getTitle());
	
	// Remove non-probe channels
	// Channels 2 and 4 are probe channels
	for(i=1;i<=sizeC;i+=1){
		selectImage("C"+i+"-"+title);
		if(i == 2){
			// Process channel 2
			print("processing image "+ "C" + i + "-" + imName);
			processImage(srcDir, imName, i);
		}
		if(i == 4){
			// Process channel 4
			print("processing image "+ "C" + i + "-" + imName);
			processImage(srcDir, imName, i);
		}
		close();
	}
	
	// Close all windows:
	run("Close All");
	while (nImages>0) {
		selectImage(nImages);
		close();
    }
}

function processImage(srcDir, imName, ch) {
	
	// create destination path
	subfolder = imName + "/";
	dstDir = srcDir.replace(parentSrcDir, parentDstDir) + subfolder;
	print("dstDir = " + dstDir);

	results_csv_path = "" + dstDir + "results_" + "C" + ch + "-" +
	imName.substring(0, imName.length()-3) + "csv";
	
	log_txt_path = "" + dstDir + "BATCH_LOG_C" + ch + "-" + 
	imName.substring(0, imName.length()-3) + "txt";
	print(log_txt_path);

	RSparams =  //"image=" + "C" + ch + "-" + imName +
	" mode=Advanced anisotropy=" + anisotropyCoefficient + " robust_fitting=[" + ransac + "] use_anisotropy" +
	//	" image_min=" + imMin + " image_max=" + imMax +
	" compute_min/max"+ " [" + spot_intensity + "]" +
	" sigma=" + sigmaDoG + " threshold=" + thresholdDoG +
	" support=" + supportRadius + " min_inlier_ratio=" + inlierRatio + " max_error=" + maxError + " spot_intensity_threshold=" + intensityThreshold +
	" background=[" + bsMethod + "] background_subtraction_max_error=" + bsMaxError + " background_subtraction_min_inlier_ratio=" + bsInlierRatio +
	" results_file=[" + results_csv_path + "]" +
	" " + useMultithread + " num_threads=" + numThreads + " block_size_x=" + blockSizX + " block_size_y=" + blockSizY + " block_size_z=" + blockSizZ;

	print(RSparams);

	// Clear Log
	print("\\Clear");
	
	startTime = getTime();
	run("RS-FISH", RSparams);
	exeTime = getTime() - startTime; //in miliseconds
	
	// Save Log
	log_string = getInfo("log");
	File.saveString(log_string, log_txt_path);

	// Save exeTime to file:
	File.append(results_csv_path + "," + exeTime + "\n ", timeFile);
}
