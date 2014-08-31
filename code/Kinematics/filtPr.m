function data=filtPr(data)

% display algorithm step entry
display('Filtering out incomplete PR  paths from window matching');

%% Filter out ANY rows from pX, pY, vX, vY,uX,uY that have NaN's in them. 
filtPath=any(isnan(data.stepX),2);
data.pX(filtPath,:)=[];
data.pY(filtPath,:)=[];
data.stepX(filtPath,:)=[];
data.stepY(filtPath,:)=[];
data.vX(filtPath,:)=[];
data.vY(filtPath,:)=[];
data.minX(filtPath,:)=[];
data.minY(filtPath,:)=[];
data.minRsq(filtPath,:)=[];
data.minSSD(filtPath,:)=[];


%% and filter out the SSD and Rsq values for these as well, using the empty SSD and Rsq in any row
% first, set all rows with emptry column entries to all empty
for i2=1:1:data.numFeats
    for i3=1:1:data.numSt
        % if any entry in each row is empty, make all entries in row empty
        if isempty(data.SSD{i2,i3})
            for i4=1:1:data.numSt
                data.SSD{i2,i4}=[];
                data.Rsq{i2,i4}=[];
            end
        end
    end
end
% then copy the resulting structure to a new structure with empty rows
% removed.  This should give the same dimensions and indexing values as pX,
% pY, etc.
cnt=0;
cntFilt=0;
for i2=1:1:data.numFeats
    % only need to check the first column for empty now b/c of above step
    if ~isempty(data.SSD{i2,1})
        cnt=cnt+1;
        for i3=1:1:data.numSt
            SSDtmp{cnt,i3}=data.SSD{i2,i3};
            Rsqtmp{cnt,i3}=data.Rsq{i2,i3};
        end
    else
        cntFilt=cntFilt+1;
    end
end
% finally, reassign the SSD and Rsq
data.SSD=SSDtmp;
data.Rsq=Rsqtmp;

% update the number of paths
numPaths=size(data.pX,1);

%% output the path filtering stats
display(sprintf('%i paths filtered. %i Remaining frames.  %i complete paths.',cntFilt,data.numSt,numPaths));

%% assign counter to data structure
data.cntFilt=cntFilt;
data.numPaths=numPaths;
