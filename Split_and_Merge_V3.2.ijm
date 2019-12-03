/*
---------------------------------------------------------------------------------------------------
					Split and Merge V3.2
					
	* This macro facilitates generation of figures-ready microscopy images from raw files such as .lsm or .tif
	* User can assign green, red, blue, magenta and cyan channels
	* Background subtraction for individual channels
	* Scale bars can be inserted in individual channels	
    	* Scale bar length can be adjusted (default = 10 µm) 
	* Scale bar width and fonts scale according to image size in pixels
	* Saves the results as .tif files to a new folder in the original image directory

Mehrshad Pakdel

mehrshad.pakdel@posteo.de
https://github.com/MehrshadPakdel

November 22, 2019
----------------------------------------------------------------------------------------------------
*/


list = getList("image.titles");
 if (list.length>=2) {
 	waitForUser("Only one image can be processed at a time. Please close all other images");
	}
list = getList("image.titles");
 if (list.length>=2) {
 		exit("Error: Please open just one image at a time and rerun the macro.");
	 } else { 
		originalImage = getTitle();
		}
		
print("\\Clear");
print("Running Split and Merge V3.2");

//specifiying channel number and arrays for input of user 

getDimensions(width, height, channels, slices, frames);
noCh = channels;
noFrames = frames;

	if (noCh<=1) {
		exit("Error: This macro requires at least two channel hyperstack");
		print("Error: This macro requires at least two channel hyperstacks");
	}
	if (noCh>=4) {
		exit("Error: This macro cannot process more than three channel hyperstacks");
		print("Error: This macro cannot process more than three channel hyperstacks");
	}

	if (noFrames>=2) {
		exit("Error: This macro cannot process multi-frame hyperstacks");
		print("Error: This macro cannot process multi-frame hyperstacks");
	}
/*	
-------------------------------------------------------------------------------------------------- 
* assigning channel colors
* creating saving directory
* defining variables and arrays
-------------------------------------------------------------------------------------------------- 
*/
dir = getDirectory("image");
fileNameWithoutExtension = File.nameWithoutExtension;
	print("Image name: " + fileNameWithoutExtension);
splitDir = dir + "/Results_" + fileNameWithoutExtension + "/";
File.makeDirectory(splitDir);
selectWindow(originalImage);
saveAs("tiff", splitDir + "Orig_" + fileNameWithoutExtension);
originalImage = getTitle();
print("Image directory: " + splitDir); 
	print("Number of channels detected: " + noCh);
dialChannels = newArray("Green", "Red", "Blue", "Magenta", "Cyan");
dialCrop = newArray("Create new or move current selection", "Load saved selection", "Do not crop"); //for dialog to cropping

//assigning Channels to the image stacks
	

	Dialog.create("Assign channels");
		setSlice(1);
		Dialog.addChoice("Choose channel for Ch1", dialChannels, dialChannels[0]);
	Dialog.show();
		flCh1 = Dialog.getChoice();
		print("Channel1 assigned to: " + flCh1);
	Dialog.create("Assign channels");
		setSlice(2);
		Dialog.addChoice("Choose channel for Ch2", dialChannels, dialChannels[0]);
	Dialog.show();
		flCh2 = Dialog.getChoice();
		print("Channel2 assigned to: " + flCh2);
			if (noCh==3) {
				Dialog.create("Assign channels");
					setSlice(3);
					Dialog.addChoice("Choose channel for Ch1", dialChannels, dialChannels[0]);
				Dialog.show();
					flCh3 = Dialog.getChoice();
					print("Channel2 assigned to: " + flCh3);
					}
	run("Channels Tool...");
	Stack.setDisplayMode("color");
	Stack.setChannel(1);	
	run(flCh1);
	Stack.setChannel(2);
	run(flCh2);
		if (noCh==3) {
			Stack.setChannel(3);
			run(flCh3);
			}
	selectWindow("Channels");
	run("Close");

