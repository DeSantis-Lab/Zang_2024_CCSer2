This code measures the cortical enrichment of proteins (CCSer2 or GFP) in an individual cell.
Currently it is set up to measure the CCSer2 or GFP channel.
The user is prompted to select a folder as the output destination.
The CCSer2 (or GFP) channel is selected and the user should generate a line tracing around the cell periphery. It is recommended that the user use many points to draw the line and make them as evenly spaced as possible to get an accurate trace of the cell perimeter. 
The program expands the line to create a band and measures the intensity at the cortex. The band width can be altered in line 32. Then, the intensity of the interior of the cell, excluding the cortical band, is also measured.
The results window also displays the intensities in the following order: CCSer2 (or GFP) cortex, CCSer2 (or GFP) interior.
The cell perimeter ROIs are saved as a zip file and the intensity measurements at the cortex and in the cytoplasm are saved as a csv file. 