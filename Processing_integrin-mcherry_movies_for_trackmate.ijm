//This macro is for processing live imaging movies prior to using the trackmate plugin //
//To begin, the user should set a folder where output files will be saved // 
//The user should open a movie of labeled vesicles being trafficked within a cell // 
//Currently, the macro is set up for the analysis of cells migrating to fill in a wound at the bottom of the image //
//The movie will then be processed by applying a background subtraction, Gaussian blur, and Mexican Hat filter to clearly define vesicles //
//* Note: the Mexican Hat Filter plugin must be downloaded prior to using this macro //
//Processed movie is saved as a .tif file //
//Area between the leading edge and the nucleus is saved as an ROI in a .zip file //
//This ROI will be used with trackmate to track vesicles traveling between the nucleus and leading edge //

output = getDirectory("Select the folder for output");
imageName = getTitle();
imageName = getTitleStripExtension(imageName);

run("Enhance Contrast", "saturated=0.35");
waitForUser("Make sure cells are at the top of image and migrating down, click OK when done");
saveAs("Tiff", output + File.separator + imageName + ".tif");
run("Duplicate...", "duplicate");
run("Subtract Background...", "rolling=50 sliding stack");
run("Enhance Contrast", "saturated=0.35");
run("32-bit");

//The user is prompted to draw a short line (~5 microns is sufficient) through a distinct vesicle somewhere in the cell periphery //
setTool("line");
waitForUser("Zoom in on a vesicle on the cell periphery and draw a line through, click OK when done");
run("Plot Profile");
waitForUser("Under Data_Add Fit_copy the d value and insert into the gaussian blur in the next step, click OK when done");
run("Gaussian Blur...");
run("Mexican Hat Filter", "radius=2 stack");
saveAs("Tiff", output + File.separator + imageName + "_processed.tif");

setTool("freehand");
waitForUser("Draw an ROI around the leading edge, but excluding the nucleus, click OK when done");
Roi.setPosition(1);
roiManager("Add");
roiManager("save", output + File.separator + "LeadingEdge.zip"); // save rois;
run("TrackMate");



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