//Set destination for output files;
output = getDirectory("Select the folder for output");

//Draw around the cell periphery;
	setTool("freehand");
	waitForUser("Open image, draw an ROI around one cell, click OK when done");
	Roi.setPosition(1);
	roiManager("Add");

	imageName = getTitle();
	imageName = getTitleStripExtension(imageName);
	
	
//Isloate the FAs of one cell;
	run("Split Channels");
	selectWindow("C3-" + imageName + ".tif"); 
	run("Enhance Contrast", "saturated=0.35");
	setAutoThreshold("Default dark");
	roiManager("Select", 0);
	run("Analyze Particles...", "size=200-500 show=Nothing add");
	roiManager("Select", 1);
	run("Enlarge...", "enlarge=3");
	roiManager("Add");
	roiManager("Select", newArray(0,2));
	roiManager("XOR");
	roiManager("Add");
	
	selectWindow("C2-" + imageName + ".tif"); 
	roiManager("Select", 3);
	setThreshold(269, 65535, "raw");
	run("Analyze Particles...", "size=0.25-Infinity show=Masks summarize");
	//waitForUser("checking");
	run("Invert LUTs");
	saveAs("Tiff", output + File.separator + imageName + "_mask.tif");
	run("Create Selection");
	roiManager("Add");
	roiManager("Select", newArray(3,4));
	roiManager("XOR");
	roiManager("Add");
	
	run("Set Measurements...", "area mean min shape limit redirect=None decimal=3");
	selectWindow("C1-" + imageName + ".tif"); 
	roiManager("Select", 0);
	run("Measure");
	roiManager("Select", 4);
	run("Measure");
	roiManager("Select", 5);
	run("Measure");
	saveAs("Results", output + File.separator + "Integrin_analysis.csv"); // save individual FA measurements;
	run("Clear Results");
	saveAs("Tiff", output + File.separator + imageName + ".tif");

	
//analyze FA particles;
	roiManager("save", output + File.separator + "Area_analyzed.zip");
	selectWindow("Summary");
	saveAs("Results", output + File.separator + "FA_summary.csv"); // save all FA measurements;
	selectWindow("FA_summary.csv");
		Table.deleteRows(0, 0, "FA_summary.csv");
	
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