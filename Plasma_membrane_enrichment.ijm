//Reset  ROI manager and results so that old values are not present
roiManager("reset");
run("Clear Results");

//Get directory and image title so that we can save results. 
output = getDirectory("Select the folder for output");

//Split the DIC from the mCherry channel
title = getTitle();
run("Split Channels");
selectWindow("C1-"+ title);
close();
selectWindow("C2-"+ title);
close();


//Roi 0: Have the user generate a line along cell border
selectWindow("C4-"+ title); 
run("Maximize");
run("Brightness/Contrast...");
setTool("polygon");
waitForUser("Draw a polygon around the cell periphery, then hit okay.");

if (roiManager("count") == 0){
	roiManager("Add");
}
else {
}

selectWindow("C4-" + title);
roiManager("Select", 0);
run("Enlarge...", "enlarge=-2");
roiManager("Add");
roiManager("Select", 1);
roiManager("Measure");
roiManager("Select", 1)
run("Make Band...", "band=2.25");
roiManager("Add");	
roiManager("Select", 2);
roiManager("Measure");


roiManager("deselect");
roiManager("Save", output + title + "_ROIs.roi.zip");
saveAs("results",output + "Intensity-"+ title + ".txt");

