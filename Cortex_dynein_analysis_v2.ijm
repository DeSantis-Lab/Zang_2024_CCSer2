/* This code measures the intensity at the cortex and in regions close to the cortex for a sheet of cells.
 *  Currently it is set up to measure two channels, dynein and tubulin.
 *  The user first selects whether the cells are at the top or bottom of the image.
 *  They then draw a line along the edge of the cells. It is recommended that they use many points to draw the line and make them as evenly spaced as possible, because this will help to evenly space the circles that are drawn in the cell interior.
 *  The program expands the line to measure the cortex, and then many circles are drawn along the line in the interior of the cell to measure the intensity of the cytoplasm near the cortex.
 *  The user is then asked to delete any circles that are overlapping. Many more circles than are necessary are drawn so that there is fairly even coverage across the whole sheet of cells.
 *  Finally, the circles are combined into a single ROI and then the cell cortex and cell interior are measured in the dynein and tubulin channels.
 *  An ROI with the initial cell cortex line, the expanded line, and the combined circles is saved to the folder that the image originated in.
 *  Txt documents with the dynein and tubulin intensities are also saved.
 *  The results window also displays the intensities in the following order: dynein cortex, dynein interior, tubulin cortex, tubulin interior
 */

//Variables:

numCircles = 15; //numCircles is the number of circles that appear in the interior of the cell

bandSize = 2; // bandSize is the number of pixels that the line on the cell cortex is enlarged by. The final roi is twice as large as the bandSize + 1pixel.

circleDistance = 35; //circleDistance is the distance in pixels from the original cell cortex line that the interior cell circles will be drawn. The value is adjusted below taking into account whether the cells are on the top or bottom of the image.

circleDiameter = 15; //circleDiameter is the diameter in pixels of the circles that are drawn in the cell interior.



//Ask user for cell location:
cellLoc = getBoolean("Are your cells on the top of the image? (Hit yes if they are on top and no if they are on bottom)");

if (cellLoc == 1) {
	circleDistance = -1*circleDistance;
	bandMove = -1 * bandSize;
}
else{
	circleDistance = circleDistance-circleDiameter;
	bandMove = bandSize;
	}
	

//Reset  ROI manager and results so that old values are not present
roiManager("reset");
run("Clear Results");


//Get directory and image title so that we can save results. This section also sets parameters for the images and splits the channels.
output = getDirectory("Select the folder for output");

title = getTitle(); 
Stack.setXUnit("pixel");
run("Properties...", "pixel_width=1.0000000 pixel_height=1.0000000 voxel_depth=1");
run("Split Channels"); //splits channels into c1-tubulin  and c2- dynein


//Roi 0: Have the user generate a line along cell border
selectWindow("C4-" + title); 
run("Maximize");
run("Brightness/Contrast...");
setTool("polyline");
waitForUser("Draw a line along the edge of the cells, then hit okay.");

if (roiManager("count") == 0){
	roiManager("Add");
}
else {
}


//Roi 1: enlarge line
roiManager("select",0);
run("Line to Area");
run("Enlarge...", "enlarge="+bandSize);
getSelectionBounds(x, y, w, h);
setSelectionLocation(x, y+bandMove);
roiManager("Add");


//Create circles inside cell:
roiManager("select",0);
Roi.getCoordinates(xpoints, ypoints);
xLength = xpoints.length;
interval = xLength/(numCircles+2);

for (i = 0; i < numCircles; i++) {
j = interval*(i+1);
makeOval(xpoints[j], (ypoints[j]+circleDistance), circleDiameter, circleDiameter);
roiManager("add");
}


//User deletes any overlapping circles:
roiManager("show all with labels");
waitForUser("Delete any overlapping circle ROIs, then hit okay.");


//Combines remaining circles into one ROI:
n = roiManager('count');
circleArray = newArray();
for (i = 2; i < n; i++) {
    circleArray = Array.concat(circleArray,i);
}
roiManager("select", circleArray);
roiManager("combine");
roiManager("add");
roiManager("select", circleArray);
roiManager("delete");
roiManager("deselect");
roiManager("Save", output + title + "_ROIs.roi.zip");


//measure the cortex and inner rings in the dynein channel and the tubulin channel. 
//Saves individual txt documents for each
//results window contains data in the following order: dynein cortex, dynein interior, tubulin cortex, tubulin interior
run("Set Measurements...", "area mean min redirect=None decimal=3");
selectWindow("C2-" + title); 
roiManager("select", newArray(1,2));
roiManager("measure");
saveAs("results",output + title + "_MTs-intensity.txt");
run("Clear Results");

selectWindow("C4-" + title); 
roiManager("select", newArray(1,2));
roiManager("measure");
saveAs("results",output + title + "_dynein-intensity.txt");
run("Clear Results");

selectWindow("C1-" + title); 
roiManager("select", newArray(1,2));
roiManager("measure");
saveAs("results",output + title + "_Ndel1-intensity.txt");
run("Clear Results");

roiManager("Deselect");
roiManager("Delete");

