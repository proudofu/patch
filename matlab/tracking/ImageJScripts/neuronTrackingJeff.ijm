// SmallArena GCaMP Tracking 
// Dirk Albrecht, Johannes Larsch 
//March, 2013 
//improved by Jeff Rhoades, February 2017
 
 
macro "NeuronTracking [t]" { 
 
 
// Track setting Defaults are read from txt file 
//TrackSettingfile="D:\\TrckSett_awa_2p5x_4pxSqcMOS.txt"; 
 
//TrackSettingfile="D:\\TrckSett_aia_5x_6pxSq_2013.txt"; 
//TrackSettingfile="D:\\TrckSett_awa_2p5x_4pxSqMoving_b.txt"; 
//TrackSettingfile="/Applications/Fiji.app/plugins/Macros/TrckSett_awa_2p5x_4pxSqMoving_b.txt";
TrackSettingfile="/Users/jeff/Dropbox (MIT)/Jeffs Matland/ImageJScripts/TrckSett_awa_2p5x_4pxSqMoving_b.txt";
//TrackSettingfile="C:\\Users\\jeff\\Desktop\\Fiji.app\\plugins\\Macros\\TrckSett_awa_2p5x_4pxSqMoving_b.txt"; 
 
 
TrckSttng=newArray(25); 
TrckSttng=ReadSettings(TrckSttng,TrackSettingfile); 
 
animal = TrckSttng[0]; 
lower=TrckSttng[1];	//threshold 
upper=65535; 		//threshold  
h = TrckSttng[2];	//height of search window for tracking 
w = TrckSttng[3];	//whidth of search window for tracking 
 
sqsize = TrckSttng[4];	//size of square for intensity measurement of neuron 
maxsize = TrckSttng[5];	//upper limit of particle size for tracking 
minsize = TrckSttng[6];	//lower limit of particle size for tracking 
expandAllow=TrckSttng[7]; //limit of allowed expansion of search window for tracking 
 
offsetx = -1*(2*w); 
offsety = -1*(2*h); 
 
 
// Default variables. not relevant for tracking function 
 
FrameForNeuronClick=1; // choose a frame when fluorescence is expected high to fascilitate neuron selection 
ThresholdDefaultMin=1290; 
ThresholdDefaultMax=65535; 
animalThreshold = newArray(25); // array of animal specific lower thresholds 
trackFolder=0; //1: track folder; 0: track open file 
 
 
//------------------------------------------------- 
 
// check if images open. 
// if images open, track single movie. 
// else, ask for directory for batch tracking 
 
 
//dir="e:\\f\\20121127_awa_doseResp_n2upVsChe2dn\\"; 
//dir="I:\\20130830_01_kyIs587N2_vs_KyIs587arr1_doseResponse\\"; 

	
if (nImages()==0){ 
 	Dialog.create("Made it this far." + nImages()); 
	Dialog.show();
	wait(500);
 	
 	dir = getDirectory("choose a fucking directory for stationary tracking"); 

	trackFolder=1; 
 
	list = getFileList(dir); 
	newlist = newArray(list.length); 
	k=0; 
	for (i=0; i < list.length; i++)  { 
		if (endsWith(list[i], ".tif")) { 
			newlist[k] = list[i]; 
			k++; 
		} 
	} 
	 
	list = Array.trim(newlist, k); 
 
	startFile=getNumber("found "+list.length+" files, at what movie do you want to start tracking?", 1); 
	startFile=startFile-1; 
	endFile=getNumber("found "+list.length+" files, at what movie do you want to end tracking?", list.length); 
	endFile=endFile-1; 
 
	open(dir + list[startFile]); 
	if (getVersion>="1.37r") setOption("DisablePopupMenu", true); 
	 
}else{ 
	if (getVersion>="1.37r") setOption("DisablePopupMenu", true); 
	trackFolder=0; 
// continue single movie tracking 
} 
 
 
 
// get neuron coordinates. either from position file or via manual selection 
// if position files are found, ask if they should be used 
// there are 2 types of position files 
// 'PosFile' has positions in movie that was last tracked in current folder 
// 'moviePosFile' is created for each movie during tracking 
 
mainid = getImageID(); 
title = getTitle(); 
titleNoExt=substring(title,0,lengthOf(title)); 
 
dir = getDirectory("image"); 
pathnoext = dir+substring(title,0,lengthOf(title)); 
 
//setSlice(FrameForNeuronClick); 
run("Select None"); 
setThreshold(ThresholdDefaultMin, ThresholdDefaultMax); 
updateDisplay(); 
 
useSavedPos ="no"; 
useSavedmoviePos ="no"; 
 
moviePosFile = dir+titleNoExt+"_Pos.txt"; 
PosFile=dir+"initialPos.txt"; 
 
if (File.exists(moviePosFile)==1){ 
 
  	Dialog.create("Positions found for current movie"); 
	Dialog.addChoice("Use saved Positions", newArray("yes", "no")); 
	Dialog.show(); 
  	useSavedmoviePos = Dialog.getChoice(); 
} 
 
if (File.exists(PosFile)==1){ 
	Dialog.create("Positions found for current folder"); 
	Dialog.addChoice("Use saved Positions", newArray("yes", "no")); 
	Dialog.show(); 
	useSavedPos = Dialog.getChoice(); 
} 
 
if (useSavedmoviePos=="yes"){ 
	readfile=moviePosFile; 
}else if (useSavedPos=="yes") { 
	readfile=PosFile; 
}else{ 
	readfile="none"; 
} 
 
 
// read animal info from position file 
 
if (readfile!="none"){  
 
	xpAll=ReadAnimalInfo(readfile,"x","y"); 
	ypAll=ReadAnimalInfo(readfile,"y","a"); 
	animalThreshold=ReadAnimalInfo(readfile,"t","f"); 
	redFlag=ReadAnimalInfo(readfile,"f","g"); 
	useTracking=ReadAnimalInfo(readfile,"g","end"); 
 
//temporarily draw rectangles on neuron positions 
 
	for (animal=0; (animal<xpAll.length); animal++) { 
		xc=xpAll[animal];  
		yc=ypAll[animal]; 
		makeRectangle(xc - sqsize/2, yc - sqsize/2, sqsize, sqsize); 
		run("Add Selection...", "stroke=yellow width=1 fill=0"); 
		print("x",xc,"y",yc,"a",animal,"t",animalThreshold[animal],"f",redFlag[animal],"g",useTracking[animal]); 
	} 
animal++; 
firstAnimal=0; 
} 
 
//get neuron positions manually if no posFiles found or not wanted 
else{ 
	// get all neuron positions by manual selection 
	xpAll = newArray(100); 
	ypAll = newArray(100); 
	redFlag=newArray(100); 
	useTracking=newArray(100); 
	doneWithPicking=0; 
 
	// how many animals have been tracked for this movie already?(an#.txt files) 
 
	firstAnimal=-1; 
	do { 
		firstAnimal++; 
		logname = pathnoext+".an"+firstAnimal+".txt"; 
	} while (File.exists(logname)); 
 
	for (animal=firstAnimal; !doneWithPicking; animal++) { 
		showStatus("Select center point of the neuron:");  
 
		do{ 
			updateDisplay(); 
			getCursorLoc(xc, yc, z, flags); 
			doneWithPicking= (flags==4); 
			getThreshold(lower, upper); 
			animalThreshold[animal] = lower; 
			wait(50); 
			a=(flags != 16); 
			b=!doneWithPicking; 
			c=a && b; 
		} while (c); 
		redFlag[animal]=0; 
		useTracking[animal]=1; 
		xpAll[animal] = xc; ypAll[animal] = yc; 
		if(b) print("x",xc,"y",yc,"a",animal,"t",lower,"f",0,"g",1); 
		slice = getSliceNumber(); 
		wait(1000); 
	} 
} 
 
selectWindow(title);  
 
 
if (trackFolder==1){ 
 
AnimalsToTrack=animal-1;  
close(); 
 
 
for (i=startFile; i<=endFile; i++) { //start with early movies 
   
	open(dir + list[i]); 
	title = getTitle();  
	titleNoExt=substring(title,0,lengthOf(title));    
	moviePosFile = dir+titleNoExt+"_Pos.txt"; 
 
  script = 
    "lw = WindowManager.getFrame('"+title+"');\n"+ 
    "if (lw!=null) {\n"+ 
    "   lw.setLocation(20,20);\n"+ 
    "}\n"; 
  eval("script", script);  
 
  script = 
    "lw = WindowManager.getFrame('Log');\n"+ 
    "if (lw!=null) {\n"+ 
    "   lw.setLocation(10,800);\n"+ 
    "   lw.setSize(800, 200)\n"+ 
    "}\n"; 
  eval("script", script);  
 
// save previous neuron endPositions 
// save to initialPos.txt and file specific moviePos.txt 
 
	selectWindow("Log");	 
	print("\\Clear"); 
	for (animal=firstAnimal; animal<AnimalsToTrack; animal++) { 
		print("x",xpAll[animal],"y",ypAll[animal],"a",animal,"t",animalThreshold[animal],"f",redFlag[animal],"g",useTracking[animal]); 
	} 
 
 
	selectWindow("Log"); 
	wait(150); //for some reason, needs long dealy here to work 
	selectWindow("Log"); 
	wait(150); 
	saveAs("Text",PosFile); 
	selectWindow("Log"); 
	wait(150); 
	selectWindow("Log"); 
	wait(150); 
	saveAs("Text",moviePosFile); 
	print("\\Clear"); 
 
	selectWindow(title);  
 
	updateDisplay(); 
 
	for (animal=firstAnimal; animal<AnimalsToTrack; animal++) { 
		setThreshold(animalThreshold[animal], upper); 
		updateDisplay(); 
		xc = xpAll[animal];  
		yc = ypAll[animal]; 
		 
		// update TrckSttng variable with info for this animal before calling the tracker 
		TrckSttng[1]= animal; 
		TrckSttng[2]=animalThreshold[animal]; 
		TrckSttng[3]=h; 
		TrckSttng[4]=w; 
		TrckSttng[5]=offsetx; 
		TrckSttng[6]=offsety; 
		TrckSttng[7]=sqsize; 
		TrckSttng[8]=maxsize; 
		TrckSttng[9]=minsize; 
		TrckSttng[10]=expandAllow; 
		TrckSttng[11]=xc; 
		TrckSttng[12]=yc; 
		TrckSttng[14]=redFlag[animal]; 
		TrckSttng[15]=useTracking[animal]; 
 
 
		//setSlice(1); 
		TrckSttng=SmallArenaTrackerBatch(TrckSttng); 
		lower=TrckSttng[2]; 
		xc=TrckSttng[11]; 
		yc=TrckSttng[12]; 
		redFlag[animal]=TrckSttng[14]; 
		useTracking[animal]=TrckSttng[15]; 
		animalThreshold[animal] = lower; 
		xpAll[animal] = xc; ypAll[animal] = yc; 
		print(xc,yc); 
	} 
	selectWindow(title); close(); 
	animal=0; 
 
}} 
 
		if (trackFolder==0){ 
		//animal=0; 
		xc = xpAll[animal];  
		yc = ypAll[animal]; 
		getThreshold(lower, upper); 
		animalThreshold[animal] = lower; 
		// update TrckSttng variable with info for this animal before calling the tracker 
		TrckSttng[1]= animal; 
		TrckSttng[2]=animalThreshold[animal]; 
		TrckSttng[3]=h; 
		TrckSttng[4]=w; 
		TrckSttng[5]=offsetx; 
		TrckSttng[6]=offsety; 
		TrckSttng[7]=sqsize; 
		TrckSttng[8]=maxsize; 
		TrckSttng[9]=minsize; 
		TrckSttng[10]=expandAllow; 
		TrckSttng[11]=xc; 
		TrckSttng[12]=yc; 
		TrckSttng[14]=0; 
		//TrckSttng[15]=useTracking; 
		TrckSttng[15]=1; 
		//setSlice(1); 
 
		selectWindow("Log"); 
		print("start tracking"); 
		TrckSttng=SmallArenaTrackerBatch(TrckSttng); 
 
} 
 
 
} //end macro NeuronTracking [t] 
 
