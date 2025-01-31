function [ChOPDwellStateDurations ControlDwellStateDurations] = DwellsDuringChOP_specifymodel(finalTracks,startStim,stopStim,estTR,estE)

    [expNewSeq expStates estTR estE] = getHMMStatesSpecifyTRandE_2(finalTracks,30,estTR,estE);
    [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds_HMM(expStates,.333);
    
   
    startStim = startStim*3;
    stopStim = stopStim*3;
    
    ChOPDwellStateDurations = [];
    ControlDwellStateDurations = [];
    
    %%%%%Start with include ends - then toss out first and last rows
    for(j=1:length(stateDurationMaster))
        startTime = finalTracks(j).Frames(1);
       
        for(i=1:(length(stateDurationMaster(j).stateCalls(:,1))))
            display(stateDurationMaster(j).stateCalls)
            stopTime = startTime + (stateDurationMaster(j).stateCalls(i,2)*3);
            stateDurationMaster(j).stateCalls(i,3) = startTime; % adjust for startFrame, and seconds to Frames
            stateDurationMaster(j).stateCalls(i,4) = stopTime;
            startTime = stopTime;
            
        end
        
        %if(length(stateDurationMaster(j).stateCalls>2))
        %for(i=2:(length(stateDurationMaster(j).stateCalls(:,1))-1))
        for(i=1:(length(stateDurationMaster(j).stateCalls(:,1))))
            if(stateDurationMaster(j).stateCalls(i,1)==1)
                
                DwellFrames = round(stateDurationMaster(j).stateCalls(i,3):1:stateDurationMaster(j).stateCalls(i,4));

                ChOPFrames = startStim:1:stopStim;

                checkforoverlap = intersect(DwellFrames,ChOPFrames);

                if(length(checkforoverlap>12))
                    if(stateDurationMaster(j).stateCalls(i,3)<startStim)
                    if(stateDurationMaster(j).stateCalls(i,3)>6200)
                        if(stateDurationMaster(j).stateCalls(i,4)<13040)
                    ChOPDwellStateDurations = [ChOPDwellStateDurations stateDurationMaster(j).stateCalls(i,2)];
                        end
                    end
                    end
                    
                else
                    %if(finalTracks(j).Frames(1)>stopStim)
                    %if(stateDurationMaster(j).stateCalls(i,3)>stopStim)
                    ControlDwellStateDurations = [ControlDwellStateDurations stateDurationMaster(j).stateCalls(i,2)];
                   % end
                    %end
                end
                
            end
        end
        %end
    end
end

        