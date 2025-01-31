function Dif = GetAngleDif(x,y)

% This function subtracts x from y, taking into consideration
% "wrap-around" issues with a period of 360

Dif = y - x; 

Index = find(Dif > 180);
Dif(Index) = 360 - Dif(Index);

Index = find(Dif < -180);
Dif(Index) = -360 - Dif(Index);

% after wrapping, correct the few stragglers
Index = find(Dif > 180);
Dif(Index) = 180;

Index = find(Dif < -180);
Dif(Index) = -180;

return;
end
