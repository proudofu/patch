function [Num_total_revs Num_sRevs Num_lRevs Duration_of_State SpeedMatrix AngSpeedMatrix lRevSpeedMatrix sRevSpeedMatrix] = CreateRevMatrixforLongvShort_HMM(finalTracks,tracknumb,StartFrame,EndFrame,FrameIndicestoExclude)
Rev_Dwell = [];
Rev_Roam = [];
j=tracknumb;
% [expNewSeq expStates estTR estE] = getHMMStates(finalTracks,30)
% %[stateList startingStateMap] = getStateSliding_Diff(finalTracks,finalTracks2,450,30,3,35,57,3);
% % %[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations(stateList,.333);
%  allStateCalls = [];
%  for(j = 1:(length(expStates)))
%  
%      allStateCalls = [allStateCalls expStates(j).states];
% %  end
%  TotalBins = length(allStateCalls);
%  numDwellBins = length(find(allStateCalls==1));
%  numRoamBins =length(find(allStateCalls==2));
%  DwellTime = numDwellBins/180;
%  RoamTime = numRoamBins/180;

DwellIndex = [];
DwellIndexLength = []; 
RoamIndex = [];
RoamIndexLength = [];
indexRevMatrix = 1;
RevMatrix = [];
TotalRevRate =NaN;
sRevRate =NaN;
lRevRate=NaN;

    %display(finalTracks(j).Reversals)
    %display(finalTracks(j).Name)
    %display(j)
    if(length(finalTracks(j).Reversals)>0)
        Revs = finalTracks(j).Reversals(:,2);
    
        %DwellFrames = find(expStates(j).states==1);
        FramesofInt = StartFrame:1:EndFrame;
        %display(FramesofInt)
        %display(FrameIndicestoExclude)
        
        if (length(FrameIndicestoExclude)>0)
            FramesofInt(FrameIndicestoExclude) = [];
        end
        %display(FramesofInt)

        if (finalTracks(j).Reversals(end,1) > finalTracks(j).NumFrames)
        
           Revs = Revs - finalTracks(j).NumFrames + 1;
        end
        
        
        
        for (i=1:length(Revs))
            a = find(FramesofInt==Revs(i));

            if(a>0)
                %DwellIndex = [DwellIndex i];
                RevMatrix(indexRevMatrix,1) = 1;
                RevMatrix(indexRevMatrix,2) = j;
                RevMatrix(indexRevMatrix,3) =  Revs(i);
                RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reversals(i,3);
                indexRevMatrix = indexRevMatrix + 1;

%             else
%                 %RoamIndex = [RoamIndex i];
%                 RevMatrix(indexRevMatrix,1) = 2;
%                 RevMatrix(indexRevMatrix,2) = j;
%                 RevMatrix(indexRevMatrix,3) =  finalTracks(j).Reversals(i,2);
%                 RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reversals(i,3);
%                 indexRevMatrix = indexRevMatrix + 1;

            end

        end
    end
    Frames_of_State = EndFrame - StartFrame + 1 - length(FrameIndicestoExclude)
    Duration_of_State = Frames_of_State/180;
if(length(RevMatrix)>0)   
    RevLengths = RevMatrix(:,4);
    Num_sRevs = length(find(RevLengths < 0.3));
    Num_total_revs = length(RevLengths);
    Num_lRevs = Num_total_revs-Num_sRevs;
    
    
%%%%%%%%%Get 3sec after each reversal and include this is output

    SpeedMatrix = [];
    
    indexDwell = 1;
    
    indexDwellsRev = 1;
    indexDwelllRev = 1;
    
    
    lRevSpeedMatrix = [];
    sRevSpeedMatrix = [];
    
    AngSpeedMatrix =[];
    
    NumRevs = length(RevMatrix(:,1));
    for (k = 1:NumRevs)
        EndofRev = RevMatrix(k,3);
        trackNumb = RevMatrix(k,2);
        ThreeSecAfterPlusOne = (EndofRev+2):(EndofRev+11);
        
        if(ThreeSecAfterPlusOne(10) <= finalTracks(tracknumb).NumFrames)
            %%%adjust for Framestart
%             if (finalTracks(tracknumb).Reversals(1,1) < finalTracks(tracknumb).Frames(1))
%             else
%               ThreeSecAfterPlusOne = ThreeSecAfterPlusOne - finalTracks(tracknumb).Frames(1) +1;
%            end
            %FirstFrame = finalTracks(tracknumb).Frames(1);
            %display(FirstFrame)
            %ThreeSecAfterPlusOne = ThreeSecAfterPlusOne - FirstFrame + 1;
            %display(ThreeSecAfterPlusOne)
            AngSpeedPostRev = finalTracks(tracknumb).AngSpeed(ThreeSecAfterPlusOne);
            AngSpeedPostRev = abs(AngSpeedPostRev);
            check1 = find(AngSpeedPostRev>60);
            checkforNans = isnan(AngSpeedPostRev);
            allnans = sum(checkforNans);
            if(allnans == 0)
                if (check1>0)
                else
                    ThreeSecAfter = (EndofRev+2):(EndofRev+10);
                    %%%adjust for Framestart
                    
%                     if (finalTracks(tracknumb).Reversals(1,1) < finalTracks(tracknumb).Frames(1))
%                     else
%                       ThreeSecAfter = ThreeSecAfter - finalTracks(tracknumb).Frames(1) +1;
%                    end

                    %ThreeSecAfter = ThreeSecAfter - FirstFrame + 1;
                    SpeedPostRev =  finalTracks(tracknumb).Speed(ThreeSecAfter);
                    AngSpeedPostRev =  abs(finalTracks(tracknumb).AngSpeed(ThreeSecAfter));
                    
                    SpeedMatrix(indexDwell,1:9) = SpeedPostRev;
                    AngSpeedMatrix(indexDwell,1:9) = AngSpeedPostRev;
                    indexDwell = indexDwell + 1;

                    
                    if (RevMatrix(k,4) < 0.3)
                        
                            sRevSpeedMatrix(indexDwellsRev,1:9) = SpeedPostRev;
                            indexDwellsRev = indexDwellsRev + 1;
                        
                    else
                        
                            lRevSpeedMatrix(indexDwelllRev,1:9) = SpeedPostRev;
                            indexDwelllRev = indexDwelllRev +1;
                        
                    end
                    
                    
                end
            end
        end
    end
    else
    Num_sRevs = 0;
    Num_total_revs = 0;
    Num_lRevs = 0;
    SpeedMatrix =[];
    AngSpeedMatrix =[];
    sRevSpeedMatrix =[];
    lRevSpeedMatrix =[];
    end

   
    end