%% filter out triangles lower than some quality threshold in both the PR 
%% and SPR triangulations

function data=filtQual(data)

%  display algorithm step entry
display('Filter out low quality mesh elements');


for i3=1:1:data.numSt-1
    % counter for filtered triangles 
    cntDFilt=0;
    
    for i4=1:1:data.numTri
        
        % if the quality of a triangle is too low...
        if data.raQual(i3,i4)>=data.raQualTh            % || data.aT(i3,i4)<=0.5E-9
            
            % set the raQual entry to NaN to mark filtered triangles
            data.raQual(i3,i4)=NaN;
            
            
            cntDFilt=cntDFilt+1;
            
        else
            % leave entries as is
        end
    end
    
    % display the number of filtered strain rates.
    display(sprintf('%i low quality elements in frame %i',cntDFilt,i3));
end

%% Filter out strain rates, triangles, etc. 
 
filtVec=any(isnan(data.raQual),1);

% filter non-cell struct quantities
data.raQual(:,filtVec)=[];
data.skewTri(:,filtVec)=[];
data.aT(:,filtVec)=[];
data.raQualSpr(:,filtVec)=[];
data.skewTriSpr(:,filtVec)=[];
data.aTSpr(:,filtVec)=[];
data.dX(:,filtVec)=[];
data.dY(:,filtVec)=[];
data.dXY(:,filtVec)=[];
data.tC(:,filtVec)=[];
data.wC(:,filtVec)=[];
data.tauC(:,filtVec)=[];
data.omegaC(:,filtVec)=[];
data.pSC(:,filtVec)=[];
data.qSC(:,filtVec)=[];
data.thetaSC(:,filtVec)=[];
data.phiSC(:,filtVec)=[];

% filter out cell struct quantities
for i3=1:1:data.numSt-1
    data.triX{i3}(:,filtVec)=[];
    data.triY{i3}(:,filtVec)=[];
    data.triCc{i3}(:,filtVec)=[];
    data.triSprX{i3}(:,filtVec)=[];
    data.triSprY{i3}(:,filtVec)=[];
    data.triSprCc{i3}(:,filtVec)=[];
end

