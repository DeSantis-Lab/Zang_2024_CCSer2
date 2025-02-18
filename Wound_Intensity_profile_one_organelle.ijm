// Modified by Morgan in August 2020, Modified by A.G. in 2020 Augest based on the previous script written by Breane Budaitis.
// Modified by Juliana in September 2022

/*  1. crop images into images containing single cells;
 *  2. the software recognizes the nucleus, and finds the centroid of nucleus;
 *  3. draw the boundary of the cell;
 *  4. draw a line from the centroid and a point of the cellular oueline; repeat the process to go through all the points of the outline of the cell, add all the lines into the ROIs;
 *  5. measure the length and angle of each line by the "ROI measurement" function;
 *  6. select out scanning lines with intervals of every 1 degree; further select scanning lines that are longer than 1/2 maximum length;
 *  (6-1) if needed, further select out voild lines: plot the mean intensity of remaining scanning lines, if the distribution nices fit into two Guassian curves, delete the group with lower intensity;   
 *  7. measure the intensity distribution of all the selected the scanning lines;
 *  8. normalize the intensity profiles of these lines and export them as .cvs files, sum (or average) all of them to generate a total profile of a cell. 
 */


function pdf(data, mean, variance) {
	pdfArray = newArray(lengthOf(data));
	for (i = 0; i < lengthOf(data); i++) {
		s1 = 1/(Math.sqrt(2*PI*variance));
		s2 = Math.exp(-(Math.sqr(data[i]-mean)/(2*variance)));
		pdfArray[i] = s1*s2;
	}
	return pdfArray;
	} 

function arraySum(array) {
	sum = 0;
	for (i = 0; i < lengthOf(array); i++) {
		sum + = array[i];
		} 
	return sum;
	}

function arrayMultiplynumber(array, number) {
	result = newArray(lengthOf(array));
	for (i = 0; i < lengthOf(array); i++) {
		result[i] = array[i] * number;
		}
	return result;
	}

function arrayMinusnumber(array, number) {
	result = newArray(lengthOf(array));
	for (i = 0; i < lengthOf(array); i++) {
		result[i] = array[i] - number;
		}
	return result;
	}

function arraySqr(array) {
	result = newArray(lengthOf(array));
	for (i = 0; i < lengthOf(array); i++) {
		result[i] = Math.sqr(array[i]);
		}
	return result;
	}

function arrayMultiplyArray(array1, array2) {
	if (lengthOf(array1)!= lengthOf(array2)) {
		print("Error: two arrays of different lengths cannot be multiplied.")
		}
	else {
		multipliedArray = newArray(lengthOf(array1));
		for (i = 0; i < lengthOf(array1); i++) {
			multipliedArray[i] = array1[i]*array2[i];
			}
		return multipliedArray;		
		}	
	}

function arrayPlusArray(array1, array2) {
	if (lengthOf(array1)!= lengthOf(array2)) {
		print("Error: two arrays of different lengths cannot be summed.")
		}
	else {
		sumArray = newArray(lengthOf(array1));
		for (i = 0; i < lengthOf(array1); i++) {
			sumArray[i] = array1[i] + array2[i];
			}
		return sumArray;
		}
	}

function arrayMinusArray(array1, array2) {
	if (lengthOf(array1)!= lengthOf(array2)) {
		print("Error: two arrays of different lengths cannot be subtracted.")
		}
	else {
		sumArray = newArray(lengthOf(array1));
		for (i = 0; i < lengthOf(array1); i++) {
			sumArray[i] = array1[i] - array2[i];
			}
		return sumArray;
		}
	}

function arrayDivideArray(array1, array2) {
	if (lengthOf(array1)!= lengthOf(array2)) {
		print("Error: two arrays of different lengths cannot be devided.")
		}
	else {
		dividedArray = newArray(lengthOf(array1));
		for (i = 0; i < lengthOf(array1); i++) {
			dividedArray[i] = array1[i]/array2[i];
			}
		return dividedArray;		
		}	
	}


// Note: one cropped frame should ONLY contain one nucleus for the software to recognize

/* Measure the length of the leading edge of the analysis cell; */ 

setTool("freeline");
waitForUser("Trace the leading edge");
roiManager("Add");
run("Measure");
//roiManager("save", output + ".roi"); // save the ROI ;
roiManager("Delete");
saveAs("Results"); // save leading edge (length in microns);
run("Clear Results");

/* 1. Open images, and crop images into single cells; */

output = getDirectory("Create or select a folder for the measurement of one cell");

n_channels = 3; // set number of channels; default is 3 (usually enough)
setTool("rectangle");

waitForUser("Draw a rectangle");
roiManager("Add");
run("Crop");
//for (j = 0; j < n_channels-1; j++) {
//	waitForUser("Select the next window to crop it");
//	roiManager("Select", 0);
//	run("Crop");
//}
roiManager("deselect");
roiManager("delete");
run("Split Channels");
	
