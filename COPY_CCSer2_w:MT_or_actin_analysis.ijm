
output = getDirectory("Select the folder for output");

imageName = getTitle();
imageName = getTitleStripExtension(imageName);

/* Open image and select the cell boundary */
setForegroundColor(0, 0, 0);
setBackgroundColor(255, 255, 255);
setTool("Pencil Tool");
run("Pencil Tool Options...", "pencil=4");
run("Split Channels");
setThreshold(180, 65535, "raw");
waitForUser("Draw a freehand line to isolate a single cell and adjust threshold to isolate cell, click OK when done");
setTool("wand");
waitForUser("Select cell, click OK when done");
roiManager("Add");
run("Set Measurements...", "area mean min redirect=None decimal=3");

/* Creates a selection for CCSer2 */
setOption("ScaleConversions", true);
run("8-bit");
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);
roiManager("Select", 0);
run("Clear Outside");

/* Creates a selection for Actin filaments */
selectWindow("C2-" + imageName + ".tif");
setOption("ScaleConversions", true);
run("8-bit");
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);
roiManager("Select", 0);
run("Clear Outside");

/* Creates a selection for MTs */
selectWindow("C1-" + imageName + ".tif");
setOption("ScaleConversions", true);
run("8-bit");
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);
roiManager("Select", 0);
run("Clear Outside");

/* Creates an image of colocalized pixels between pairwise thresholded images and calculates the percent area overlap between the thresholded images */
imageCalculator("AND create", "C1-"+imageName+".tif", "C2-"+imageName+".tif");
saveAs("Tiff", output + File.separator + imageName + "_Actin&MTs.tif");
roiManager("Select", 0);
run("Analyze Particles...", "clear summarize");

imageCalculator("AND create", "C1-"+imageName+".tif", "C4-"+imageName+".tif");
saveAs("Tiff", output + File.separator + imageName + "_MTs&Ser2.tif");
roiManager("Select", 0);
run("Analyze Particles...", "clear summarize");

imageCalculator("AND create", "C2-"+imageName+".tif", "C4-"+imageName+".tif");
saveAs("Tiff", output + File.separator + imageName + "_Actin&Ser2.tif");
roiManager("Select", 0);
run("Analyze Particles...", "clear summarize");
saveAs("Results", output + File.separator + imageName + "_Summary.csv"); // save measurements;

/* Saves all thresheld channels */
selectWindow("C4-" + imageName + ".tif");
saveAs("Tiff", output + File.separator + imageName + "_CCSer2.tif");
selectWindow("C2-" + imageName + ".tif");
saveAs("Tiff", output + File.separator + imageName + "_Actin.tif");
selectWindow("C1-" + imageName + ".tif");
saveAs("Tiff", output + File.separator + imageName + "_MTs.tif");
roiManager("save", output + File.separator + "Cell periphery.zip"); // save rois;
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