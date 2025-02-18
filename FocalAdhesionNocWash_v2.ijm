//This macro will Threshold the paxillin channel and save that channel as a tif, a thresholded tif, save the roi set and the results of the area.
//Reset imageJ:
//reset everything:
roiManager("reset");
run("Clear Results");
run("Close All");


dir = getDirectory("Choose a Directory to process"); //User defined process directory
list = getFileList(dir); //list all files in directory
analysisDir = dir + "/Analysis"; //make a new directory path for analysis folder
File.makeDirectory(analysisDir); //make analysis folder


for (i=0; i<list.length; i++) {

path = dir+list[i];

//This if statement makes it so that the macro ignores folders and only analyzes files
if (!File.isDirectory(path)) {
run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
title = getTitle(); //this gets the name of the file so we can parse it

imageString = replace(title, ".nd2", ""); //remove the .nd2 from the file name so we can name the folder after it
imageDir = analysisDir + "/" + imageString; //make a directory name mathcing the file
File.makeDirectory(imageDir); // make that directory

run("Split Channels"); //splits channels into C1-paxillin, C2-MTs, C3-nuclei, C4-FAK
selectWindow("C1-" + title); //select paxillin channel
tifDir = imageDir +"/"+ title + "_C1";
saveAs("Tiff", tifDir); //save channel as tif

//set threshold
setThreshold(555, 65535, "raw");
run("Convert to Mask", "background=Dark");

saveAs("Tiff", imageDir +"/"+ title + "_C1_threshold"); //save thresholded image

//analyze particvles and save results/roi
run("Analyze Particles...", "size=0.40-1000.00 display exclude add");
run("Clear Results");
open(tifDir + ".tif");
roiManager("measure");
saveAs("Results", imageDir +"/"+ title + "_C1_Results");
roiManager("Save", imageDir +"/"+ title + "_C1_ROI.zip");

//reset everything:
roiManager("reset");
run("Clear Results");
run("Close All");

}
else{}
}