for (j = 0; j < n_channels; j++) {
	waitForUser("Click on a window to save it");
	run("Set Scale...", "distance=0 known=0 unit=pixel");
	title = getTitle();
	saveAs("Tiff", output + title);
	}

 
/* 2. the software recognizes the nucleus, and finds the centroid (x, y) of nucleus; */

waitForUser("Select the DAPI window");
setOption("ScaleConversions", true);
run("8-bit");
setAutoThreshold("Default dark");
run("Threshold...");
setAutoThreshold(); // or setThreshold(73, 255); 
setOption("BlackBackground", true);
run("Convert to Mask");
run("Analyze Particles...", "size=1000-50000 show=Nothing display exclude add");
waitForUser("check the centroid, otherwise draw nucleus by hand");
run("Set Measurements...", "centroid limit redirect=None decimal=3");
run("Clear Results");
roiManager("Measure");
x0 = getResult("X", 0);	
y0 = getResult("Y", 0);
saveAs("Results", output + "Centroid.csv"); // save centroid (x, y);
roiManager("Deselect");
roiManager("Delete");

//waitForUser("check the (x, y) coordinates of centroid");

run("Clear Results");

File.makeDirectory(output+ "OrganelleFinal"); // initiate a place to save the final results, which is the normalized distribution profile;
saveAs("Results", output + "/" + "OrganelleFinal" + "/"+ "Results.csv");


/* 3. draw the boundary of the cell; */

setTool("freehand");

waitForUser("Draw the cell boundary by hand, click OK when done");

roiManager("Add");
roiManager("Select", 0);

waitForUser("Select the Organelle window to measure intensity profile");
run("Subtract Background...", "rolling=50"); // local uneven illumination background subtraction by "rolling ball" algrithm
roiManager("Select", 0);
getSelectionCoordinates(xpoints, ypoints);
roiManager("save", output + "cell_outline.zip");
roiManager("Deselect");
roiManager("Delete");

/* 4. draw a line from the centroid and a point along the oueline of the cell; repeat the process to go through all the points on the outline of the cell, add the lines into the ROIs; */

for (i = 0; i < xpoints.length; i ++) {
	makeLine(x0, y0, xpoints[i], ypoints[i]);
	roiManager("Add");
	}

/* 5. measure the length and angle of each line by the "ROI measurement" function;*/

//waitForUser("Select the Organelle window to measure intensity profile");
//roiManager("reset");

//open(output + "ROI.zip");
//roiManager("Open", output + "ROI.zip");
run("Set Measurements...", "area mean limit redirect=None decimal=3");
run("Clear Results");
roiManager("Deselect");
roiManager("Measure");

/* 6. select out scanning lines with intervals of every 1 degree; further select scanning lines that are longer than 1/2 maximum length;*/

n = roiManager("count"); //getValue("results.count");
//print(n);
setOption("ExpandableArrays", true);
lengtharray = newArray(0);
for (i = 0; i < n; i ++) {
	length = getResult("Length", i);
	lengtharray[i] = length;
	}
Array.getStatistics(lengtharray, min, lengthmax, mean, stdDev);
//Array.print(lengtharray);
//print(lengthmax);

//setOption("ExpandableArrays", true);
//indexes = newArray(0);
//for (i = 1; i < n; i ++) {
//	angle = getResult("Angle", i) + 180;
//	pre_angle = getResult("Angle", i-1) + 180;
//	length = getResult("Length", i);
//	if (floor(angle) == floor(pre_angle) || length < 0.5 * lengthmax) {
//		indexes = Array.concat(indexes, i);
//		}
//	}
	
setOption("ExpandableArrays", true);
indexes = newArray(0);
for (i = 1; i < n; i ++) {
	angle = getResult("Angle", i);
	pre_angle = getResult("Angle", i-1);
	if (floor(angle) == floor(pre_angle) || angle < 25 || angle > 155) {
		indexes = Array.concat(indexes, i);
		}
	}

	
//Array.print(indexes);
roiManager("select", indexes);
roiManager("delete");
run("Clear Results");
roiManager("Deselect");
roiManager("Measure");

saveAs("Results", output + "Results.csv"); // save the measurement of mean intensity and area information of each ROI;
roiManager("save", output + "ROI.zip"); // safe the first ROI set;

/* (6-1) if needed, further select out voild lines: 
* plot the mean intensity of remaining scanning lines, if the distribution nices fit into two Guassian curves, delete the group with lower intensity; 
*/

setOption("ExpandableArrays", true);
intensityArray = newArray(); // delete "void lines" that have low mean intensity, likely do not cover positive signals;
for (i = 0; i < nResults; i++) {
	intensityArray[i] = getResult("Mean", i);
	}

