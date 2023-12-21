This code measures the intensity at the cortex and in regions close to the cortex for a sheet of cells.
Currently it is set up to measure two channels, dynein and tubulin.
The user first selects whether the cells are at the top or bottom of the image.
They then draw a line along the edge of the cells. It is recommended that they use many points to draw the line and make them as evenly spaced as possible, because this will help to evenly space the circles that are drawn in the cell interior.
The program expands the line to measure the cortex, and then many circles are drawn along the line in the interior of the cell to measure the intensity of the cytoplasm near the cortex.
The user is then asked to delete any circles that are overlapping. Many more circles than are necessary are drawn so that there is fairly even coverage across the whole sheet of cells.
Finally, the circles are combined into a single ROI and then the cell cortex and cell interior are measured in the dynein and tubulin channels.
An ROI with the initial cell cortex line, the expanded line, and the combined circles is saved to the folder that the image originated in.
Txt documents with the dynein and tubulin intensities are saved there as well.
The results window also displays the intensities in the following order: dynein cortex, dynein interior, tubulin cortex, tubulin interior
 
 The following variables can be easily edited at the top of the macro:
	numCircles: numCircles is the number of circles that appear in the interior of the cell
	bandSize: bandSize is the number of pixels that the line on the cell cortex is enlarged by. The final roi is twice as large as the bandSize + 1 pixel. (So if it is set to 4 the enlarged ROI is 9 pixels wide)
	circleDistance: circleDistance is the distance in pixels from the original cell cortex line that the interior cell circles will be drawn. 
	circleDiameter: circleDiameter is the diameter in pixels of the circles that are drawn in the cell interior.
