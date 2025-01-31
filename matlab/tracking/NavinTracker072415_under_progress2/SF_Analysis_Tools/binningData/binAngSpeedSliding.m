%%%slideSize and binSize are in frames

function binnedAngSpeedSliding = binAngSpeedSliding(trackData, binSize, slideSize)
    
   for (i=1:length(trackData)) 
        angspeedData = trackData(i).AngSpeed;
        binnedAngSpeedSliding(i).AngSpeed = [];
        j= 1;
    while((j+(binSize-1)) <= (length(angspeedData)))
        startIn = j;
        stopIn = j + (binSize-1);
        currentData = angspeedData(startIn:stopIn);
        binnedAngSpeedSliding(i).AngSpeed = [binnedAngSpeedSliding(i).AngSpeed mean(abs(currentData))];
        j = j + slideSize;
    end
end


