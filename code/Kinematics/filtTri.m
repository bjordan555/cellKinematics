%% Function to filter out triangles that either don't meet quality or cross 
%% restricted boundaries
function data=filtTri(data)

% allow only triangle quality (as measured by ratio of circumcircle radius
% to smallest triangle edge length) smaller than this
data.raQualTh=2;

% initialize the filter table
data.rbFilt=zeros(data.numSt-1,data.numTri);

%% filter out triangles lower than some quality threshold in both the PR 
%% and SPR triangulations

%  display algorithm step entry
display('Filter out low quality mesh elements');


for i3=1:1:data.numSt-1
    % counter for filtered triangles 
    cntDFilt=0;
    
    for i4=1:1:data.numTri
        
        % if the quality of a triangle is too low...
        if data.raQual(i3,i4)>=data.raQualTh            % || data.aT(i3,i4)<=0.5E-9
            
            % set the filtering parameter to 1 to mark filtered triangles
            data.rbFilt(i3,i4)=1;
                        
            cntDFilt=cntDFilt+1;
            
        else
            % leave entries as is
        end
    end
    
    % display the number of filtered strain rates.
    display(sprintf('%i low quality elements in frame %i',cntDFilt,i3));
end


%% filter out triangles whose verticies cross restricted boundaries
%  display algorithm step entry
display('Filter out elements that cross restricted boundaries');

for i3=1:1:data.numSt-1
    % counter for filtered triangles
    cntDFilt=0;
    
    for i4=1:1:data.numTri
        
        % if the verticies span a restricted boundary...
        % and loop over all restricted boundaries
        for i5=1:1:length(data.restBdryX)
            % compute and check all 6 cases for each boundary
            c12=data.triSprX{i3}(1,i4)<=data.restBdryX(i5)*data.mPxXMIP && data.triSprX{i3}(2,i4)>=data.restBdryX(i5)*data.mPxXMIP;
            c21=data.triSprX{i3}(2,i4)<=data.restBdryX(i5)*data.mPxXMIP && data.triSprX{i3}(1,i4)>=data.restBdryX(i5)*data.mPxXMIP;
            c13=data.triSprX{i3}(1,i4)<=data.restBdryX(i5)*data.mPxXMIP && data.triSprX{i3}(3,i4)>=data.restBdryX(i5)*data.mPxXMIP;
            c31=data.triSprX{i3}(3,i4)<=data.restBdryX(i5)*data.mPxXMIP && data.triSprX{i3}(1,i4)>=data.restBdryX(i5)*data.mPxXMIP;
            c23=data.triSprX{i3}(2,i4)<=data.restBdryX(i5)*data.mPxXMIP && data.triSprX{i3}(3,i4)>=data.restBdryX(i5)*data.mPxXMIP;
            c32=data.triSprX{i3}(3,i4)<=data.restBdryX(i5)*data.mPxXMIP && data.triSprX{i3}(2,i4)>=data.restBdryX(i5)*data.mPxXMIP;
            
            % check to see if any verticies cross this boundary
            if any([c12 c21 c13 c31 c23 c32])==1
                
                % set the filtering parameter to 1 to mark filtered triangles
                data.rbFilt(i3,i4)=1;
                
                cntDFilt=cntDFilt+1;
            else
                % do nothing.  If it is marked above for any boundary, then
                % it is flagged for filtering.
            end
        end
    end
    
    % display the number of filtered strain rates.
    display(sprintf('%i elements crossed restricted boundary in frame %i',cntDFilt,i3));
end

%% Filter out strain rates, triangles, etc.

filtVec=any(data.rbFilt==1,1);

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
data.beta(:,filtVec)=[];
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

