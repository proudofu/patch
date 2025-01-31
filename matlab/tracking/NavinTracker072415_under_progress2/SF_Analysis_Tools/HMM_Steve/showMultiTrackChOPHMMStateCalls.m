function showMultiTrackChOPHMMStateCalls(finalTracks,vectToAnalyze,binSize,TracksInStim,stimulus,C128SFlag)

    numTracks = length(vectToAnalyze);
    numPlots = numTracks *3;
    
    
    for(i=1:numTracks)
        NumFrames = finalTracks(vectToAnalyze(i)).NumFrames;
        StartFrame = finalTracks(vectToAnalyze(i)).Frames(1);
        xaxis_1 = StartFrame:1:(StartFrame+NumFrames-1);
        xaxis_2 = xaxis_1/180;
        subplot(numPlots,1,(i*3)-2);
        
        finalTrackIndex = vectToAnalyze(i);
        TrackStimIndex = find(TracksInStim(:,2)==finalTrackIndex);
        stimuliPresent = TracksInStim(TrackStimIndex,1);
        if(C128SFlag==1)
            stimuliPresent_blue=stimuliPresent-1;
            stimulusHere_blue=stimulus(stimuliPresent_blue,:)/60;
        end
        stimulusHere = stimulus(stimuliPresent,:)/60;
        
        if(C128SFlag==1)
            stimulusShade(stimulusHere, -500, 200,[0 0.95 0]); hold on;
            stimulusShade(stimulusHere_blue, -500, 200); hold on;
        else
            stimulusShade(stimulusHere, -500, 200); hold on;
        end
        ax = plotyy(xaxis_2,finalTracks(vectToAnalyze(i)).AngSpeed,xaxis_2,finalTracks(vectToAnalyze(i)).Speed);
        set(ax, 'XLim', [0 90])
        axis([0 90 -500 200])
        xlabel('time (min)');
        ylabel('Angular Speed (deg/sec)');

        [expNewSeq expStates estTR estE] = getHMMStates(finalTracks,binSize);
        xaxis_5 = finalTracks(vectToAnalyze(i)).Frames(1):1:(finalTracks(vectToAnalyze(i)).Frames(1) + length(expStates(vectToAnalyze(i)).states) -1);
        xaxis_6 = xaxis_5/180;
        subplot(numPlots,1,(i*3)-1);
        if(C128SFlag==1)
            stimulusShade(stimulusHere, -1, 3,[0 0.95 0]); hold on;
            stimulusShade(stimulusHere_blue, -1, 3); hold on;
        else
            stimulusShade(stimulusHere, -1, 3); hold on;
        end
        plot(xaxis_6,expStates(vectToAnalyze(i)).states);
        axis([0 90 -1 3]);
        dummystring = sprintf('HMM Calls');
        title(dummystring);
        %%%maybe set color, etc.
%          subplot(numPlots,1,(i*3));
%          stimulusShade(stimulusHere, 0.5, 1); hold on;
%          plot(xaxis_2, finalTracks(vectToAnalyze(i)).Eccentricity);
%          axis([0 90 0.5 1])
%          dummystring = sprintf('Eccenticity');
%          title(dummystring);
%         
        
        
        t=[];
        
        for (j=1:length(finalTracks(i).Pirouettes)) t = [t finalTracks(i).Pirouettes(j).start]; end
        t = t/180;
        display(i)
        subplot(numPlots,1,(i*3));
        stimulusShade(stimulusHere, -1, 3); hold on;
        plot([t;t],[ones(size(t));zeros(size(t))])
        axis([0 90 -1 2])
        dummystring = sprintf('Pirouettes');
        title(dummystring);
        
%         [RevMatrix DwellRevRate RoamRevRate Dwell_sRevRate Dwell_lRevRate Roam_sRevRate Roam_lRevRate] = CreateRevMatrix2_HMM(finalTracks);
%         
%         RevIndexCol1 = RevMatrix(:,1);
%         RevIndexCol2 = RevMatrix(:,2);
%         RevIndforThisTracks = find(RevIndexCol2 == i);
%         ThisTrackRevs = RevMatrix(RevIndforThisTracks,:);
%         RevLengths = ThisTrackRevs(:,4);
%         lRevIndex = find(RevLengths > 0.3);
%         lRevTimes = ThisTrackRevs(lRevIndex,3);
%         t = lRevTimes/180;
%         t=t';
%         subplot(numPlots,1,(i*3));
%         stimulusShade(stimulusHere, -1, 3); hold on;
%         plot([t;t],[ones(size(t));zeros(size(t))])
%         axis([0 90 -1 2])
%         
%         dummystring = sprintf('long Reversals');
%         title(dummystring);
%         %%%maybe set color, etc.
    end
            
        
        [filepath,fileprefix,extension,version] = fileparts(finalTracks(i).Name);
        display(fileprefix)

        fullName = sprintf('%s_chopplot',fileprefix);
        save_figure(1,'',fullName,'states');
    end
