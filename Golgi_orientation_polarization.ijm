/* Get straight line input to calculate the wound direction
 *  	store in a numeric value
 * Get a picture input of oval ROI containing the nucleus and the Golgi of a single cell 
 * 
 * From the direction of the wound, calculate the direction of the migration
 * 		the angle is positive if the cells are below the wound line
 * 		the angle is negative if the cells are above the wound line
 * 		
 * From the ROI and picture
 * 		extract the position of nuclear centroid
 * 		extract the position of each single dot along the ROI 
 * 			(interpolate the ROI before extracting points) 
 * 		draw scanning lines along the ROI, save them as ROIs
 * 			if the number of lines is larger than 400 or so, might want to make it more sparse
 * 		get the sum of intensity along each scanning line, save the values in an array
 * 		take the intensity array 
 * 			run the Gaussian split function to find the threshold between background and Golgi
 * 			delete the scanning lines that is below the intensity threshold
 * 			measure the angles of remaining scanning lines
 * 			
 * 	take the angle measurement, compare it to the direction of cell migration
 * 		for the output, can calculate the average "angle difference"
 * 			normal cells should have the "angle difference" close to zero 
 * 		can also calculate the range of angle
 * 			normal cells might have a more tightly packed Golgi? If so this will tell us
 * 			
 * 	Note: in the final result of angle difference, a "+X" value means it rotates X degrees counter-clockwise 
 * 	from the reference direction; a "-X" value means it rotates X degrees clock-wise from the reference direction
 */ 


/* 1. get the direction of wound*/

output = getDirectory("Select the folder for output");

setTool("line");
waitForUser("Open image, draw a straight line along the wound, click OK when done");
run("Measure");

direction = getResult("Angle", 0);
//print(direction);
refDirection = direction + 90; // the direction perpendicular to the wound direction

cellBelowOrLeftOfWound = getBoolean("For horisontal wound, are cells below the wound?\nFor verticle wound, are cells on the left of the wound?");
if (cellBelowOrLeftOfWound) {
	if (refDirection < 0) {
		refDirection = refDirection + 180;
	}
} else {
	if (refDirection > 0) {
		refDirection = refDirection - 180;
	}
}
//print(refDirection);

run("Clear Results");

//refDirection = 90;
//refDirection = 270 if cell is migrating downwards;

/* draw a oval ROI to include the nucleus and Golgi*/

setTool("ellipse");
waitForUser("Draw an ellipse around the nucleus and Golgi of a single cell, click OK when done");
run("Crop");
imageName = getTitle();
imageName = getTitleStripExtension(imageName);
Roi.setPosition(1);
roiManager("Add");
saveAs("Tiff", output + File.separator + imageName + "_cropped.tif");
run("Split Channels");

// crop
// save ROI
// split the cropped image 
nuclearCenter = getNuclearCentroid();
x0 = nuclearCenter[0];
y0 = nuclearCenter[1];

roiManager("select", 0);
run("Interpolate", "interval=4");
getSelectionCoordinates(xpoints, ypoints);

roiManager("deselect");
roiManager("delete");

for (i = 0; i < lengthOf(xpoints); i ++) {
	makeLine(x0, y0, xpoints[i], ypoints[i]);
	roiManager("Add");
}

waitForUser("Select the Golgi image");

run("Set Measurements...", "area mean limit redirect=None decimal=3");
run("Clear Results");
roiManager("Deselect");
roiManager("Measure");

n = roiManager("count");

setOption("ExpandableArrays", true);
angleArray = newArray();
for (i = 0; i < n; i ++) {
	angle = getResult("Angle", i);
	angleArray[i] = angle;
	}

setOption("ExpandableArrays", true);
intensityArray = newArray(); // to find "void lines" that have low mean intensity, likely do not go through any organelles;
for (i = 0; i < n; i++) {
	intensityArray[i] = getResult("Mean", i);
}

//Array.print(intensityArray);
roiManager("save", output + File.separator + "ScanningLines.zip");

threshold = splitTwoGaussian(intensityArray);

reducedIndexes = newArray();
for (i = 0; i < n; i ++) {
	if (intensityArray[i] < threshold) {
		reducedIndexes = Array.concat(reducedIndexes, i);
	}
}
roiManager("select", reducedIndexes);
roiManager("delete");
roiManager("save", output + File.separator + "ReducedScanningLines.zip");

new_n = roiManager("count");
run("Clear Results");
roiManager("Deselect");
roiManager("Measure");

setOption("ExpandableArrays", true);
reducedAngleArray = newArray();
for (i = 0; i < new_n; i ++) {
	angle = getResult("Angle", i);
	if (angle >= 0) {
		reducedAngleArray[i] = angle;
	} else {
		reducedAngleArray[i] = angle + 360;
	}	
}

