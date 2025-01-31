function LED_control(channel, current, duration, strobeperiod, strobe_on_time, strobe_pause_time)

if(nargin == 0)
    disp(['LED_control(channel, current, duration, strobeperiod, strobe_on_time, strobe_pause_time)'])
    return
end

global MAX_LED_CURRENT;

if(nargin==1)
    current =  MAX_LED_CURRENT;
    duration = 0;
    strobeperiod = -10;
    strobe_on_time = 0;
    strobe_pause_time = 0;
    
    % is a vector of inputs ... row from stimulus matrix?
    if(length(channel)>1)
        x = channel;
        for(i=1:length(x))
            if(i==1)
                channel = x(i);
            end
            if(i==2)
                current = x(i);
            end
            if(i==3)
                duration = x(i);
            end
            if(i==4)
                strobeperiod = x(i);
            end
            if(i==5)
                strobe_on_time = x(i);
            end
            if(i==6)
                strobe_pause_time = x(i);
            end
        end
    end
end

if(nargin==2)
    duration = 0;
    strobeperiod = -10;
    strobe_on_time = 0;
    strobe_pause_time = 0;
end

if(nargin==3)
    strobeperiod = -10;
    strobe_on_time = 0;
    strobe_pause_time = 0;
end

if(nargin==4)
    strobe_on_time = 0;
    strobe_pause_time = 0;
end

devices = daq.getDevices;
s = daq.createSession('ni');
s.Rate = 5000;
addAnalogOutputChannel(s,'Dev1', 0,'Voltage');

if(channel >= 12)
    addAnalogOutputChannel(s,'Dev1', 1,'Voltage');
    
    outputSingleScan(s,[current(1),current(2)])
    pause(duration);
    outputSingleScan(s,[-4,-4])
    return;
end

outputSingleScan(s,current)
pause(duration);
outputSingleScan(s,-4)

return;
end

