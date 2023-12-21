/* This code measures the intensity at the cortex for a sheet of cells.
 *  Currently it is set up to measure three channels, dynein, CCSER and tubulin.
 *  The user first selects whether the cells are at the top or bottom of the image.
 *  They then draw a line along the edge of the cells. 
 *  The program expands the line to measure the cortex in the three channels.
 *  An ROI with the initial cell cortex line and the expanded line is saved to the folder that the image originated in.
 *  Txt documents with the correllation coefficients are also saved.
 */

//Variables:


bandSize = 4; // bandSize is the number of pixels that the line on the cell cortex is enlarged by. The final roi is twice as large as the bandSize + 1pixel.

moreCells = 1;

cellNumber = 1;


//Ask user for cell location:
cellLoc = getBoolean("Are your cells on the top of the image? (Hit yes if they are on top and no if they are on bottom)");

//Get directory and image title so that we can save results. This section also sets parameters for the images and splits the channels.
output = getDirectory("Select the folder to save ROIs");

title = getTitle(); 
Stack.setXUnit("pixel");
run("Properties...", "pixel_width=1.0000000 pixel_height=1.0000000 voxel_depth=1");
run("Split Channels"); //splits channels into c1-tubulin  and c2- dynein


run("Clear Results");
//File.saveString(title + "\nCell 1", output + title + "_correlation.txt");


if (cellLoc == 1) {
	bandMove = -1 * bandSize;
}
else{
	bandMove = bandSize;
	}

while(moreCells == 1){


//Reset  ROI manager and results so that old values are not present
roiManager("reset");
run("Clear Results");


//Roi 0: Have the user generate a line along cell border
selectWindow("C4-" + title); 
run("Maximize");
run("Brightness/Contrast...");
setTool("polyline");
waitForUser("Draw a line along the edge of cell number " + cellNumber + ", then hit okay.");

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
roiManager("deselect");
roiManager("save", output + title +"_cell_number_" + cellNumber+"_ROI.zip");


//Calculate correlation for current cell:
selectWindow("C1-" + title); 
roiManager("select", 1);
run("Coloc 2", "channel_1=C1-"+title+" channel_2=C2-"+title+" roi_or_mask=[ROI(s) in channel 1] threshold_regression=Costes show_save_pdf_dialog li_histogram_channel_1 li_histogram_channel_2 li_icq spearman's_rank_correlation manders'_correlation kendall's_tau_rank_correlation 2d_intensity_histogram costes'_significance_test psf=3 costes_randomisations=10");
selectWindow("C1-" + title); 
roiManager("select", 1);
run("Coloc 2", "channel_1=C1-"+title+" channel_2=C4-"+title+" roi_or_mask=[ROI(s) in channel 1] threshold_regression=Costes show_save_pdf_dialog li_histogram_channel_1 li_histogram_channel_2 li_icq spearman's_rank_correlation manders'_correlation kendall's_tau_rank_correlation 2d_intensity_histogram costes'_significance_test psf=3 costes_randomisations=10");selectWindow("C2-" + title); 
selectWindow("C2-" + title); 
roiManager("select", 1);
run("Coloc 2", "channel_1=C2-"+title+" channel_2=C4-"+title+" roi_or_mask=[ROI(s) in channel 1] threshold_regression=Costes show_save_pdf_dialog li_histogram_channel_1 li_histogram_channel_2 li_icq spearman's_rank_correlation manders'_correlation kendall's_tau_rank_correlation 2d_intensity_histogram costes'_significance_test psf=3 costes_randomisations=10");

roiManager("Deselect");
roiManager("Delete");

cellNumber = cellNumber + 1;
moreCells = getBoolean("Are there more cells?");
}
close("*");
run("Close All");