This code measures the mean fluorescence intensity of B1-integrins at paxillin positive FAs or outside of FAs as well as the total cellular mean fluorescence intensity of B1-integrins. 
The user is prompted to select a folder as the output destination.
Then the user draws a freehand line designating the perimeter of a single cell in the actin channel (ROI #0).
The nucleus is selected as an ROI (ROI #1) and enlarged by 3 microns (ROI #2). The area between the enlarged nucleus and the cell perimeter is also saved as an ROI (ROI #3).
The paxillin channel is then selected and manually thresholded (269, 65535, "raw"). The FAs are quantified using the analyze particles plugin and extracted as one ROI (ROI #4). Further, the area between the FA ROI and ROI #3 is extracted as the area outside of FAs (ROI #5).
The cell perimeter, nucleus, enlarged nucleus, area inside and outside of FAs are saved as ROIs and the mean B1-integrin fluorescence intensity in the whole cell, at FAs, or outside of FAs are saved as a csv file. 
