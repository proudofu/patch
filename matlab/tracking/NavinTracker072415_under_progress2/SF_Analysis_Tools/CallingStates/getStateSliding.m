function [stateList startingStateMap] = getStateSliding(trackDataforSp,trackDataforAngSp,ratio,binSize,slideSize,minStateDuration,fps)
    stateList = [];
    
    binnedSpeedData = binSpeedSliding(trackDataforSp, binSize, slideSize);
    binnedAngSpeedData = binAngSpeedSliding(trackDataforAngSp, binSize, slideSize);
    
    startingStateMap = getState(binnedSpeedData,binnedAngSpeedData,ratio);
    
    minStateDurationFrames = minStateDuration * fps;
    minConsecDataPoints = (round((minStateDurationFrames-binSize)/slideSize) + 1);
    
    for(j=1:(length(trackDataforSp)))
       
    currentState = startingStateMap(j).state(1);
    stateStart = 1;
    lastState = startingStateMap(j).state(1);
    currentStateDuration = 1;
    stateList(j).finalstate = [];
    firstCall = 1;
    for (i=2:(length(startingStateMap(j).state)))
        if (startingStateMap(j).state(i) == currentState)
            currentStateDuration = currentStateDuration + 1;
            if(i==length(startingStateMap(j).state))
                stateEnd = i-1;
                startInd = 1 + ((stateStart-1) * slideSize) + (round((binSize-slideSize)/2));
                stopInd_Prec = 1 + ((stateEnd-1) * slideSize);
                stopInd = stopInd_Prec + (binSize-1);
                stateList(j).finalstate(startInd:stopInd) = currentState;
            end
        else 
            stateEnd = i-1;
            startInd = 1 + ((stateStart-1) * slideSize) + (round((binSize-slideSize)/2));
            stopInd_Prec = 1 + ((stateEnd-1) * slideSize);
            stopInd = stopInd_Prec + (binSize-1);
            if (currentStateDuration >= minConsecDataPoints)
                if (firstCall == 1)
                    stateList(j).finalstate(1:stopInd) = currentState;
                    lastState = currentState;
                    firstCall = 0;
                else
               stateList(j).finalstate(startInd:stopInd) = currentState;
               lastState = currentState;
               end
            else 
                stateList(j).finalstate(startInd:stopInd) = lastState;
       
            end
            currentStateDuration = 1;
            currentState = startingStateMap(j).state(i);
            stateStart = i;
            
        end
    end
end