/*	
-------------------------------------------------------------------------------------------------- 
DIALOG SETTINGS
-------------------------------------------------------------------------------------------------- 
*/
if (noCh==2) {
	dialBackground = newArray("Channel 1 " + flCh1, "Channel 2 " + flCh2, "All Channels", "None");	
	dialBar = newArray("Composite", "All channels", "Channel 1: " + flCh1, "Channel 2: " + flCh2);
	Dialog.create("SPLIT AND MERGE V3.2 - IMAGE SETTINGS");
	Dialog.addMessage("SUBTRACT BACKGROUND");
	Dialog.addChoice("Subtract background:", dialBackground, dialBackground[3]);
	Dialog.addMessage(" ");
	Dialog.addMessage("CROP IMAGE");
	Dialog.addChoice("Crop this image?", dialCrop, dialCrop[0]);
	Dialog.addMessage(" ");
	Dialog.addMessage("SCALE BAR");
	Dialog.addChoice("Add scale bar:", dialBar, dialBar[0]);
	Dialog.addNumber("Scale bar length:", 10);
	Dialog.addCheckbox("Insert scale bar unit", true);
	Dialog.addMessage(" ");
	Dialog.addMessage("FIGURE MONTAGE");
	Dialog.addCheckbox("Create figure montage", true);
	Dialog.addMessage(" ");
	Dialog.show();
	answerBackground = Dialog.getChoice();
	answerCrop = Dialog.getChoice();
	answerBar = Dialog.getChoice();		//array to choose in which windows a scale bar should be inserted
	barLength = Dialog.getNumber();		//dialog to get the scale bar length in number
	unitNumber = Dialog.getCheckbox();	//checkbox for adding microns number into scale bar	
	answerMontage = Dialog.getCheckbox();
}

if (noCh==3) {
	dialBackground = newArray("Channel 1 " + flCh1, "Channel 2 " + flCh2, "Channel 3 " + flCh3, "All Channels", "None");	
	dialBar = newArray("Composite", "All channels", "Channel 1: " + flCh1, "Channel 2: " + flCh2, "Channel 3: " + flCh3);	
	Dialog.create("SPLIT AND MERGE V3.2 - IMAGE SETTINGS");
	Dialog.addMessage("SUBTRACT BACKGROUND");
	Dialog.addChoice("Subtract background for channels: ", dialBackground, dialBackground[4]);
	Dialog.addMessage(" ");
	Dialog.addMessage("CROP IMAGE");
	Dialog.addChoice("Do you want to crop this Image?", dialCrop, dialCrop[0]);
	Dialog.addMessage(" ");
	Dialog.addMessage("SCALE BAR");
	Dialog.addChoice("Add scale bar to channels:", dialBar, dialBar[0]);
	Dialog.addNumber("Scale bar length:", 10);
	Dialog.addCheckbox("Insert unit", true);
	Dialog.addMessage(" ");
	Dialog.addMessage("FIGURE MONTAGE");
	Dialog.addCheckbox("Create figure montage", true);
	Dialog.addMessage(" ");
	Dialog.show();
	answerBackground = Dialog.getChoice();			
	answerCrop = Dialog.getChoice();
	answerBar = Dialog.getChoice();		//array to choose in which windows a scale bar should be inserted
	barLength = Dialog.getNumber();		//dialog to get the scale bar length in number
	unitNumber = Dialog.getCheckbox();	//checkbox for adding microns number into scale bar	
	answerMontage = Dialog.getCheckbox();
}	


