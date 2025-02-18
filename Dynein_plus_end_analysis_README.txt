This code measures the dynein intensity at microtubule plus ends. 
The user is prompted to select a folder as the output destination.
Then the user places a uniform box to a place in the cell between the nucleus and leading edge to avoid excess nuclear signal. The image is cropped to the box area and the channels are split. 
The EB1 channel is selected and microtubule plus ends are autothresholded (Default dark). The thresholded area is saved as an ROI and the mean EB1 fluorescence intensity is measured. 
In the dynein channel, the EB1 ROI is applied and the mean dynein fluorescence intensity is measured. 
The box position and EB1 ROI are saved as an ROI zip file and the mean EB1 and dynein fluorescence intensity at plus ends is saved as a csv file. 
 
