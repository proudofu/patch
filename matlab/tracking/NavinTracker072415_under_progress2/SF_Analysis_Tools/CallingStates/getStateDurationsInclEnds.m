function [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds(stateData,binSize)
    
    roamStateDurations = [];
    dwellStateDurations = [];
    for (j=1:length(stateData))
        
        nBins = length(stateData(j).finalstate);
        currentState = stateData(j).finalstate(1);
        currentStateDuration = 1;
        stateNumb = 1;
        stateDurationMaster(j).stateCalls = [];
        firstCall = 1;
        for (i=2:nBins)
            if (i==nBins)
                lastState = stateData(j).finalstate(i-1);
                lastStatesecs = binSize * currentStateDuration;
                if (lastState ==1)
                    
                    dwellStateDurations = [dwellStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                    
                else
                   
                    roamStateDurations = [roamStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                end
            else
            if (stateData(j).finalstate(i) == currentState)
                currentStateDuration = currentStateDuration + 1;
            else 
                lastState = stateData(j).finalstate(i-1);
                lastStatesecs = binSize * currentStateDuration;
                if (lastState ==1)
                    
                    dwellStateDurations = [dwellStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                    
                else
                   
                    roamStateDurations = [roamStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                end
                currentStateDuration = 1;
                currentState = stateData(j).finalstate(i);
            end
            end
        end
    end
end