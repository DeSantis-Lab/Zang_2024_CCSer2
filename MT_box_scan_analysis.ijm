//Set destination for output files;
output = getDirectory("Select the folder for output");
waitForUser("Open image, make sure the wound is at the top of the image, click OK when done");
	imageName = getTitle();
	imageName = getTitleStripExtension(imageName);
	
//Rotate the image so that the wound is on the top, Image-> Transform-> Flip vertically or Rotate;	
	run("Split Channels");
	selectWindow("C2-" + imageName + ".tif"); 
	
//Create/move a rectangle with approx 1/4 of scratch and 3/4 of cells;
	makeRectangle(63, 14, 568, 660);
	waitForUser("Move box to contain 1/4 of scratch and 3/4 of cells, click OK when done");	
	roiManager("Add");
	Roi.setPosition(1);
	roiManager("Select", 0);
	setOption("InterpolateLines", true);
	run("Plots...", "width=600 height=340 font=14 draw_ticks minimum=0 maximum=0 vertical interpolate");
	run("Plot Profile");
	saveAs("Tiff", output + File.separator + imageName + "_MT_box_scan.tif"); // save plot;
	roiManager("save", output + File.separator + "_box.zip"); // save box scan measurment;
	waitForUser("Save data as values, Data-> Save data, click OK when done");	
	

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