weights = newArray(0.5, 0.5);
means = newArray(intensityArray[0], intensityArray[lengthOf(intensityArray)-1]);
variances = newArray(100000, 100000);


//Array.print(intensityArray);

for (step = 0; step < 50; step++) {
	
	likelihood_1 = pdf(intensityArray, means[0], variances[0]);
	likelihood_2 = pdf(intensityArray, means[1], variances[1]);
	
	posterior_1 = arrayDivideArray(arrayMultiplynumber(likelihood_1, weights[0]), arrayPlusArray(arrayMultiplynumber(likelihood_1, weights[0]), arrayMultiplynumber(likelihood_2, weights[1])));
	posterior_2 = arrayDivideArray(arrayMultiplynumber(likelihood_2, weights[1]), arrayPlusArray(arrayMultiplynumber(likelihood_1, weights[0]), arrayMultiplynumber(likelihood_2, weights[1])));

	//Array.print(likelihood_2);

	means[0] = arraySum(arrayMultiplyArray(posterior_1, intensityArray))/arraySum(posterior_1);
	means[1] = arraySum(arrayMultiplyArray(posterior_2, intensityArray))/arraySum(posterior_2);

	variances[0] = arraySum(arrayMultiplyArray(posterior_1, arraySqr(arrayMinusnumber(intensityArray, means[0]))))/arraySum(posterior_1);
	variances[1] = arraySum(arrayMultiplyArray(posterior_2, arraySqr(arrayMinusnumber(intensityArray, means[1]))))/arraySum(posterior_2);

	weights[0] = arraySum(posterior_1)/lengthOf(posterior_1);
	weights[1] = arraySum(posterior_2)/lengthOf(posterior_2);

	}

function GaussianCurve(X, mu, sigmaSqr) {
	result = newArray(lengthOf(X));
	for (i = 0; i < lengthOf(X); i++) {
		s1 = 1/(Math.sqrt(2*PI*sigmaSqr));
		s2 = Math.exp(-(Math.sqr(X[i]-mu)/(2*sigmaSqr)));
		result[i] = s1*s2;
	}
	return result;
	}

range = 20000; //set the range for the intensity histogram plot;
xValues = newArray(range);
for (i = 0; i < (range); i ++) {
	xValues[i] = i;
	}
//Array.print(xValues);

y1prob = arrayMultiplynumber(GaussianCurve(xValues, means[0], variances[0]), weights[0]);
y2prob = arrayMultiplynumber(GaussianCurve(xValues, means[1], variances[1]), weights[1]);
y1Counts = arrayMultiplynumber(y1prob, lengthOf(intensityArray)*20);
y2Counts = arrayMultiplynumber(y2prob, lengthOf(intensityArray)*20);

Plot.create("Fitted Curve", "Mean_Intensity", "Counts");
Plot.add("dot", xValues, y1Counts);
Plot.add("dot", xValues, y2Counts);
Plot.addHistogram(intensityArray, 20, 0);

judge = arrayMinusArray(y1prob, y2prob); // find the crossing point of the two Gaussian curves and set the intensity value as threshold;
Array.getStatistics(means, min, max, mean, stdDev);
left = min; 
right = max;
threshold = 0;
factor = judge[left]*judge[right];
//print(factor);
mini = Math.abs(left-right);
if (factor >= 0) {
	waitForUser("Please make sure the data set looks good");
	open(output + "ROI.zip");
	roiManager("Open", output + "ROI.zip");
	roiManager("Show All without labels");
	run("Flatten");
	saveAs("PNG", output + "Organelle Scanning lines.png");
	close();
	}
else {
	
	while (factor < 0 && mini >= 0.001) {
		threshold = (left+right)/2;
		if (judge[left]*judge[threshold] < 0) {
			right = threshold;
			left = left;
			factor = judge[left]*judge[right];
			mini = Math.abs(left-right);
			}
		else {
			left = threshold;
			right = right;
			factor = judge[left]*judge[right];
			mini = Math.abs(left-right);
			}
		//print(factor + ", " + threshold + ", " + mini);
		}

	height = 0.5*(y1Counts[round(means[0])]+y2Counts[round(means[1])]);
	space = round(height)/50;
	xLine = newArray(round(height)*(1/space));
	for (i = 0; i < lengthOf(xLine); i++) {
		xLine[i] = threshold;
		}
	yLine = newArray(lengthOf(xLine));
	for (i = 0; i < lengthOf(xLine); i++) {
		yLine[i] = space*i;
		}
	Plot.add("cross", xLine, yLine);
	Plot.show();
	//print("threshold is: " + threshold);

	waitForUser("check the threshold");

	//delete the void lines from the ROIs and save a new ROI file in the path. 
	indexes_snd = newArray();
	for (i = 0; i < roiManager("count"); i ++) {
		mean_intensity = getResult("Mean", i);
		if (mean_intensity < threshold) {
			indexes_snd = Array.concat(indexes_snd, i);
			}
		}
	roiManager("select", indexes_snd);
	roiManager("delete");
	roiManager("save", output + "ROI_snd.zip"); // save the second ROI set;
//	run("Clear Results");
//	roiManager("Measure");
//	saveAs("Results", output + "Results.csv"); // save the measurement of mean intensity and area information of each ROI;

	waitForUser("If you ARE satisfied with the void-line-correction, click OK and type 1; otherwise type 0 to go back to the previous ROI set");
	check = getNumber("prompt", 0);
	if (check == 0) {
		roiManager("deselect");
		roiManager("delete");
		open(output + "ROI.zip");
		roiManager("Show All without labels");
		run("Flatten");
		saveAs("PNG", output + "Organelle Scanning lines.png");
		close();
		}
	else {
		roiManager("Show All without labels");
		run("Flatten");
		saveAs("PNG", output + "Organelle Scanning lines.png");
		close();
	}
}



