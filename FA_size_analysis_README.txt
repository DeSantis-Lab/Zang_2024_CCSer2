This code measures the size and number of paxillin positive focal adhesions (FAs) of a single cell. 
The user is prompted to select a folder as the output destination.
Then the user draws a freehand line designating the perimeter of a single cell in the actin channel. 
The paxillin channel is selected and manually thresholded (500, 65535, "raw"). The FAs are quantified using the analyze particles plugin. 
The cell perimeter and FA area are saved as ROIs and area of individual FAs are saved as a csv file. 