for (i = 0; i < new_n; i ++) {
	angle_diff = reducedAngleArray[i] - refDirection;
	if (angle_diff > 180) {
		angle_diff = angle_diff - 360;	
	}
	if (angle_diff < -180) {
		angle_diff = angle_diff + 360;
	}
	setResult("AngleDiff", i, angle_diff);
}

/*
// optional: calculate the weighted average
setOption("ExpandableArrays", true);
reducedIntensityArray = newArray();
for (i = 0; i < new_n; i ++) {
	intensity = getResult("Mean", i);
	reducedIntensityArray[i] = intensity;
}


intensitySum = arraySum(reducedIntensityArray);
for (i = 0; i < new_n; i++) {
	weightedAngleDiff = getResult("AngleDiff", i);
	weightedAngleDiff = weightedAngleDiff * (reducedIntensityArray[i]/intensitySum);
	setResult("WeightedAngleDiff", i, weightedAngleDiff);
}
*/

saveAs("Results", output + File.separator + "Measurement.csv"); // save centroid (x, y);
	
run("Clear Results");
roiManager("Deselect");
roiManager("Delete");
run("Close All");
close("*");
beep();
waitForUser("Finished!");



/*  ----------------------------------------------------------------------------------------------------------------------------------------
 *  ----------------------------------------------------------------------------------------------------------------------------------------
 *  ----------------------------------------------------------------------------------------------------------------------------------------
 */


function getNuclearCentroid() {
	x0 = 0;
	y0 = 0;
	
	waitForUser("Select the DAPI window");
	run("Set Scale...", "distance=0 known=0 unit=pixel");
	setOption("ScaleConversions", true);
	run("8-bit");
	setAutoThreshold("Default dark");
	run("Threshold...");
	setAutoThreshold(); // or setThreshold(73, 255); 
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=1000-50000 show=Nothing display exclude add"); //determine the size range of nucleus
		
	nucleusIsGood = getBoolean("Does the nucleus look good?");
	if (nucleusIsGood) {
		run("Set Measurements...", "centroid limit redirect=None decimal=3");
		run("Clear Results");
		count = roiManager("count");
		roiManager("Select", count-1);
		roiManager("Measure");
	} else {			
		setTool("elliptical");
		run("Set Measurements...", "centroid redirect=None decimal=3");
		run("Clear Results");
		waitForUser("Select the nucleus region by hand");
		roiManager("add");
		count = roiManager("count");
		roiManager("Select", count-1);
		roiManager("Measure");		
	}

	x0 = getResult("X", 0);	
	y0 = getResult("Y", 0);
//	saveAs("Results", output + File.separator + "cell_center.csv"); // save centroid (x, y);
	run("Clear Results");		
	return newArray(x0, y0);
}

