//This code measures the mean intensity of early endosomes within an individual cell.
//Currently it is set up to measure the EEA-1 channel.
//To begin, the user is prompted to select a folder as the output destination.
//The actin (phalloidin) channel is selected and the user should generate a line tracing around the cell periphery, which is saved as an ROI.
//Then the EEA channel is selected and the mean intensity within the cell perimeter is measured as well as the cell area.
//Lastly, the results and ROI manager are cleared and all windows are closed.

//Set destination for output files;
output = getDirectory("Select the folder for output");
	imageName = getTitle();
	imageName = getTitleStripExtension(imageName);

//Draw around the cell periphery and measure the mean intensity of endosomes;
	setTool("freehand");
	waitForUser("Open image, draw an ROI around one cell, click OK when done");
	Roi.setPosition(1);
	roiManager("Add");
	run("Set Measurements...", "area mean min redirect=None decimal=3");
	run("Split Channels");
	selectWindow("C2-" + imageName + ".tif"); 
	saveAs("Tiff", output + File.separator + imageName + "_EEA1_vesicles.tif");
	roiManager("Select", 0);
	run("Measure");
	saveAs("Results", output + File.separator + "Mean_endosome_intensity.csv"); // save individual cell area;

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