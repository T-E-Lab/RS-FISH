// BatchMaskFiltering
// This script walks through directory of RSFish results and neuron masks
// It then filters the results through the masks
// Creating:
// results filtered on only the cell bodies 
// and results filtered on the whole neuron
//
// Pseudocode / outline:
// Walk through results directory
// for each result csv file
//   Get both masks of neuron
//   filter results csv on each mask
//   store filtered results in subfolders


parentSrcDir = "Z:/EASI-FISH/EASI-FISH_results/2023-07-31_RS-FISH-run/";

walkFiles(parentSrcDir);

// Find all files in subdirs:
function walkFiles(srcDir) {
	// print("walking "+ srcDir); 
	list = getFileList(srcDir);
	for (i=0; i<list.length; i++) {
		// print("item = "+list[i]);

		// If results directory
		if (endsWith(list[i], ".czi/"))
		   //print("results folder =" + list[i]);
		   processBrain(srcDir + "/" + list[i]);
		
		// If other directory
		else if (endsWith(list[i], "/"))
		   walkFiles(""+srcDir+"/"+list[i]);
	}
}

// process a brain
function processBrain(brainDir) { 
	// Find masks
	// for each mask filter the results files and store it in a subfolder named after the mask
	
	// Find masks
	list = getFileList(brainDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], ".vrp_files/")
			vvdlist = getFileList(brainDir + "/" + list[i]);
	}
	masklist = newArray(2);
	for (i=0; i<vvdlist.length; i++) {
		if (endsWith(vvdlist[i], ".msk")
			masklist.append(vvdlist[i]);
	}
	
	// filter results for each mask
	
}