function splitTwoGaussian(intensityArray) {
	
	weights = newArray(0.5, 0.5);
	means = newArray(intensityArray[0], intensityArray[lengthOf(intensityArray)-1]); // take the left-most and right-most points as the starting points
	variances = newArray(100000, 100000); //depend on the estimated variance of the Gaussian distributions; note that here it's the square of STD, not STD itself

	stepNumber = 50; 
	for (step = 0; step < stepNumber; step++) {
		
		likelihood_1 = pdf(intensityArray, means[0], variances[0]);
		likelihood_2 = pdf(intensityArray, means[1], variances[1]);
		
		posterior_1 = arrayDivideArray(arrayMultiplynumber(likelihood_1, weights[0]), arrayPlusArray(arrayMultiplynumber(likelihood_1, weights[0]), arrayMultiplynumber(likelihood_2, weights[1])));
		posterior_2 = arrayDivideArray(arrayMultiplynumber(likelihood_2, weights[1]), arrayPlusArray(arrayMultiplynumber(likelihood_1, weights[0]), arrayMultiplynumber(likelihood_2, weights[1])));
	
		means[0] = arraySum(arrayMultiplyArray(posterior_1, intensityArray))/arraySum(posterior_1);
		means[1] = arraySum(arrayMultiplyArray(posterior_2, intensityArray))/arraySum(posterior_2);
	
		variances[0] = arraySum(arrayMultiplyArray(posterior_1, arraySqr(arrayMinusnumber(intensityArray, means[0]))))/arraySum(posterior_1);
		variances[1] = arraySum(arrayMultiplyArray(posterior_2, arraySqr(arrayMinusnumber(intensityArray, means[1]))))/arraySum(posterior_2);
	
		weights[0] = arraySum(posterior_1)/lengthOf(posterior_1);
		weights[1] = arraySum(posterior_2)/lengthOf(posterior_2);
		//print(step + "running split Guassian...");
	}

	range = 20000; //set the range for the intensity histogram plot;
	xValues = newArray(range);
	for (i = 0; i < (range); i ++) {
		xValues[i] = i;
	}	
	
	y1prob = arrayMultiplynumber(getGaussianCurve(xValues, means[0], variances[0]), weights[0]);
	y2prob = arrayMultiplynumber(getGaussianCurve(xValues, means[1], variances[1]), weights[1]);
	y1Counts = arrayMultiplynumber(y1prob, lengthOf(intensityArray)*20);
	y2Counts = arrayMultiplynumber(y2prob, lengthOf(intensityArray)*20);
	
//	Plot.create("Fitted Curve", "Mean_Intensity", "Counts");
//	Plot.add("dot", xValues, y1Counts);
//	Plot.add("dot", xValues, y2Counts);
//	Plot.addHistogram(intensityArray, 20, 0);
	
	//judge = arrayMinusArray(y1prob, y2prob); // find the crossing point of the two Gaussian curves and set the intensity value as threshold;

	Array.getStatistics(means, min, max, mean, stdDev); // the statistics of the "means" array, which contains two mean values
	
	left = min;
	right = max;
	threshold = (left+right)/2;
	
	factor = judgeTwoGaussian(left, means, variances, weights)*judgeTwoGaussian(right, means, variances, weights);
	diff = Math.abs(left-right);
	
	if (factor >= 0) {
		print("two distributions too close to each other");
		threshold = 0; // so that the user can know that the two curves are not well seperated when they see 0
	}
	else {

		diffLimit = 0.05; // set the limit to determin when 2 points are close enough to say they merge at the threshold
		while (factor < 0 && diff >= diffLimit) {
			if (judgeTwoGaussian(left, means, variances, weights)*judgeTwoGaussian(threshold, means, variances, weights) < 0) {
				right = threshold;
				left = left;
				factor = judgeTwoGaussian(left, means, variances, weights)*judgeTwoGaussian(right, means, variances, weights);
				diff = Math.abs(left-right);
			}
			else {
				left = threshold;
				right = right;
				factor = judgeTwoGaussian(left, means, variances, weights)*judgeTwoGaussian(right, means, variances, weights);
				diff = Math.abs(left-right);
			}
			threshold = (left+right)/2;
		}
	
//		height = 0.5*(y1Counts[round(means[0])]+y2Counts[round(means[1])]); // hight of the vertical line is the averaage of 2 peaks
//		numberOfPoints = 50;
//		space = round(height)/numberOfPoints;
//		xLine = newArray(numberOfPoints); // number of points along the vertical line
//		
//		for (i = 0; i < lengthOf(xLine); i++) {
//			xLine[i] = threshold;
//		}
//		yLine = newArray(lengthOf(xLine));
//		for (i = 0; i < lengthOf(xLine); i++) {
//			yLine[i] = space*i;
//		}
//		Plot.add("cross", xLine, yLine);
//		Plot.show();
	
//		waitForUser("check the threshold, then click the image to be measured");
		
	}
	
	return threshold;

}



// ------------------------------------------ SMALL FUNCTIONS ------------------------------------------------



function getGaussianCurve(X, mu, sigmaSqr) {
	result = newArray(lengthOf(X));
	for (i = 0; i < lengthOf(X); i++) {
		s1 = 1/(Math.sqrt(2*PI*sigmaSqr));
		s2 = Math.exp(-(Math.sqr(X[i]-mu)/(2*sigmaSqr)));
		result[i] = s1*s2;
	}
	return result;
	}

function getGaussianProb(x, mu, sigmaSqr, weight) {
	s1 = 1/(Math.sqrt(2*PI*sigmaSqr));
	s2 = Math.exp(-(Math.sqr(x-mu)/(2*sigmaSqr)));	
	prob = s1*s2*weight;
	return prob;
}

function judgeTwoGaussian(x, means, variances, weights) {
	judge = getGaussianProb(x, means[0], variances[0], weights[0]) - getGaussianProb(x, means[1], variances[1], weights[1]);
	return judge;
}


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




function zeroFill(i, x) {
	index = "" + i;
	digitNumber = lengthOf(index);
	if (digitNumber > x) {
		exit("zeroFill error: Length of subindex must not be shorter than the number of digits");
	} else {
		for (k=0; k<(x-digitNumber); k++) {
			index = "0" + index;
		}
	}
	return index;
}



function getTitleStripExtension(t) {
	t = replace(t, ".tif", "");        
	t = replace(t, ".tiff", "");      
	t = replace(t, ".lif", "");      
	t = replace(t, ".lsm", "");    
	t = replace(t, ".czi", "");      
	t = replace(t, ".nd2", ""); 
	t = replace(t, ".png", "");
	t = replace(t, ".csv", "");
	return t;
}
