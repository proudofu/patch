% Takes a folder, finds finalTracks files within the embedded folders, 
% calculates the HMM for these data, finds the animals that were within the ROI 
% at appropriate times and gives back data in matrix form, where each line
% is a single time that an animal was hit with the LED:

% column 1: track number (i.e. anim #);
% column 2: stimulus numb (e.g. 5th of out of 6 stim)
% column 3: average state for the minute before the light was illuminated
% column 4: average state for the minute after the light is shut off
% columns 5-814: speed over t = -2min, 30sec pulse, +2min (4.5 min total)
% columns 815-1624: angspeed over this time
% columns 1625-2434: state calls over this time



function AllChOPHits = summarizeChOPdata_SvF(folder,stimulusfile,ROImovie,DirofChange)  %%%DirofChange=1 if expect R->D; DirofChange=2 if expect D-R
    PathofFolder = sprintf('%s',folder);
    
    dirList = ls(PathofFolder);
    
    NumFolders = length(dirList(:,1));
    display(dirList)
    display(NumFolders)
    allTracks = [];
    for(i = 3:NumFolders)
        string1 = deblank(dirList(i,:)); 
        
        PathName = sprintf('%s/%s/',PathofFolder,string1);
        fileList = ls(PathName);
       
        numFiles = length(fileList(:,1));
        
        for(j=3:1:numFiles)
            string2 = deblank(fileList(j,:));
            [pathstr, FilePrefix, ext, versn] = fileparts(string2);
            [pathstr2, FilePrefix2, ext2, versn2] = fileparts(FilePrefix);
           
            if(strcmp(ext2,'.finalTracks')==1)
                fileIndex = j;
            end
        end
        fileName = deblank(fileList(fileIndex,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        display(fileToOpen)
        load(fileToOpen);
        allTracks = [allTracks finalTracks];
    end
    
    
    
    index1 = 1;
    %%%%%%find relevant tracks
    ChOPfinalTracks = identifyChOPTracks(allTracks,stimulusfile,ROImovie,0);
   %%%%%%%%%%calculate HMM based on all data from all animals
    [expNewSeq1 expStates1 estTR estE] = getHMMStates(allTracks,30);
    %%%%%%%%%Apply HMM to relevant tracks only
    [expNewSeq expStates estTR estE] = getHMMStatesSpecifyTRandE(ChOPfinalTracks,30,estTR,estE);
    
    stimulus = load(stimulusfile);
    lengthofStimFrames = (stimulus(1,2)-stimulus(1,1)) * 3;
    for(i=1:length(ChOPfinalTracks))
        ChOPFrames = find(ChOPfinalTracks(i).stimulus_vector==1);
        display(ChOPFrames)
        numChOPFrames = length(ChOPFrames);
        numStimuli = numChOPFrames/91;
        display(numStimuli)
        for(j=1:numStimuli)
            StartIndex = (ChOPFrames((91*j)-90))-360-(180*8);
            StopIndex = StartIndex+809+(180*8);
            if(StartIndex>0)
                if(StopIndex<(ChOPfinalTracks(i).NumFrames))
            StartIndex = (ChOPFrames((91*j)-90))-360;
            display(StartIndex)
            StopIndex = StartIndex+809;
            display(StopIndex)
            if(StartIndex>0)
                if(StopIndex<length(ChOPfinalTracks(i).Frames))
            Tracknumb = i;
            AllChOPHits(index1,1) = Tracknumb;
            StartFrame = ChOPfinalTracks(i).Frames(StartIndex+360);
            Stimuli = (stimulus(:,1))*3;
            display(Stimuli)
            display(StartFrame)
            StimulusNumb = find(Stimuli==StartFrame);
            AllChOPHits(index1,2) = StimulusNumb;
            StateCalls = expStates(i).states(StartIndex:StopIndex);
            PriorState = round(nanmean(StateCalls(181:360)));
            AllChOPHits(index1,3) = PriorState;
            
            ResultingState = round(nanmean(StateCalls(451:630)));
            AllChOPHits(index1,4) = ResultingState;
            %%%%ChangeStartandStop Indices to collect 10min prior
            
            StartIndex = (ChOPFrames((91*j)-90))-360-(180*8);
            StopIndex = StartIndex+809+(180*8);
            
            
            Speed = ChOPfinalTracks(i).Speed(StartIndex:StopIndex);
            AllChOPHits(index1,5:2254) = Speed(1:2250)
            
            AngSpeed = ChOPfinalTracks(i).AngSpeed(StartIndex:StopIndex);
            
            AllChOPHits(index1,2255:4504) = AngSpeed(1:2250);
            
            StateCalls = expStates(i).states(StartIndex:StopIndex);
            AllChOPHits(index1,4505:6754) = StateCalls(1:2250);
            
            index1 = index1+1;
                end
            end
                end
            end
        end
    end
        
        if (DirofChange==1)
            RoamStartIndices = find(AllChOPHits(:,3)==2);
            AllChOPHits2 = AllChOPHits(RoamStartIndices,:);
            SuccessIndices = find(AllChOPHits2(:,4)==1);
            AllChOPHitsSuccess = AllChOPHits2(SuccessIndices,:);
            FailureIndices = find(AllChOPHits2(:,4)==2);
            AllChOPHitsFailure = AllChOPHits2(FailureIndices,:);
        else
            if(DirofChange==2)
                DwellStartIndices = find(AllChOPHits(:,3)==1);
                AllChOPHits2 = AllChOPHits(DwellStartIndices,:);
                SuccessIndices = find(AllChOPHits2(:,4)==2);
                AllChOPHitsSuccess = AllChOPHits2(SuccessIndices,:);
                FailureIndices = find(AllChOPHits2(:,4)==1);
                AllChOPHitsFailure = AllChOPHits2(FailureIndices,:);
            end
        end
        
    for(i=1:2250)
        SuccessSpeed(i) = nanmean(AllChOPHitsSuccess(:,i+4));
        SuccessAngSpeed(i) = nanmean(abs(AllChOPHitsSuccess(:,i+2254)));
        SuccessStates(i) = nanmean(AllChOPHitsSuccess(:,i+4504));
        %DwRatio(i) = DwSpeed(i)/DwAngSpeed(i);
    end
    
    SuccessSpeedMatrixTemp = AllChOPHits2(SuccessIndices,5:2254);
    SuccessAngSpeedMatrixTemp = abs(AllChOPHits2(SuccessIndices,2255:4504));
    SuccessStateMatrixTemp = AllChOPHits2(SuccessIndices,4505:6754);
    
    for (i=1:(2250/3))
        for(j=1:length(SuccessIndices))
            SuccessSpeedMatrix(j,i) = mean(SuccessSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            SuccessAngSpeedMatrix(j,i) = mean(SuccessAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            SuccessStateMatrix(j,i) = round(mean(SuccessStateMatrixTemp(j,((i*3)-2):(i*3))));
        end
    end
    subplot(5,2,1);
    imagesc(SuccessStateMatrix)
    xlabel('seconds')
    subplot(5,2,3);
    imagesc(SuccessSpeedMatrix);
    xlabel('seconds')
    subplot(5,2,5);
    x = [600 630 1 1 0];
    ymaxest = max(SuccessSpeed);
    ymaxest = ymaxest*100;
    ymaxest = ymaxest+2;
    ymax = ceil(ymaxest)/100;
    axis([0 (2250/3) 0 ymax]);
    stimulusShade(x,0,0.3);
    hold on; plot((1:2250)/3,SuccessSpeed);
    xlabel('seconds')
    subplot(5,2,7);
    imagesc(SuccessAngSpeedMatrix)
    set(gca,'CLim',[0 20]);
    xlabel('seconds')
    subplot(5,2,9);
    axis([0 (2250/3) 0 100]);
    stimulusShade(x,0,100);
    hold on; plot((1:2250)/3,SuccessAngSpeed);
        
    for(i=1:2250)
        FailureSpeed(i) = nanmean(AllChOPHitsFailure(:,i+4));
        FailureAngSpeed(i) = nanmean(abs(AllChOPHitsFailure(:,i+2254)));
        FailureStates(i) = nanmean(AllChOPHitsFailure(:,i+4504));
        %DwRatio(i) = DwSpeed(i)/DwAngSpeed(i);
    end
    
    FailureSpeedMatrixTemp = AllChOPHits2(FailureIndices,5:2254);
    FailureAngSpeedMatrixTemp = abs(AllChOPHits2(FailureIndices,2255:4504));
    FailureStateMatrixTemp = AllChOPHits2(FailureIndices,4505:6754);
    
    for (i=1:(2250/3))
        for(j=1:length(FailureIndices))
            FailureSpeedMatrix(j,i) = mean(FailureSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            FailureAngSpeedMatrix(j,i) = mean(FailureAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            FailureStateMatrix(j,i) = round(mean(FailureStateMatrixTemp(j,((i*3)-2):(i*3))));
        end
    end
    subplot(5,2,2);
    imagesc(FailureStateMatrix)
    xlabel('seconds')
    subplot(5,2,4);
    imagesc(FailureSpeedMatrix);
    xlabel('seconds')
    subplot(5,2,6);
    x = [600 630 1 1 0];
    ymaxest = max(FailureSpeed);
    ymaxest = ymaxest*100;
    ymaxest = ymaxest+2;
    ymax = ceil(ymaxest)/100;
    axis([0 (2250/3) 0 ymax]);
    stimulusShade(x,0,0.3);
    hold on; plot((1:2250)/3,FailureSpeed);
    xlabel('seconds')
    subplot(5,2,8);
    imagesc(FailureAngSpeedMatrix)
    set(gca,'CLim',[0 20]);
    xlabel('seconds')
    subplot(5,2,10);
    axis([0 (2250/3) 0 100]);
    stimulusShade(x,0,100);
    hold on; plot((1:2250)/3,FailureAngSpeed);
        
        
        
        
        
        
        
        
        
        
end
            
    
    