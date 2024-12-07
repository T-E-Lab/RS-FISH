//CreateSomaMask.ijm
// Fiji macro to create mask of cell bodies for use in EASI-FISH data processing
// Also prints out wavelength of all the channels

// Enable Bio-Formats Macro Extensions in order to read metadata
//run("Bio-Formats Macro Extensions");

// Get image path
dir = getInfo("image.directory");
fn = getInfo("image.filename");
imgPath = dir + "/" + fn;

// Choose image to work with
//Ext.setId(imgPath);

// Get number of channels
//Ext.getSizeC(sizeC);

// For each channel print the wavelength
// Using the field below gives values 10 less than the corresponding emission wavelengths
// "Information|Image|Channel|IlluminationWavelength|SinglePeak #1" 
//for(i=1;i<=sizeC;i+=1){
//	Ext.getMetadataValue("Information|Image|Channel|EmissionWavelength #" + i, channelWaveLength);
//	print("Channel "+i+" Wavelength = "+channelWaveLength);
//}


// Add ROI to manager
run("ROI Manager...");
roiManager("Add");

// Remove ROI from image to avoid duplicating only bounding box around the ROI
run("Select None");

// Create copy of image to work on
run("Duplicate...", "ignore duplicate title=[MASK_"+fn+"]");
idDup1 = getImageID();

// Select copy
selectImage(idDup1);

// Auto Threshold
run("Select None");
run("Auto Threshold", "method=Moments white stack use_stack_histogram");

// Add ROI
roiCount = roiManager("count");
roiManager("select", roiCount-1);

// Clear outside ROI
run("Clear Outside", "stack");

// Clear noise (morphological open)
run("Minimum...", "radius=0.5 stack");
run("Maximum...", "radius=0.5 stack");

// Connect nearby objects (morphological close)
run("Maximum...", "radius=0.5 stack");
run("Minimum...", "radius=0.5 stack");

// Fill holes
run("Fill Holes", "stack");