//-----------------------------------------------------------------------s 
 
 
function ReadSettings(TrckSttng,file){ 
//file="D:\\TrckSett_awa_2p5x_4pxSq.txt" 
string = File.openAsString(file); 
xlines = split(string, "\n"); 
n_xlines = lengthOf(xlines); 
 
for (n=0; n<n_xlines; n++) 
    { 
    TrckSttng[n] = substring(xlines[n],0,indexOf(xlines[n],"//")-1); 
    } 

//print("\\Clear");
return TrckSttng; 
} 
 
//----------------------------------------------------------------------- 
 
function ReadAnimalInfo(PosFile,ID1,ID2){ 
 
string = File.openAsString(PosFile); 
lines = split(string, "\n"); 
n_lines = lengthOf(lines); 
AnimalInfo=newArray(n_lines); 
 
for (n=0; n<n_lines; n++) 
	{ 
	if (ID2=="end"){ 
		AnimalInfo[n] = substring(lines[n],indexOf(lines[n],ID1)+2); 
	}else{ 
    		AnimalInfo[n] = substring(lines[n],indexOf(lines[n],ID1)+2,indexOf(lines[n],ID2)-1); 
	} 
 
} 
 
return AnimalInfo; 
} 
 
 
 
//------------------------------------------------------- 
 
 
function SmallArenaTrackerBatch(TrckSttng){ 
// this version of the tracker can be called once the neuron positions are known 
 
animal=TrckSttng[1]; 
lower=TrckSttng[2]; 
h=TrckSttng[3]; 
w=TrckSttng[4]; 
offsetx=TrckSttng[5]; 
offsety=TrckSttng[6]; 
sqsize=TrckSttng[7]; 
maxsize=TrckSttng[8]; 
minsize=TrckSttng[9]; 
expandallow=TrckSttng[10]; 
xc=TrckSttng[11]; 
yc=TrckSttng[12]; 
redFlag=TrckSttng[14]; 
useTracking=TrckSttng[15]; 
 
print(xc,yc); 
 
// Go to beginning of stack 
 
 
mainid = getImageID(); 
title = getTitle(); 
dir = getDirectory("image"); 
pathnoext = dir+substring(title,0,lengthOf(title)); 
 
 
// Initialize variables 
area = 0; maxint = 0; intdens = 0; x = xc; y = yc; intsub = 0; sqintdens =0; sqintsub =0; sqarea = 0; avg = 0; dx = 0; dy = 0; 
X = newArray(nSlices); 
Y = newArray(nSlices); 
Int1 = newArray(nSlices); 
Int2 = newArray(nSlices); 
BgMed = newArray(nSlices); 
Avg = newArray(nSlices); 
xp = xc; yp = yc; 

velFactor = 0.75;
threshAllow = 40;
threshSearchBoxScale = 0.25;
 
 
searchBoxScale=0.5; //##########################################################################################################################################################################
 
print("\\Clear"); 
print("Slice,xc,yc,intdens,intsub,bgmedian,maxint,area,x,y,sqintdens,sqintsub,sqarea,threshold,animal,redFlag,useTracking"); 
 
selectWindow(title); 
setThreshold(lower, 65535); 
 start = getSliceNumber();

for (slice = start; slice<=nSlices; slice++)  { 
 
	 
setSlice(slice); 
 
// Allow manual pausing via spacebar 
 
anyKeyDown=isKeyDown("space") || isKeyDown("shift") || isKeyDown("alt") || anyKeyDown; //avoiding if statements in loop 
if(anyKeyDown){ 
 
	if (isKeyDown("space")) { 
		showStatus("Select center point of the neuron:");  
		do { 
			getCursorLoc(xc, yc, z, flags); 
			wait(50); 
		} while (flags != 16); 
		xp = xc; yp = yc; 
		slice = getSliceNumber(); 
			// Remove upper threshold limit 
			getThreshold(lower, upper); 
			wait(100); 
			//auto change threshold
			thresh = threshAllow;
			do {	
				thresh--;
				setThreshold(lower+thresh, 65535);
				makeOval(xc - threshSearchBoxScale*w, yc - threshSearchBoxScale*h, threshSearchBoxScale*2*w, threshSearchBoxScale*2*h);
				run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity=0.00-1.00 show=Nothing display clear slice");
			} while ((nResults != 1) && (thresh >= -threshAllow));
			if (nResults == 1) {
				lower = lower + thresh;
			}
	} 
 
	// Allow stationary tracking via 'shift' toggle 
	if (isKeyDown("shift")) { 
		if (useTracking == 0) { 
			wait(400); 
			useTracking=1; 
		 
		}else if (useTracking == 1) { 
			wait(400); 
			useTracking=0; 
		} 
 
	} 
 
	//Allow flagging via 'alt' 
	if (isKeyDown("alt")) { 
		if (redFlag == 0) { 
			wait(400); 
			redFlag=1; 
		} 
		else if (redFlag == 1) { 
			wait(400); 
			redFlag=0; 
		} 
 
	} 
 	
	anyKeyDown=0;
} 
 
	 
 
 
	if (useTracking == 1) { 
 
	makeOval(xc - searchBoxScale*w, yc - searchBoxScale*h, w, h); 
	 
	run("Set Measurements...", "area min centroid center integrated slice limit redirect=None decimal=1"); 
	//run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity=0.00-1.00 show=Nothing display exclude clear slice"); 
	run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity=0.00-1.00 show=Nothing display clear slice"); 
 
	if (nResults == 1) { 
		xc = getResult("XM", 0); 
		yc = getResult("YM", 0); 
		area = getResult("Area", 0); 
		maxint = getResult("Max", 0); 
		intdens = getResult("IntDen", 0); 
		x = getResult("X", 0); 
		y = getResult("Y", 0); 
		avg = intdens / area; 
	} else if (nResults > 1) { 
		biggestArea = 0; 
		for (res=0; res<nResults; res++) { 
			resArea = getResult("Area", res); 
			if (resArea > biggestArea) { 
				biggestArea = resArea; 
				biggestAreaPos = res; 
			} 
		} 
 
		xc = getResult("XM", biggestAreaPos ); 
		yc = getResult("YM", biggestAreaPos ); 
		area = getResult("Area", biggestAreaPos ); 
		maxint = getResult("Max", biggestAreaPos ); 
		intdens = getResult("IntDen", biggestAreaPos ); 
		x = getResult("X", biggestAreaPos ); 
		y = getResult("Y", biggestAreaPos ); 
		avg = intdens / area; 
	} else { 
		expand = 0; 
		do {	 
			expand++; 
			makeOval(xc - searchBoxScale*w - expand, yc - searchBoxScale*h - expand, w+2*expand, h+2*expand); 
			//run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity=0.00-1.00 show=Nothing display exclude clear slice"); 
			run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity=0.00-1.00 show=Nothing display clear slice"); 
			anyKeyDown=isKeyDown("space") || isKeyDown("shift") || isKeyDown("alt") || anyKeyDown;
		} while ((nResults < 1) && (expand <= expandAllow) && !anyKeyDown); 
		if (nResults == 1) { 
			xc = getResult("XM", 0); 
			yc = getResult("YM", 0); 
			area = getResult("Area", 0); 
			maxint = getResult("Max", 0); 
			intdens = getResult("IntDen", 0); 
			x = getResult("X", 0); 
			y = getResult("Y", 0); 
			avg = intdens / area; 
		} else if (nResults > 1) { 		
			thresh = threshAllow;
			do {	
				thresh--;
				setThreshold(lower+thresh, 65535);
				makeOval(xc - threshSearchBoxScale*w, yc - threshSearchBoxScale*h, threshSearchBoxScale*2*w, threshSearchBoxScale*2*h);
				run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity=0.00-1.00 show=Nothing display clear slice");
				anyKeyDown=isKeyDown("space") || isKeyDown("shift") || isKeyDown("alt") || anyKeyDown;
			} while ((nResults != 1) && (thresh >= -threshAllow) && !anyKeyDown);
			if (nResults == 1) {
				lower = lower + thresh;
				xp = xc; yp = yc;
				slice = getSliceNumber();
			} else {
				makeRectangle(xc - sqsize/2, yc - sqsize/2, sqsize, sqsize); 
				showStatus("Select center point of the neuron:");  
				do { 
					getCursorLoc(xc, yc, z, flags); 
					wait(50); 
				} while (flags != 16); 
				xp = xc; yp = yc; 
				slice = getSliceNumber(); 
	 
				// Remove upper threshold limit 
				getThreshold(lower, upper); 
				wait(100); 
				//auto change threshold
				thresh = threshAllow;
				do {	
					thresh--;
					setThreshold(lower+thresh, 65535);
					makeOval(xc - threshSearchBoxScale*w, yc - threshSearchBoxScale*h, threshSearchBoxScale*2*w, threshSearchBoxScale*2*h);
					run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity=0.00-1.00 show=Nothing display clear slice");
				} while ((nResults != 1) && (thresh >= -threshAllow));
				if (nResults == 1) {
					lower = lower + thresh;
				}
			}
		} 
	} 
	} 
 
	// set small region around neuron center 
	makeRectangle(xc - sqsize/2, yc - sqsize/2, sqsize, sqsize); 
	run("Clear Results"); 
	setThreshold(lower, 65535); 
	run("Set Measurements...", "area min centroid center integrated slice redirect=None decimal=1"); 
	run("Measure"); 
	if (nResults == 1) { 
		sqarea = getResult("Area", 0); 
		sqintdens = getResult("IntDen", 0); 
	} 
	run("Add Selection...", "stroke=yellow width=1 fill=0"); 
	Overlay.setPosition(slice); 
 
	// get background 
	//makeOval(xc - 0.5*w + offsetx, yc - 0.5*h + offsety, w, h); 
	makeOval(xc - 1.2*w, yc - 1.2*h, 2.4*w, 2.4*h); 
	setKeyDown("alt"); 
	makeOval(xc - 0.7*w, yc - 0.7*h, 1.4*w, 1.4*h); 
 
	run("Clear Results"); 
	run("Set Measurements...", "area mean min median slice redirect=None decimal=1"); 
	run("Measure"); 
	if (nResults == 1) { 
		bgavg = getResult("Mean", 0); 
		bgmedian = getResult("Median", 0); 
		intsub = intdens - (area * bgmedian); 
		sqintsub = sqintdens - (sqarea * bgmedian); 
	} 
 
	print(slice+","+xc+","+yc+","+intdens+","+intsub+","+bgmedian+","+maxint+","+area+","+x+","+y+","+sqintdens+","+sqintsub+","+sqarea+","+lower+","+animal+","+redFlag+","+useTracking); 
	 
	X[slice-1]=xc; 
	Y[slice-1]=yc; 
	Int1[slice-1]=intsub; 
	Int2[slice-1]=sqintsub; 
	BgMed[slice-1]=bgmedian; 
	Avg[slice-1]=avg; 
	 
	//Velocity prediction 
	if (slice >= 2) {
		dx = xc-X[slice-2]; dy = yc-Y[slice-2];
		xc = xc + dx*velFactor; yc = yc + dy*velFactor;
	}
	
	//xp = xc; yp = yc; 
	
} //End tracking step
 
 
 
        Plot.create("Position", "Frame", "Pixels", X); 
        Plot.setLimits(0, nSlices, 0, 512); 
        Plot.setColor("red"); 
        Plot.add("line", Y); 
        Plot.setColor("blue"); 
 
 
	Plot.create("Integrated intensity", "Frame", "Sq. Intensity", Int2); 
 
        Plot.show(); 
	setLocation(5, 400); 
 
	selectWindow("Log"); 
	logname = pathnoext+".an"+animal+".txt"; 
 
	action = ""; 
	if (!File.exists(logname)){ 
		wait(50); 
		selectWindow("Log"); 
		wait(150); 
		selectWindow("Log"); 
		wait(150); 
		saveAs("Text",logname); 
	}else { 
		Dialog.create("Log file already exists"); 
		Dialog.addChoice("Choose:", newArray("Overwrite", "New Animal")); 
		Dialog.show(); 
		action = Dialog.getChoice(); 
		if (action!="Overwrite") { 
			do { 
			animal++; 
			logname = pathnoext+".an"+animal+".txt"; 
			} while (File.exists(logname)); 
		} 
		selectWindow("Log"); 
		 
		wait(150); 
		selectWindow("Log"); 
		wait(150); 
		saveAs("Text",logname); 
	} 
	print(action); 
	print("Saved to logfile: "+logname); 
	selectWindow("Integrated intensity"); 
		wait(100); 
close(); 
	 
	selectWindow(title); 
 
TrckSttng[2]=lower; 
TrckSttng[11]=xc; 
TrckSttng[12]=yc; 
 
TrckSttng[14]=redFlag; 
TrckSttng[15]=useTracking; 
 
return TrckSttng; 
 
} // end function SmallArenaTracker 
