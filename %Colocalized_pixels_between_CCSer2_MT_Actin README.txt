This code measures the percentage of colocalized pixels between CCSer2, microtubules, and actin in a pairwise manner of a single cell.
Currently it is set up to measure the CCSer2, tubulin and phalloidin (actin) channels.
To begin, the user is prompted to select a folder as the output destination. 
The user should draw the minimal amount of lines to separate an individual cell from its neighbors. The actin channel is then thresholded to a set range since our images were all collected with the same phalloidin concentration and imaging acquisition. The thresholding parameters can be changed in line 13. 
Once the cell is thresholded properly, the cell perimeter should be selected by clicking on the cell. Any cell touching the edge of the field of view should not be selected for analysis.
Auto local thresholding is applied to each of the three channels. In a pairwise fashion, a new image of colocalized pixels between two thresholded images is created using the imageCalculator "AND" function. Next, the percent area of the colocalized pixels from the cell area ROI is calculated. 
The results window also displays the percent area overlap in the following order: actin + microtubules, microtubules + CCSer2, and actin + CCSer2. 
The thresholded images and cell perimeter ROI are saved. The percent area colocalized between CCSer2, microtubules, and actin is saved in a csv file called "Summary". 
Finally, the results and ROI manager are cleared and all windows are closed, so a new analysis can begin. 
