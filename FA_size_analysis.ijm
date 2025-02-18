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
	//waitForUser("Select the DAPI channel");
	//setAutoThreshold("Default dark");
	//roiManager("Select", 0);
	//run("Analyze Particles...", "add");
	waitForUser("Select the paxillin focal adhesion image");
	//roiManager("Select", 1);
	//run("Enlarge...", "enlarge=3");
	//setBackgroundColor(0, 0, 0);
	//run("Clear", "slice");
	//waitForUser("checking");
	roiManager("Select", 0);
	setThreshold(500, 65535, "raw");
	roiManager("Select", 0);
	saveAs("Tiff", output + File.separator + imageName + "_FAs.tif");

	
//analyze FA particles;
	run("Analyze Particles...", "size=0.4-10 show=Masks display summarize add");
	saveAs("Tiff", output + File.separator + imageName + "_FAs_mask.tif");
	roiManager("save", output + File.separator + "FA_particles_analyzed.zip");
	saveAs("Results", output + File.separator + "FA_area.csv"); // save individual FA measurements;
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