This code measures the circularity of the cell perimeter of individual cells within the field of view. 
Currently it is set up to measure the actin (phalloidin) channel.
The user is prompted to select a folder as the output destination.
The actin channel is thresholded to a set range since our images were all collected with the same phalloidin concentration and imaging acquisition. The thresholding parameters can be changed in line 15.
Then, the user draws a line to separate any cells touching on less than 25% of their perimeters. The user next adds each cell to the ROI manager, by clicking on a cell and pressing 't'. Cells touching the edge of the field of view should not be selected for analysis. 
The thresholded image and cell perimeter ROIs are saved and the circularity of cells within the field of view are all measured and saved as an csv file. 
Finally, the results are cleared and all windows are closed so a new analysis can begin. 
