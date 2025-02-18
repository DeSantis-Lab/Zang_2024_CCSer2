This code measures the relative localization of an organelle in an individual cell.
Currently it is set up to measure one or two organelle channels.
The user is prompted to select a folder as the output destination.
Then the user draws a rectangle around a single cell and the image is cropped. It is suggested to select cells which are quite round for analysis to avoid skewing the localization.
The nucleus is selected in the DAPI channel using autothresholding and the centroid is extracted.
In the actin channel, the user draws the perimeter of the analysis cell which is saved as an ROI.
The script draws lines 360˚ about the centroid of the nucleus to the cell perimeter. Lines shorter than half the length of the longest line are removed from analysis. 
In the organelle channel, each line is binned into 20 equidistant segments and the intensity is measured in each bin.
The cell perimeter ROIs and lines quantified are saved as an ROI zip file and the organelle intensity measurements for each line are saved as a csv file. 