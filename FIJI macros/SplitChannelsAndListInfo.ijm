// SplitChannelsAndListInfo.ijm

// Enable Bio-Formats Macro Extensions in order to read metadata
run("Bio-Formats Macro Extensions");

// Get image path
dir = getInfo("image.directory");
fn = getInfo("image.filename");
imgPath = dir + "/" + fn;

// Choose image to work with
Ext.setId(imgPath);

// Get number of channels
Ext.getSizeC(sizeC);

// For each channel print the wavelength
// Using the field below gives values 10 less than the corresponding emission wavelengths
// "Information|Image|Channel|IlluminationWavelength|SinglePeak #1" 
for(i=1;i<=sizeC;i+=1){
	Ext.getMetadataValue("Information|Image|Channel|EmissionWavelength #" + i, channelWaveLength);
	print("Channel "+i+" Wavelength = "+channelWaveLength);
}


// Split Channels
run("Split Channels");

// for each channel
for(i=1;i<=sizeC;i+=1){
	selectImage("C"+i+"-"+fn);
	// Enhance Contrast
	run("Enhance Contrast", "saturated=0.4");
	// Reduce image size
	run("Out [-]");
}

// Move first channel to front
selectImage("C1-"+fn);

// Create max intensity projection
run("Z Project...", "projection=[Max Intensity]");
// Enhance Contrast
run("Enhance Contrast", "saturated=0.4");
// Reduce image size
run("Out [-]");

// Add Synchronize windows tool to help with drawing rois
run("Synchronize Windows");
