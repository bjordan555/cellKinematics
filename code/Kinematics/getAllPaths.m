function data=getAllPaths(data)

% define width of restricted boundaries in image
data.restBdryXWidth=data.winSzPix/2;

% vector for the window
data.winVec=(-data.winSzPix/2):1:(data.winSzPix/2-1);

% vectors and sizes of steps
data.stepXVec=data.winStepXMin:1:data.winStepXMax;
data.stepYVec=data.winStepYMin:1:data.winStepYMax;
data.winStepSzXPix=length(data.stepXVec);
data.winStepSzYPix=length(data.stepYVec);

% display algorithm step entry
display('Finding paths by window matching with least-squares');

% loop over all time frames used
h=figure(1);
clf;
set(h,'Units','normalized','outerposition',data.guiSize);
hold on;
axis off;
drawnow;

% wait button
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Wait...','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imWait);

% preallocate
pX=zeros(data.numFeats,data.numSt);
pY=zeros(data.numFeats,data.numSt);
stepX=zeros(data.numFeats,data.numSt);
stepY=zeros(data.numFeats,data.numSt);
SSD=cell(data.numFeats,data.numSt);
Rsq=cell(data.numFeats,data.numSt);
minX=zeros(data.numFeats,data.numSt);
minY=zeros(data.numFeats,data.numSt);
minRsq=zeros(data.numFeats,data.numSt);
minSSD=zeros(data.numFeats,data.numSt);
pathData=cell(data.numFeats);

% dereference
numFeats=data.numFeats;

% dereference and reshape the PIV images
% get and reshape the image for the previous time frame. Put this into
% pathData structure for path detection.
imMIPFr=reshape(data.imMIP(:,:,:),data.numSt,data.MIPYLen,data.MIPXLen);
pathDataIn.imMIPFr=imMIPFr;

% Put it into pathData for passing into feature
% detection.  Reducing the size of the data set and reassembling the whole
% after the loop optimizes exectuion.
pathDataIn.numSt=data.numSt;
pathDataIn.MIPMaxX=data.MIPMaxX;
pathDataIn.MIPMaxY=data.MIPMaxY;
pathDataIn.stepX0Min=data.stepX0Min;
pathDataIn.stepY0Min=data.stepY0Min;
pathDataIn.stepX0Max=data.stepX0Max;
pathDataIn.stepY0Max=data.stepY0Max;
pathDataIn.winStepSzXPix=data.winStepSzXPix;
pathDataIn.winStepSzYPix=data.winStepSzYPix;
pathDataIn.stepXVec=data.stepXVec;
pathDataIn.stepYVec=data.stepYVec;
pathDataIn.MIPYLen=data.MIPYLen;
pathDataIn.MIPXLen=data.MIPXLen;
pathDataIn.cPrXMIP=data.cPrXMIP;
pathDataIn.cPrYMIP=data.cPrYMIP;
pathDataIn.winVec=data.winVec;
pathDataIn.stepXVec=data.stepXVec;
pathDataIn.stepYVec=data.stepYVec;
pathDataIn.restBdryX=data.restBdryX;
pathDataIn.restBdryXWidth=data.restBdryXWidth;
pathDataIn.MIPMinX=data.MIPMinX;
pathDataIn.MIPMaxX=data.MIPMaxX;
pathDataIn.MIPMinY=data.MIPMinY;
pathDataIn.MIPMaxY=data.MIPMaxY;
pathDataIn.RsqThWin=data.RsqThWin;
pathDataIn.PIVFrameON=data.PIVFrameON;

%% Create paths starting with each centroid in the first frame
if data.parOn~=0
    
    % initialize the parallelization pools in matlab. Note that plotting and
    % other reporting features from within the parfor loop are not active due
    % to MATLAB's parallel configuration.
    if data.parOn~=0
        display('Parallelization: Enabled');
        matlabpool(data.parOn);
    end

    parfor i2=1:numFeats

        % using parallel processors, track this features path in time in
        % either Langragian or Eulerian frame
        pathData{i2}=getFeatPath(pathDataIn,i2);
    end
    
    % close the parallel workers pool
    matlabpool close;
    
else
    for i2=1:data.numFeats
        
        % using parallel processors, track this features path in time in
        % either Langragian or Eulerian frame
        pathData{i2}=getFeatPath(pathDataIn,i2);
    end
end

%% assign the path data returned from the pathData structure to the global
%% data structure.
for i2=1:data.numFeats
    pX(i2,:)=pathData{i2}.pX;
    pY(i2,:)=pathData{i2}.pY;
    stepX(i2,:)=pathData{i2}.stepX;
    stepY(i2,:)=pathData{i2}.stepY;
    minX(i2,:)=pathData{i2}.minX;
    minY(i2,:)=pathData{i2}.minY;
    minRsq(i2,:)=pathData{i2}.minRsq;
    minSSD(i2,:)=pathData{i2}.minSSD;
    
    % loop over the number of time frames for the cell structs
    for i3=1:1:data.numSt
        SSD{i2,i3}=pathData{i2}.SSD{i3};
        Rsq{i2,i3}=pathData{i2}.Rsq{i3};
    end
end


%% Plot the results of the path detection

% Setup the figure for plotting while analyzing
h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);
clf;

% plots of the steps and minimizing R^2
for i3=1:1:data.numSt
    subplot(2,3,1)
    hold on
    plot(i3,stepX(:,i3)','.r');
    plot(i3,stepY(:,i3)','.b');
    title('steps per time frame');
    legend('stepX','stepY');
    
    subplot(2,3,2)
    hold on
    plot(i3,minRsq(:,i3)','.k');
    title('minRsq per time frame');
end
drawnow;

% % plots of the winning SSD, image windows, and residuals
% for i2=1:1:data.numFeats
%     for i3=1:1:data.numSt
% 
%         % When a fitted path is returned, plot some results
%         if ~isempty(SSD{i2,i3}) && i3~=1
%             
%             % Plot the SSD surface for each feature at each time step
%             subplot(2,3,3);
%             cla;
%             hold on
%             pcolor(data.stepXVec,data.stepYVec, SSD{i2,i3}');
%             plot(data.stepXVec(minX(i2,i3)),data.stepYVec(minY(i2,i3)),'.y');
%             shading interp
%             xlabel('x=cols=j'); ylabel('y=rows=i');
%             title(sprintf('SSD surface for path %i, frame %i',i2,i3));
%             axis tight
%             axis equal
%             colorbar
%             colormap(jet);
%             
%             
%             drawnow;
%             
%         end
%     end
% end

%% Assign the current paths, steps, and velocities to the data structure
% paths
data.pX=pX;
data.pY=pY;
data.stepX=stepX;
data.stepY=stepY;
data.vX=stepX;
data.vY=stepY;

% assigned above for matrix values of SSD and Rsq
data.SSD=SSD;
data.Rsq=Rsq;
data.minRsq=minRsq;
data.minSSD=minSSD;

% the locations of the minima in the SSD for SPR
data.minX=minX;
data.minY=minY;

%% Next button GUI
% pause or wait for continue
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Next','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imNext);

% wait for the user
uiwait(gcf);

end

%% ---- implicit function for Next Button
function imNext(hObj,event,ax)

uiresume(gcbf);
end

%% ---- implicit function for Wait Button
function imWait(hObj,event,ax)
% do nothing
end


