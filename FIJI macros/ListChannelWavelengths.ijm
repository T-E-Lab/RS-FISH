// ListChannelWavelengths.ijm

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