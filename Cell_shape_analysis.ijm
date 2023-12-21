//Set destination for output files;
output = getDirectory("Select the folder for output");

	imageName = getTitle();
	imageName = getTitleStripExtension(imageName);
	
//Threshold the actin channel to isolate cells;

	//run("Z Project...", "projection=[Max Intensity]");
	run("Split Channels");
	//run("Enhance Contrast", "saturated=0.35");
	run("Subtract Background...", "rolling=50");
	run("Gaussian Blur...", "sigma=1 scaled");
	//waitForUser("Select the actin (647) image");
	setThreshold(42, 65535, "raw");
	setTool("Pencil Tool");
	run("Pencil Tool Options...", "pencil=4");
		setForegroundColor(0, 0, 0);
		setBackgroundColor(255, 255, 255);
	waitForUser("Draw lines to separate two defined cells, click okay when finished");
	setTool("Wand (tracing) tool");
	waitForUser("Click on each GFP fluorescent cell and press 't' to add to ROI");
	saveAs("Tiff", output + File.separator + imageName + "_cell_shape_threshold.tif");
	run("Set Measurements...", "area shape redirect=None decimal=3");
	roiManager("Measure");
	roiManager("save", output + File.separator + "Individual_cell_ROIs.zip");
	saveAs("Results", output + File.separator + imageName + "_cell_shape_anaylsis.csv");

//clear results;
	run("Clear Results");
	roiManager("Deselect");
	roiManager("Delete");
	run("Close All");
	
//Finished!;
	beep();
	
function getTitleStripExtension(t) {
	t = replace(t, ".tif", "");        
	t = replace(t, ".tiff", "");      
	t = replace(t, ".lif", "");      
	t = replace(t, ".lsm", "");    
	t = replace(t, ".czi", "");      
	t = replace(t, ".nd2", ""); 
	t = replace(t, ".png", "");
	t = replace(t, ".csv", "");
	return t;
}