/*	
-------------------------------------------------------------------------------------------------- 
SUBTRACT BACKGROUND
* dialog for background correction
* subtract background for individual channels or all channels
-------------------------------------------------------------------------------------------------- 
*/ 
	
	if (noCh==2) {
		if (answerBackground==dialBackground[0])	{
			selectWindow(originalImage);
			setSlice(1);
			run("Subtract Background...");
			print("Background subtracted for channel 1: " + flCh1);
		}
	if (answerBackground==dialBackground[1])	{
		selectWindow(originalImage);
		setSlice(2);
		run("Subtract Background...");
		print("Background subtracted for channel 2: " + flCh2);
		}
	if (answerBackground==dialBackground[2])	{
		selectWindow(originalImage);
		setSlice(1);
		run("Subtract Background...");
		setSlice(2);
		run("Subtract Background...");
		print("Background subtracted for channels 1, 2: " + flCh1 +", " + flCh2);
		}
	if (answerBackground==dialBackground[3])	{
		print("No background subtraction selected.");		
		}
	}
	if (noCh==3) {
		if (answerBackground==dialBackground[0])	{
			selectWindow(originalImage);
			setSlice(1);
			run("Subtract Background...");
			print("Background subtracted for channel 1: " + flCh1);
		}
		if (answerBackground==dialBackground[1])	{
			selectWindow(originalImage);
			setSlice(2);
			run("Subtract Background...");
			print("Background subtracted for channel 2: " + flCh2);
		}
		if (answerBackground==dialBackground[2])	{
			selectWindow(originalImage);
			setSlice(3);
			run("Subtract Background...");
			print("Background subtracted for channel 3: " + flCh3);
		}
		if (answerBackground==dialBackground[3])	{
			selectWindow(originalImage);
			setSlice(1);
			run("Subtract Background...");
			setSlice(2);
			run("Subtract Background...");
			setSlice(3);
			run("Subtract Background...");
			print("Background subtracted for channels 1, 2, 3: " + flCh1 +", " + flCh2 +", " + flCh3);
		}
		if (answerBackground==dialBackground[4])	{
			print("No background subtraction selected.");		
		}	
	}
	
/*
--------------------------------------------------------------------------------------------------  
CROP IMAGE
* select area to crop the image
* load previously saved selection
---------------------------------------------------------------------------------------------------
*/

scrW = screenWidth;
scrH = screenHeight;
scrHROI = scrW/2;
scrWROI = scrH/3;
getLocationAndSize(x1, y1, width, height);
if(answerCrop==dialCrop[0]) {
	run("ROI Manager...");
	selectWindow("ROI Manager");
	setLocation(scrHROI, scrWROI);
	waitForUser(" Please select a new selection \nor move an existing selection \n      to a region of interest");
	selectWindow(originalImage);		
	roiManager("Add");
	roiNo = roiManager("Count");
	roiManager("select", roiNo-1);
	roiManager("Rename", "selectedROI" + roiNo);	
	selectWindow(originalImage);
	run("Crop");
	imageH = getHeight;
	imageW = getWidth;
	print("Image cropped. New Image size in pixels: " +imageW + " x " + imageH);
  	}
if(answerCrop==dialCrop[1]) {
	selectWindow(originalImage);
	run("ROI Manager...");
	selectWindow("ROI Manager");
	setLocation(scrHROI, scrWROI);
	roiManager("Open", "");
	waitForUser("   Please select an area of \ninterest with you loaded ROI");
	roiManager("Add");
	roiNo = roiManager("Count");
	roiManager("select", roiNo-1);
	roiManager("Rename", "selectedROI" + roiNo);
  	selectWindow(originalImage);
	roiManager("select", roiNo-1);
	run("Crop");
	imageH = getHeight;
	imageW = getWidth;
	print("Image cropped. New image size in pixels: " + imageW + " x " + imageH);	
	}
if(answerCrop==dialCrop[2]) {
	imageH = getHeight;
	imageW = getWidth;
	print("No cropping selected. Original image size in pixels: " + imageW + " x " + imageH);
	}

/*
--------------------------------------------------------------------------------------------------  
SCALE BAR INSERTION
* adjusting image size to scale bar width
* automatically adjusts the scale bar width and fonts according to the image size
--------------------------------------------------------------------------------------------------  
*/

selectWindow(originalImage);
run("RGB Color");
rename("Channels_RGB_" + originalImage);
imageRGB = getTitle();
selectWindow(originalImage);
run("Make Composite");
run("RGB Color");
rename("Composite_RGB_" + originalImage);
imageCompositeRGB = getTitle();
selectWindow(originalImage);
run("Close");

/*
--------------------------------------------------------------------------------------------------  
SCALE BAR INSERTION
* adjusting image size to scale bar width
* automatically adjusts the scale bar width and fonts according to the image size
--------------------------------------------------------------------------------------------------  
*/

