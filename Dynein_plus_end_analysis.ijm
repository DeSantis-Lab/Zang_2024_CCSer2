/* draw a rectangle ROI to assess dynein at microtubule plus ends*/

output = getDirectory("Select the folder for output");

makeRectangle(365, 518, 84, 58);
waitForUser("Move the square to a part of the cell where it does not encompass the leading edge or the nucleus, click OK when done");
Roi.setPosition(1);
roiManager("Add");
setBackgroundColor(0, 0, 0);
run("Clear Outside");
run("Crop");

imageName = getTitle();
imageName = getTitleStripExtension(imageName);

saveAs("Tiff", output + File.separator + imageName + "_cropped.tif");
run("Split Channels");
saveAs("Tiff", output + File.separator + imageName + "_cropped_DHC.tif");

//run("Threshold...");
waitForUser("Select the EB1 window");
saveAs("Tiff", output + File.separator + imageName + "_cropped_EB1.tif")
roiManager("Select", 0);
setAutoThreshold("Default dark");
run("Create Selection");
roiManager("Add");
run("Set Measurements...", "area mean min redirect=None decimal=3");
run("Measure");

waitForUser("Select the DHC window");
saveAs("Tiff", output + File.separator + imageName + "_cropped_DHC.tif");
roiManager("Select", 1);
run("Measure");

roiManager("save", output + File.separator + "ROI.zip"); // save rois;
saveAs("Results", output + File.separator + "DHC-EB1_ratio.csv"); // save intensities;
	run("Clear Results");
	roiManager("Deselect");
	roiManager("Delete");
	run("Close All");



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