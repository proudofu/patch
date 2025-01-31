function tracks = checkAllEncounters_v3(tracks)
memBuffer = 0.25;% out of 1

strains = fields(tracks);
maxMem = memory;
nextI = [1 1];
%%%%%%%%LOAD VIDS
vids = struct();
indices = struct();

if isfield(tracks.(strains{1}), 'ID')
    for s = 1:length(strains)%each strain
        theseVids = {tracks.(strains{s}).ID};
        vids.(strains{s})(1:length(theseVids)) = struct('vidFrames', []);
        indices.(strains{s})(1:length(theseVids)) = struct('indices', []);
        trackNum = 0;
        for t = 1:length(theseVids)%each track for all strain videos
            trackNum = trackNum + 1;
            vidFile = dir(sprintf('**\\encounterVids\\%s.mat',theseVids{t}));
            vidFile = [vidFile.folder '\' vidFile.name];
            vids.(strains{s})(trackNum) = load(vidFile, 'vidFrames');
            indices.(strains{s})(trackNum) = load(vidFile, 'indices');
            now = memory;
            if ((now.MemAvailableAllArrays/maxMem.MemAvailableAllArrays) <= memBuffer) || (now.MemAvailableAllArrays < 1e+8)
                [tracks, indices, vids, trackNum] = watchNow(vids, indices, tracks, nextI, [s trackNum]);
                strainDone = (t == length(theseVids));
                nextI = [(s+strainDone) ((trackNum+1)*~strainDone + strainDone)];
            end
        end
    end
else%%for old versions
    vidNames = parseVidNames(tracks, strains);%NOTE: vids is string array, not cell array
    for s = 1:length(strains)%each strain
        oldVidPaths = {};
        for v = 1:length(vidNames.(strains{s}))%each video per strain
            theseVidPaths = dir(sprintf('**\\encounterVids\\%s\\*.mat', vidNames.(strains{s})(v)));
            theseVidPaths = arrayfun(@(vid) [vid.folder '\' vid.name], theseVidPaths, 'UniformOutput', false);
            oldVidPaths = [oldVidPaths; theseVidPaths];
        end
        theseVidPaths = oldVidPaths;
        strainVids(1:length(theseVidPaths)) = struct('vidFrames', []);
        strainIndices(1:length(theseVidPaths)) = struct('indices', []);
        for t = 1:length(theseVidPaths)%each track for all strain videos
            strainVids(t) = load(theseVidPaths{t}, 'vidFrames');
            strainIndices(t) = load(theseVidPaths{t}, 'indices');
        end
        vids.(strains{s}) = strainVids;
        indices.(strains{s}) = strainIndices;
        clear strainVids;
        clear strainIndices;
        now = memory;
        if ((now.MemAvailableAllArrays/maxMem.MemAvailableAllArrays) <= memBuffer) || (now.MemAvailableAllArrays < 1e+8)
            [tracks, indices, vids] = watchNow(vids, indices, tracks, nextI, s);
            nextI = s;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%WATCH REST OF VIDS
[tracks, ~, ~, ~] = watchNow(vids, indices, tracks, nextI, [s trackNum]);

%now save it
num = 1;

names = unique({tracks.(strains{1}).Name});
name = split(names{1}, '\');
name = split(name(end), '_');
name = name{1};

while exist(sprintf('allTracks_%s_%i.mat', name, num), 'file')
    num = num + 1;
end

disp('Saving...');
eval(sprintf('tracks_%s = tracks', name))
eval(sprintf('save(''allTracks_%s_%i.mat'', ''tracks_%s'')', name, num, name));

return
end

function [tracks, indices, vids, trackNum] = watchNow(vids, indices, tracks, nextI, ready)
    strains = fields(tracks);
    trackNum = nextI(2);
    for s = nextI(1):ready(1)%each strain
        if s == ready(1)
            stopAt = ready(2);
        else
            stopAt = length(tracks.(strains{s}));
        end
        while trackNum <= stopAt%each worm per strain
            fig = figure;
            fig.UserData.localI = find(indices.(strains{s})(trackNum).indices == tracks.(strains{s})(trackNum).refeedIndex);
            fig.UserData.len = length(indices.(strains{s})(trackNum).indices);
            fig.Name = sprintf('%s (%i of %i): worm %i of %i', strains{s}, s, length(strains), trackNum, length(tracks.(strains{s})));
            fig.UserData.noShow = false;
            fig.UserData.doThis = '';
            fig.UserData.onHold = false;
            fig.KeyPressFcn = @playCommand;
            
            thisVid = vids.(strains{s})(trackNum).vidFrames;
            checkVid(thisVid, fig);
            noShow = fig.UserData.noShow;
            localI = fig.UserData.localI;
            close;

            if ~noShow
                tracks.(strains{s})(trackNum).refeedIndex = indices.(strains{s})(trackNum).indices(localI);
                vids.(strains{s})(trackNum).vidFrames = [];
                trackNum = trackNum + 1;
            else
                stopAt = stopAt - 1;
                if trackNum == 1
                    tracks.(strains{s}) = tracks.(strains{s})([2:end]);
                    indices.(strains{s}) = indices.(strains{s})([2:end]);
                    vids.(strains{s}) = vids.(strains{s})([2:end]);
                else
                    tracks.(strains{s}) = tracks.(strains{s})([1:(trackNum-1) (trackNum+1):end]);
                    indices.(strains{s}) = indices.(strains{s})([1:(trackNum-1) (trackNum+1):end]);
                    vids.(strains{s}) = vids.(strains{s})([1:(trackNum-1) (trackNum+1):end]);
                end
            end
        end
        if s ~= ready(1)
            trackNum = 1;
        end
    end
    
    trackNum = trackNum - 1;
    return
end

function vidNames = parseVidNames(tracks, strains)
    for s = 1:length(strains)
        names = split(unique({tracks.(strains{s}).Name}), '\');
        if size(names,2)>1
            names = names(:, :, end);
            names = split(names, '.');
            vidNames.(strains{s}) = sort(names(:,:,1));
        else
            names = names(end);
            names = split(names, '.');
            vidNames.(strains{s}) = names(1);
        end        
    end
end

function checkVid(thisVid, fig)
    figure(fig)    
    while isempty(fig.UserData.doThis) && fig.UserData.localI <= size(thisVid, 3)%press spacebar to indicate event
        imshow(thisVid(:,:,fig.UserData.localI), 'DisplayRange', []);
        eval(fig.UserData.doThis);
    end
end

function playCommand(src, event)
    if strcmp(sprintf('%i', src.CurrentCharacter), '28')%<- backwards
        src.UserData.localI = src.UserData.localI - 1;
        if src.UserData.localI < 1
            src.UserData.localI = 1;
        end
    elseif strcmp(sprintf('%i', src.CurrentCharacter), '29')%-> forwards
        src.UserData.localI = src.UserData.localI + 1;
        if src.UserData.localI > src.UserData.len
            src.UserData.localI = src.UserData.len;
        end    
    elseif strcmp(src.CurrentCharacter, 'b')%b for fast backward
        src.UserData.localI = src.UserData.localI - 3;%for 3fps
        if src.UserData.localI < 1
            src.UserData.localI = 1;
        end
    elseif strcmp(src.CurrentCharacter, 'f')%f for fast forward
        src.UserData.localI = src.UserData.localI + 3*3;%for 3fps
        if src.UserData.localI > src.UserData.len
            src.UserData.localI = src.UserData.len;
        end
    elseif strcmp(src.CurrentCharacter, 'e')%e for empty frame
        src.UserData.noShow = true;
        src.UserData.doThis = 'return';
    elseif strcmp(src.CurrentCharacter, ' ')%spacebar for encounter
        src.UserData.doThis = 'return';
    end
        
    if (src.UserData.localI >= src.UserData.len || src.UserData.localI <= 1) && ~src.UserData.onHold
        src.UserData.onHold = true;
        answer = questdlg('End of track data. Save this frame as index?', 'End of Track', 'Yes', 'No', 'Do not save index', 'No'); 
        src.UserData.onHold = false;
        if strcmp(answer, 'Yes')
            src.UserData.doThis = 'return';
            if src.UserData.localI > src.UserData.len
                src.UserData.localI = src.UserData.len;
            elseif src.UserData.localI < 1
                src.UserData.localI = 1;
            end
        elseif strcmp(answer, 'Do not save index')
            src.UserData.noShow = true;
            src.UserData.doThis = 'return';
        elseif src.UserData.localI > src.UserData.len
            src.UserData.localI = src.UserData.len;
        elseif src.UserData.localI < 1
            src.UserData.localI = 1;
        end
    end
end

% add Close request function 