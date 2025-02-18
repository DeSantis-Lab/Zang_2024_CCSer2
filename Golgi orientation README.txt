This code measures the angles 360˚ around the centroid of the nucleus which contain Golgi fluorescence signal. 
The user is prompted to select a folder as the output destination.
Then the user draws a line across the wound to designate the wound angle. 
Next answer whether the cell to be analyzed is below or to the left of the wound. 
The user is prompted to generate an ellipse that captures both the nucleus and all of the Golgi signal. The DAPI channel is selected and the centroid of the nucleus is extracted. Angles are then drawn 360˚ about the centroid to the edge of the ellipse and the intensity across each line is measured in the Golgi channel. Only lines that contain Golgi signal above the background of the cell are kept. The kept angles are then reported relative to the angle of the wound, with the perpendicular angle to the wound being 0˚ (denoted as "angle difference" in the last column of the measurement.csv file generated). 
The ellipse and Golgi containing angles are saved as an ROI zip file and the angle measurements are saved as a csv file. 
Lastly, the angle measurements in degrees are converted to radians for use in the polar histogram Matlab script. 