/* 7. measure the intensity distribution of all the selected the scanning lines; */

File.makeDirectory(output+ "OrganelleProfile");
for (i = 0; i < roiManager("count"); i++) {
	run("Clear Results");
	roiManager("Select", i);
	profile = getProfile();
	for (j = 0; j < profile.length; j ++) {
		setResult("Value", j, profile[j]);
		}
	updateResults();
	File.makeDirectory(output + "/" + "OrganelleProfile" + "/" + i);
	saveAs("Results", output + "/" + "OrganelleProfile" + "/" + i + "/Results.csv");
	}
run("Clear Results");
	
/* 8. normalize the intensity profiles of these lines and export them as .cvs files, sum (or average) all of them to generate a total profile of a cell. */
// normalize length to 1 with bin size of 0.05 (for example); sum the intensity within each bin;

/* Organelle internsity, save to <OrganelleFinal folder*/

//open(output + "Results.csv");
m = roiManager("count");
//run("Clear Results");

BinNumber = 20; // set bin number;

setOption("ExpandableArrays", true);
BinvalueSum = newArray(BinNumber); //sum the intensity within a certain bin of all ROIs; get an array of summed bin values;

for (i = 0; i < m; i++) {	// iterate through the profile of all the ROIs
		
	open(output + "/" + "OrganelleProfile" + "/" + i + "/Results.csv");
	s = getValue("results.count");
	binsize = s/BinNumber;
	
	setOption("ExpandableArrays", true);
	BinvalueArray = newArray(0);
	
	for (j = 0; j < BinNumber-1; j++) {
		low = round(j*binsize);
		high = round((j+1)*binsize);
		Binvalue = 0;
		for (k = low; k < high; k++) {
			x = k;
			y = getResult("Value", x);
			Binvalue = Binvalue + y;
			}
		BinvalueArray[j] = Binvalue;
		setResult("Binvalue", j, Binvalue); // sum the value of all pixels within a bin to be the "Binvalue" for each ROI;
		updateResults();
		}
		
	LastBinvalue = 0;
	for (l = round((BinNumber-1)*binsize); l < s; l++) {
		LastBinvalue = LastBinvalue + getResult("Value", l);
		}
	BinvalueArray[BinNumber-1] = LastBinvalue;
	setResult("Binvalue", BinNumber-1, LastBinvalue);
	updateResults();
	//print(BinValueArray[bin-1]);
	saveAs("Results", output + "/" + "OrganelleProfile" + "/" + i + "/Results.csv");
	run("Clear Results");

	for (k = 0; k < BinNumber; k++) {
		BinvalueSum[k] = BinvalueSum[k] + BinvalueArray[k]; //add up the Binvalue of the current ROI to the BinvalueSum array;
		}
	
	open(output + "/" + "OrganelleFinal" + "/"+ "Results.csv"); //update the binned intensity profile of each ROI 
	for (z = 0; z < BinNumber; z++) {
		setResult(i, z, BinvalueArray[z]);
	}
	updateResults();
	saveAs("Results", output + "/" + "OrganelleFinal" + "/"+ "Results.csv");

}

Totalintensity = 0;
open(output + "/" + "OrganelleFinal" + "/"+ "Results.csv");
for (e = 0; e < BinNumber; e++) {
	Totalintensity = Totalintensity + BinvalueSum[e];
}

for (f = 0; f < BinNumber; f++) {
	setResult("BinvalueSum", f, BinvalueSum[f]/Totalintensity);
}
updateResults();
saveAs("Results", output + "/" + "OrganelleFinal" + "/"+ "Results.csv");


waitForUser("Analysis finished");
run("Clear Results");
roiManager("Deselect");
roiManager("Delete");
run("Close All");
