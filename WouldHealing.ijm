//*
//Caner Ercan
//First Dialog Asks for the folder which contains all the images
//Second dialog asks for time zero image
//It generates a file in the same folder named as Results.csv
*//

setBatchMode(true);
input = getDirectory("Choose Image Directory");
//input + "C:/Users/Caner/Desktop/cedric/"
filelist = getFileList(input) 
//Get all the images
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")) { 
        open(input + File.separator + filelist[i]);
    } 
}
// Analysing the time zero image

//Select time zero with dialog
Dialog.create("Time Zero");
Dialog.addImageChoice("First Image")
Dialog.show();
FirstImage = Dialog.getImageChoice()

//FirstImage="VID247_A1_18_00d00h00m.tif"



imageTitle = getTitle();
//Process and Analyse the time zero
run("8-bit");
run("Find Edges");
run("Gaussian Blur...", "sigma=10");
setAutoThreshold("Otsu dark");
//run("Threshold...");
run("Create Selection");
roiManager("Add");
roiManager("Select", 0);
run("Create Mask");
roiManager("Delete");
run("Create Selection");
run("Make Inverse");
roiManager("Split");

//Get The biggest ROI
Area=newArray(roiManager("count"));
        for (i=0; i<roiManager("count");i++){
                roiManager("select", i);
                getStatistics(Area[i], mean, min, max, std, histogram);
        }
        AreaLarge = 0;
        for (i=0; i<(roiManager("count"));i++){
                if (Area[i]>AreaLarge){
                        AreaLarge=Area[i];
                        large = i;
                }
        }
/*
//Remove the rest
a = Array.getSequence(roiManager("count"));
awo = Array.deleteIndex(a, large)
roiManager("select", awo);
roiManager("delete");
*/


// Analyse the biggest ROI
//selectWindow("Mask");
roiManager("select", large);
roiManager("Measure");
roiManager("Save", input + "/timezero.roi");
roiManager("deselect");
roiManager("Delete");
setResult("Label", 0, imageTitle);
run("Close All");


//The rest of the images
for (k = 0; k < lengthOf(filelist); k++) {
    if (endsWith(filelist[k], ".tif")) { 
        open(input + File.separator + filelist[k]);
        imageTitle = getTitle();
        roiManager("Open", input + "/timezero.roi");
        roiManager("select", 0);
        run("8-bit");
run("Find Edges");
run("Gaussian Blur...", "sigma=10");
setAutoThreshold("Otsu dark");
//run("Threshold...");
run("Create Selection");
roiManager("Add");
roiManager("Select", newArray(0,1));
roiManager("AND");
roiManager("Add");
roiManager("Select", 2)
roiManager("Measure");
setResult("Label",  nResults-1, imageTitle);


roiManager("deselect");
roiManager("delete");
run("Close All");
    } 
}
saveAs("Results", input + "/Results.csv");
print("DONE!");
