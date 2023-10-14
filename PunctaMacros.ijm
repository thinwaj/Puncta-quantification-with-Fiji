/*
 * 20220708: MM v1 of macros that facilitate file renaming, selection of cells and quantification of punctae
 */
requires("1.52o");

//////////////////////////////////////////////////////////////////////////////////////////
macro "Fix funny filenames [1]" {
dir = getDirectory("Which directory contains file names with brackets?");

makelist(dir);
 function makelist(dir){
 	list = getFileList(dir);
		for (i=0; i<list.length; i++) {
			if (endsWith(list[i], "/")){makelist(""+dir+list[i]);}     		
     	else{todo = fixFileNames(list);
     	if (todo.length == 0) {exit("No file names need fixing!");}
  

function fixFileNames(list) {
	result = newArray(list.length * 2);
	j = 0;
	for (i = 0; i < list.length; i++) {
		fixedName = replace(list[i], "[\\]\\[\\\\ \t\"']", "_");
		fixedName = replace(fixedName, " ", "_");
		fixedName = replace(fixedName, ",", "_");
		fixedName = replace(fixedName, "-", "");
		fixedName = replace(fixedName, ")", "");
		fixedName = replace(fixedName, "(", "");
		fixedName = replace(fixedName, "__", "_");
		fixedName = replace(fixedName, "\\.1", "1");
		fixedName = replace(fixedName, "\\.2", "2");
		fixedName = replace(fixedName, "\\.3", "3");
		fixedName = replace(fixedName, "\\.4", "4");
		fixedName = replace(fixedName, "\\.5", "5");
		fixedName = replace(fixedName, "\\.6", "6");
		fixedName = replace(fixedName, "\\.7", "7");
		fixedName = replace(fixedName, "\\.8", "8");
		fixedName = replace(fixedName, "\\.9", "9");
		fixedName = replace(fixedName, "\\.0", "0");
		
		if (list[i] != fixedName) {
			result[j++] = list[i];
			result[j++] = fixedName;
		}}
	if (j < result.length) {result = Array.trim(result, j);}
	return result;
}

// Verify that the rename targets do not exist yet
for (i = 1; i < todo.length; i += 2) {
	if (File.exists(dir + todo[i])) {
		File.delete(dir+todo[i]);}}

// Actually rename the problematic files
for (i = 0; i < todo.length; i += 2) {
	print("Renaming " + todo[i] + " to " + todo[i + 1]);
	File.rename(dir + todo[i], dir + todo[i + 1]);}
     	}}}
}
//////////////////////////////////////////////////////////////////////////////////////////

macro "Isolate cells [2]" { 

if (nImages==0){
	sourcefolder = getDirectory("Source folder");
	open();}
getDimensions(width, height, channels, slices, frames);

path = getDirectory("image");
title = getTitle();
title = split(title, ".");
title = title[0];
run("Z Project...", "projection=[Max Intensity]");
ori = getImageID();
dialogtitle = "Define ROI";
message = "Draw your ROI and click \"Add[t]\" in the ROI manager (or \"t\" on the keyboard). \nOnce done, click\"ok\"";
roiManager("reset");
roiManager("Show all");
waitForUser(dialogtitle, message);
setBatchMode(true);
n = roiManager("count");
for (i=0; i<n; i++) {
roiManager("Deselect");
roiManager("show none");
roiManager("show All");
selectImage(ori);
run("Duplicate...", "duplicate");
dupl = getImageID();
roiManager("select", i);
run("Duplicate...", "duplicate");
namesubfile = "subROI_"+(i+1)+"_"+title;
myDir = path+namesubfile+File.separator;
if(File.exists(myDir)){exit("directory already exists");}
File.makeDirectory(myDir);
saveAs("tif", myDir+namesubfile);
close();
selectImage(dupl);
close();}
close("*");
if (isOpen("ROI Manager")) {
     selectWindow("ROI Manager");
     run("Close");}
setBatchMode(false);
if (isOpen("Log")) {selectWindow("Log"); run ("Close");}
if (isOpen(title)) {selectWindow(title); close(title);}
}
///////////////////////////////////////////////////////////////////////////////
macro "Quantification [3]" {
roiManager("reset");
if (nImages == 0){waitForUser("First, open your image(s) of interest. \nThen click\"ok\"");}
run("Set Measurements...", "area mean display redirect=None decimal=3");
roiManager("add");
roiManager("Remove Channel Info");
roiManager("Remove Slice Info");
roiManager("Remove Frame Info");
if (isOpen("Quantification")==0) {Table.create("Quantification");}
title = getTitle();
dir = getDirectory("image");
run("Split Channels");
selectImage("C1-"+title);
setAutoThreshold("Intermodes dark");
roiManager("select", 0);
setBackgroundColor(0, 0, 0);
run("Clear Outside");
roiManager("reset");
run("Analyze Particles...", "add");
n = roiManager("count");
for (i = 0; i < n; i++) {
roiManager("select", i);
selectImage("C1-"+title);
roiManager("Measure");
area = getResult("Area", nResults-1);
meanRed = getResult("Mean", nResults-1);
selectImage("C2-"+title);
roiManager("Measure");
meanGreen = getResult("Mean", nResults-1);
ratio = meanGreen / meanRed;
ii = i+1;
ii = d2s(ii, 0);
number=ii+" out of " +n;

selectWindow("Quantification");
k = Table.size;
	Table.set("image", k, title);
	Table.set("spot #", k, number);
	Table.set("spot size", k, area);
	Table.set("mean Intsen. red", k, meanRed);
	Table.set("mean Intsen. green", k, meanGreen);
	Table.set("ratio", k, ratio);
}
roiManager("Save", dir+"RoiSet.zip");
if (isOpen("Log")) {selectWindow("Log"); run ("Close");}
if (isOpen("Results")) {selectWindow("Results"); run ("Close");}
if (isOpen("ROI Manager")) {selectWindow("ROI Manager"); run ("Close");}
close("*");
}
