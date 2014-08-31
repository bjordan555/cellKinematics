%% Detection of steps between either moving or fixed reference frame

function pathData=getFeatPath(pathDataIn,i2)

% dereference
numSt=pathDataIn.numSt;
MIPMaxX=pathDataIn.MIPMaxX;
MIPMaxY=pathDataIn.MIPMaxY;
stepX0Min=pathDataIn.stepX0Min;
stepY0Min=pathDataIn.stepY0Min;
stepX0Max=pathDataIn.stepX0Max;
stepY0Max=pathDataIn.stepY0Max;
winStepSzXPix=pathDataIn.winStepSzXPix;
winStepSzYPix=pathDataIn.winStepSzYPix;
stepXVec=pathDataIn.stepXVec;
stepYVec=pathDataIn.stepYVec;
MIPYLen=pathDataIn.MIPYLen;
MIPXLen=pathDataIn.MIPXLen;
cPrXMIP0=pathDataIn.cPrXMIP{1}(i2);
cPrYMIP0=pathDataIn.cPrYMIP{1}(i2);
imMIPFr=pathDataIn.imMIPFr;
PIVFrameON=pathDataIn.PIVFrameON;

% preallocate
pX=zeros(1,pathDataIn.numSt);
pY=zeros(1,pathDataIn.numSt);
stepX=zeros(1,pathDataIn.numSt);
stepY=zeros(1,pathDataIn.numSt);
SSD=cell(1,pathDataIn.numSt);
Rsq=cell(1,pathDataIn.numSt);
minX=zeros(1,pathDataIn.numSt);
minY=zeros(1,pathDataIn.numSt);
minRsq=zeros(1,pathDataIn.numSt);
minSSD=zeros(1,pathDataIn.numSt);

% initialize the logical value for whether or not the path was filtered on
% the previous frame
filtPrev=0;

for i3=1:1:numSt
    
   
    %% Determine the step between each set of frames
    if i3==1
       
        % use the fixed evaluation points as the position of each feature in first
        % frame, and use thsi plus the step for the position in next frame
        % use the integer valued starting positions for window matching.
        % For the first frame this is the same regardless of the reference
        % frame chosen
        pX(i3)=cPrXMIP0;
        pY(i3)=cPrYMIP0;
        
        % compute the relative position of the feature in the whole frame
        pXr=pX(i3)./MIPMaxX;
        pYr=pY(i3)./MIPMaxY;
        
        % set initial steps based on estimate of the initial velocity
        stepX(i3)=stepX0Min+round(pXr*(stepX0Max-stepX0Min));
        stepY(i3)=stepY0Min+round(pYr*(stepY0Max-stepY0Min));
        
        % set the derived measures for the first frame to default values
        SSD{i3}=zeros(winStepSzXPix,winStepSzYPix);
        Rsq{i3}=ones(winStepSzXPix,winStepSzYPix);
        minX(i3)=find(stepXVec==0);
        minY(i3)=find(stepYVec==0);
        minRsq(i3)=1;
        minSSD(i3)=0;
        
        
    else
        
        % dereference previous path coordinate and the step it took to
        % get there, i.e. the per-frame velocity in pixels
        % approximate the current path coordinate using the previous step, and search around it
        stepXAppr=stepXPrev;
        stepYAppr=stepYPrev;
        pXAppr=pXPrev+stepXAppr;
        pYAppr=pYPrev+stepYAppr;
        
        % get and reshape the image for the previous time frame
        imPrev=reshape(imMIPFr(i3-1,:,:),MIPYLen,MIPXLen);
        
        % get and reshape the current image
        imCur=reshape(imMIPFr(i3,:,:),MIPYLen,MIPXLen);
        
        %% Find displaced coords using window SSD method
        [SSDNew,RsqNew,minXNew,minYNew,minRsqNew,minSSDNew,stepXNew,stepYNew,filtPrev]=...
            windowSSD(pathDataIn, pXPrev, pYPrev, pXAppr, pYAppr, imPrev, imCur,i2,i3,filtPrev);
        
        % Assign the winning path and winning step away from the approximated
        if PIVFrameON==0
            pX(i3)=pXAppr+stepXNew;
            pY(i3)=pYAppr+stepYNew;
        else
            pX(i3)=cPrXMIP0;
            pY(i3)=cPrYMIP0;
        end
        
        stepX(i3)=stepXAppr+stepXNew;
        stepY(i3)=stepYAppr+stepYNew;
        
        % assign the stats to a structure for storage
        SSD{i3}=SSDNew;
        Rsq{i3}=RsqNew;
        minX(i3)=minXNew;
        minY(i3)=minYNew;
        minRsq(i3)=minRsqNew;
        minSSD(i3)=minSSDNew;
        
    end
    
    % Set the values of the path and step in this frame, for use in
    % the next frame when referencing this one, i.e. it is the
    % previous step in the next frame.
    pXPrev=pX(i3);
    pYPrev=pY(i3);
    stepXPrev=stepX(i3);
    stepYPrev=stepY(i3);
    
end

% % output filtering statistics every so often
% if mod(i2,30)==0
%     display(sprintf('Paths filtered thus far: %1.3f',cntFilt/i2));
% end

%% Assign the current paths and velocities to the data structure
% paths
pathData.pX=pX;
pathData.pY=pY;
pathData.stepX=stepX;
pathData.stepY=stepY;

% assigned above for matrix values of SSD and Rsq
pathData.SSD=SSD;
pathData.Rsq=Rsq;
pathData.minRsq=minRsq;
pathData.minSSD=minSSD;

% the locations of the minima in the SSD for SPR
pathData.minX=minX;
pathData.minY=minY;