if (imageW<=256) {
	barWidth = 4;
	barFont = 16;
}
if ((imageW<=512) && (imageW>256)) {
	barWidth = 5;
	barFont = 18;
}
if ((imageW<=1024) && (imageW>512)) {
	barWidth = 6;
	barFont = 20;
}
if ((imageW>=1024)) {
	barWidth = 8;
	barFont = 22;
}
print("Adjusted scale bar width: " +barWidth);
print("Adjusted scale bar fonts: " +barFont); 

if (unitNumber==true) {		//in case user wishes to add the microns number into scale bar 
	unitChoice = "";
	} 
if (unitNumber==false) {
	unitChoice = "hide";
	}
		
	if (answerBar==dialBar[0]) {	
		selectWindow(imageCompositeRGB);
		run("Scale Bar...", "width=barLength height=barWidth font=barFont color=White background=None location=[Lower Right] bold "+unitChoice+"");
		print("Scale bar inserted in " +dialBar[0]+ ", scale bar length: " +barLength);
	}
	if (answerBar==dialBar[1]) {	
		selectWindow(imageRGB);
		run("Scale Bar...", "width=barLength height=barWidth font=barFont color=White background=None location=[Lower Right] bold "+unitChoice+" label");
		selectWindow(imageCompositeRGB);
		run("Scale Bar...", "width=barLength height=barWidth font=barFont color=White background=None location=[Lower Right] "+unitChoice+" bold");
		print("Scale bar inserted in " +dialBar[1]+ ", scale bar length: " +barLength);
	}
	if (answerBar==dialBar[2]) {	
		selectWindow(imageRGB);
		setSlice(1);
		run("Scale Bar...", "width=barLength height=barWidth font=barFont color=White background=None location=[Lower Right] "+unitChoice+" bold");
		print("Scale bar inserted in " +dialBar[1]+ ", scale bar length: " +barLength);
	}
	if (answerBar==dialBar[3]) {	
		selectWindow(imageRGB);
		setSlice(2);
		run("Scale Bar...", "width=barLength height=barWidth font=barFont color=White background=None location=[Lower Right] "+unitChoice+" bold");
		print("Scale bar inserted in " +dialBar[2]+ ", scale bar length: " +barLength);
	}
	if (noCh==3) {
		if (answerBar==dialBar[4]) {	
			selectWindow(imageRGB);
			setSlice(3);
			run("Scale Bar...", "width=barLength height=barWidth font=barFont color=White background=None location=[Lower Right] "+unitChoice+" bold");
			print("Scale bar inserted in " +dialBar[3]+ ", scale bar length: " +barLength);
		}
	}
/*
--------------------------------------------------------------------------------------------------  
SPLITTING AND MERGING CHANNELS
* generating single channel images
* set locations of the images to the center of the screen
--------------------------------------------------------------------------------------------------  
*/

scrW = screenWidth;
scrH = screenHeight;
normScrW = scrW/8;
normScrH = scrH/8;
getLocationAndSize(x, y, width, height);
selectWindow(imageRGB);
run("Duplicate...", "title=[Channel1_"+originalImage+"] duplicate range=1-1");
imageCh1 = "Channel1_" + originalImage;
selectWindow(imageRGB);
run("Duplicate...", "title=[Channel2_"+originalImage+"] duplicate range=2-2");
imageCh2 = "Channel2_" + originalImage;
if (noCh==3) {
	selectWindow(imageRGB);
	run("Duplicate...", "title=[Channel3_"+originalImage+"] duplicate range=3-3");
	imageCh3 = "Channel3_" + originalImage;  
	}
selectWindow(imageRGB);
run("Close");	
print("Merging channels.");

list = getList("image.titles"); 
	selectWindow(list[0]);
	run("Out [-]");
	setLocation((2*normScrW), (0.6*normScrH));

	selectWindow(list[1]);
	run("Out [-]");
	setLocation((3.9*normScrW), (3.8*normScrH));
	
	selectWindow(list[2]);
	run("Out [-]");
	setLocation((2*normScrW), (3.8*normScrH));
if (noCh==3) {
	selectWindow(list[3]);
	run("Out [-]");
	setLocation((3.9*normScrW), (0.6*normScrH));
}

