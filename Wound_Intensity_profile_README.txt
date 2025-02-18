This code measures the cortical enrichment of actin in an individual migrating cell.
Currently it is set up to measure the phalloidin-647 actin channel.
The user is prompted to select a folder as the output destination.
The image is positioned so that the wound is at the top and so the cells are migrating upwards.
The length of the leading edge of the analysis cell is measured by having the user draw a freehand line along the leading edge touching the wound. Then the user draws a rectangle around a single migrating cell and the image is cropped. 
The nucleus is selected in the DAPI channel using autothresholding and the centroid is extracted.
In the actin channel, the user draws the perimeter of the analysis cell which is saved as an ROI.
The script draws lines 360˚ about the centroid of the nucleus to the cell perimeter. Lines with angles between 25˚ and 155˚ are kept for analysis, the exact angles kept can be adjusted in line 246. This restricts the analysis to the area between the nucleus and the leading edge of the migrating cells.
Then each line is binned into 20 equidistant segments and the actin intensity is measured in each bin.
The cell perimeter ROIs and lines quantified are saved as an ROI zip file and the actin intensity measurements for each line are saved as a csv file. 