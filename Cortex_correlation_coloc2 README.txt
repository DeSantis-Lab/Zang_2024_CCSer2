This code measures the colocalization of CCSer2, dynein, and tubulin at the leading edge of cells migrating in a sheet.
Currently it is set up to measure pairwise colocalization between three channels, CCSer2, dynein, and tubulin.
The user first selects whether the cells are at the top or bottom of the image.
They then draw a line along the edge of the cells. The program expands the line to measure the correlation coefficient using Color 2 plugin between the three channels at the cortex.
An ROI with the initial cell cortex line and the expanded line is saved to the folder that the image originated from. Txt documents with the correlation coefficients are also saved.
 
 The following variables can be easily edited at the top of the macro:
	bandSize: bandSize is the number of pixels that the line on the cell cortex is enlarged by. The final ROI is twice as large as the bandSize + 1 pixel. (So if it is set to 4 the enlarged ROI is 9 pixels wide).
	