/*
--------------------------------------------------------------------------------------------------  
SAVING IMAGES
* saving all single channel and composite images in the Results directory
--------------------------------------------------------------------------------------------------  
*/
print("Saving images to: ");
print(splitDir);
selectWindow(imageCh1);
saveAs("tiff", splitDir + imageCh1);
selectWindow(imageCh2);
saveAs("tiff", splitDir + imageCh2);
if (noCh==3) {
	selectWindow(imageCh3);
	saveAs("tiff", splitDir + imageCh3);
}
selectWindow(imageCompositeRGB);
saveAs("tiff", splitDir + imageCompositeRGB);
roiNo = roiManager("Count");
if (roiNo>=1) {
	roiManager("Save", splitDir + "ROI_" + fileNameWithoutExtension + ".zip");
}

/*
--------------------------------------------------------------------------------------------------  
FIGURE MONTAGE
* generating a new image according to number of channels
* horizontal reorder of channels
* adds single channel images and composite to a new montage figure
--------------------------------------------------------------------------------------------------  
*/

if (answerMontage==true) {
	if (noCh==2) {
		dialMontage = newArray("Channel 1 " + flCh1, "Channel 2 " + flCh2, "Composite");
	}
	if (noCh==3) {
		dialMontage = newArray("Channel 1 " + flCh1, "Channel 2 " + flCh2, "Channel 3 " + flCh3, "Composite");
	}
	Dialog.create("FIGURE SETTINGS");
	Dialog.addMessage("                MONTAGE ORDER");
	Dialog.addMessage(" ");
	Dialog.addChoice("Image 1:", dialMontage, dialMontage[0]);
	Dialog.addChoice("Image 2:", dialMontage, dialMontage[1]);
	Dialog.addChoice("Image 3:", dialMontage, dialMontage[2]);
	if (noCh==3) {
		Dialog.addChoice("Image 4:", dialMontage, dialMontage[3]);
	}
	Dialog.show();
	answerImage1 = Dialog.getChoice();
	answerImage2 = Dialog.getChoice();
	answerImage3 = Dialog.getChoice();
	if (noCh==3) {
		answerImage4 = Dialog.getChoice();
	}
	print("Creating figure montage.");
	spacerDistance = imageW / 55;
	montageW = (imageW * (noCh+1)) + (spacerDistance * (noCh+2));
	montageH = imageH + (spacerDistance * 2);
	newImage("Figure Montage", "RGB", montageW, montageH, 1);
	list = getList("image.titles");
	if (noCh==2) {
		sortedList = newArray(list[1], list[2], list[0]);
	}
	if (noCh==3) {
		sortedList = newArray(list[1], list[2], list[3], list[0]);
	}
	for (i=0; i<sortedList.length; i++) {
		if (answerImage1==dialMontage[i]) {
			selectWindow(sortedList[i]);
	  		run("Copy");
			selectWindow("Figure Montage");
			makeRectangle(spacerDistance, spacerDistance, imageW, imageH);
			run("Paste");
			}
		if (answerImage2==dialMontage[i]) {
			selectWindow(sortedList[i]);
	  		run("Copy");
			selectWindow("Figure Montage");
			makeRectangle((imageW*1+spacerDistance*2), spacerDistance, imageW, imageH);
			run("Paste");
			}
		if (answerImage3==dialMontage[i]) {
			selectWindow(sortedList[i]);
	  		run("Copy");
			selectWindow("Figure Montage");
			makeRectangle((imageW*2+spacerDistance*3), spacerDistance, imageW, imageH);	
			run("Paste");
			}
		if (noCh==3) {	
			if (answerImage4==dialMontage[i]) {
				selectWindow(sortedList[i]);
		  		run("Copy");
				selectWindow("Figure Montage");
				makeRectangle((imageW*3+spacerDistance*4), spacerDistance, imageW, imageH);
				run("Paste");			
			}
		}
	}
	print("Saving figure montage to: ");
	print(splitDir);
	selectWindow("Figure Montage");
	saveAs("tiff", splitDir + "Figure Montage_" + fileNameWithoutExtension);
	run("Out [-]");
	setLocation((1.7*normScrW), (2.25*normScrH));
}
