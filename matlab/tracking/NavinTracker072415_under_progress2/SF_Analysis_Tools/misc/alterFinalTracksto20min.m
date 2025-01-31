function alterFinalTracksto20min(mastermasterfolder)

PathofMasterMasterFolder = sprintf('%s',mastermasterfolder);
MasterMasterdirList = ls(PathofMasterMasterFolder);
MasterMasterNumFolders = length(MasterMasterdirList(:,1));
for(q=3:MasterMasterNumFolders)
    string1 = deblank(MasterMasterdirList(q,:)); 
    MasterPathName = sprintf('%s/%s/',PathofMasterMasterFolder,string1);
    MasterdirList = ls(MasterPathName);
    display(MasterdirList)
    MasterNumFolders = length(MasterdirList(:,1)); %%%%2 folders cuz 2 genotypes
for (j=3:MasterNumFolders)
    string1 = deblank(MasterdirList(j,:)); 
    NestedPathName = sprintf('%s/%s/',MasterPathName,string1);
    NesteddirList = ls(NestedPathName);
    display(NesteddirList)
    FinalNumFolders = length(NesteddirList(:,1)); %%%%2 folders cuz 2 genotypes
    for (l=3:FinalNumFolders)
        
                string3 = deblank(NesteddirList(l,:)); 

                PathName = sprintf('%s/%s/',NestedPathName,string3);
                fileList = ls(PathName);
                display(PathName)
                display(fileList)
                numFiles = length(fileList(:,1));

                for(l=3:1:numFiles)
                    string4 = deblank(fileList(l,:));
                    [pathstr, FilePrefix, ext, versn] = fileparts(string4);
                    [pathstr2, FilePrefix2, ext2, versn2] = fileparts(FilePrefix);

                    if(strcmp(ext2,'.finalTracks')==1)
                        finalTracksfileIndex = l;
                    end

                    if(strcmp(ext2,'.leftoverTracks')==1)
                        leftoverTracksfileIndex = l;
                    end

                end
                finalTracksfileName = deblank(fileList(finalTracksfileIndex,:));
                leftoverTracksfileName = deblank(fileList(leftoverTracksfileIndex,:));
                fileToOpen = sprintf('%s%s',PathName,leftoverTracksfileName);
                display(fileToOpen);
                load(fileToOpen);
                fileToOpen = sprintf('%s%s',PathName,finalTracksfileName);
                display(fileToOpen);
                load(fileToOpen);


                NumFramesAll = [];
                for (k=1:(length(leftoverTracks)))
                    NumFramesAll(k) = leftoverTracks(k).NumFrames;
                end


                LongTrackIndex = find(NumFramesAll >= 3600);

                Tracks_to_add = leftoverTracks(LongTrackIndex);
                
                NumNewTracks = length(LongTrackIndex);
                NumOldTracks = length(finalTracks);
                if(NumNewTracks>0)
                finalTracks(NumOldTracks+1:(NumOldTracks+NumNewTracks)) = Tracks_to_add;

                movieName = finalTracks(1).Name;
                [filepath,filePrefix,extension,version] = fileparts(sprintf('%s',movieName));
                dummystring = sprintf('%s%s.finalTracks.mat',PathName,filePrefix);
                save(dummystring,'finalTracks');
                end
        end
    end
end

end
