%% Detect the features in the first image
function data=findPIVFeat(data)

% minimum and maximum bead radius and area
data.beadMaxArea=pi*data.beadMaxRad^2;
data.beadMinArea=pi*data.beadMinRad^2;

% loop over all the time frames
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);
clf;

% setup vectors for extracting only bw image in ROI
pXROIVec=round(data.pXMinROI/data.mPxXMIP):1:round(data.pXMaxROI/data.mPxXMIP);
pYROIVec=round(data.pYMinROI/data.mPxYMIP):1:round(data.pYMaxROI/data.mPxYMIP);

% use the gamma corrected MIP for finding beads
im=reshape(data.imMIPGamma(1,pYROIVec,pXROIVec),length(pYROIVec),length(pXROIVec));

% compute the binary image by thresholding
level = graythresh(im);
bw = im2bw(im,level);
%     bw = bwareaopen(bw, 50);

% plot of the binary image used for centroid detection
subplot(1,1,1)
imagesc(pXROIVec.*data.mPxXMIP,pYROIVec.*data.mPxYMIP,bw);
set(gca,'YDir','normal');
colormap(jet);
colorbar
% equalize the axis scales
axis equal
% remove outside whitespace from axes
axis tight
% set the axis using the ROI
axis(data.pROIVec);
xlabel('m');
ylabel('m');
view(2);

% find the beads
cc = bwconncomp(bw, data.beadConn);

% delete objects larger than beadMaxArea or smaller than beadMinArea
numPixels = cellfun(@numel,cc.PixelIdxList);
idxMax= find(numPixels>=data.beadMaxArea);
idxMin= find(numPixels<=data.beadMinArea);

% filter out empty entries created above from pixel index list
cnt=0;
clear PixelIdxList

for i2=1:1:cc.NumObjects
    if isempty(find(idxMax==i2)) || isempty(find(idxMin==i2))
        cnt=cnt+1;
        PixelIdxList{cnt} = cc.PixelIdxList{i2};
    end
end

% Create and populate the filtered connected components structure
ccFilt.PixelIdxList=PixelIdxList;
ccFilt.NumObjects=cnt;
ccFilt.Connectivity=cc.Connectivity;
ccFilt.ImageSize=cc.ImageSize;

% compute and the centroids of the objects and store as matrix in cell
cTmp= regionprops(ccFilt,'Centroid');
cents=cat(1,cTmp.Centroid);

% make centroids into x and y vectors representation
cXMIP{1}=cents(:,1);
cYMIP{1}=cents(:,2);


% note that cXPix and cYPix are doubles, not integers.
% Using floor to round down since minimum value is 1.
% Also subtracting 1 because we are in pixel coords [1,Inf]x[1,Inf]=XxY
cPrXMIP{1}=floor(cents(:,1));
cPrYMIP{1}=floor(cents(:,2));

% offset the centroids back into the ROI from the detection image
cXMIP{1}=cXMIP{1}+min(pXROIVec);
cYMIP{1}=cYMIP{1}+min(pYROIVec);
cPrXMIP{1}=cPrXMIP{1}+min(pXROIVec);
cPrYMIP{1}=cPrYMIP{1}+min(pYROIVec);

%% report centroid stats
numFeats(1)=length(cXMIP{1});
display(sprintf('%i features in time frame %i',numFeats(1),1));

% ratio of ROI to window size
roiXLPx=(data.pXMaxROI-data.pXMinROI)./data.mPxXMIP;
roiYLPx=(data.pYMaxROI-data.pYMinROI)./data.mPxYMIP;
winImRat=round((roiXLPx*roiYLPx)./data.winSzPix^2);

% display the statsitics about features, image and window size.
display(sprintf('Average # of features per window in ROI is: %1.3f',numFeats(1)/winImRat));

%% plot centroids in the ROI on the entire image in 2D
hold on
% use the gamma corrected MIP for finding beads
im=reshape(data.imMIPGamma(1,:,:),data.MIPYLen,data.MIPXLen);

% the image object is a 2D image, in microns
imagesc(data.xPxMIPVec,data.yPxMIPVec ,im);

% the centroids
plot(cXMIP{1},cYMIP{1},'g.');

% the integer valued centroids
%     plot(cPrXMIP{1},cPrYMIP{1},'r.');

% plot the number labels on the centroids
for i2=1:1:numFeats(1)
    
    % the number labels on the MIP centroids
    text(cPrXMIP{1}(i2),cPrYMIP{1}(i2),[num2str(i2)],'HorizontalAlignment','center','Color',[0.75 1 0.5],'FontSize',7);
end
set(gca,'YDir','normal')
colormap(gray);
colorbar
caxis([0 1]);
axis equal
axis tight
xlabel('px');
ylabel('px');
title('Detected features');
view(2);
drawnow;

% display the remaining paths
display(sprintf('%i features',numFeats));

%% store centroid information with the data structure
data.numFeats=numFeats;
data.cXMIP=cXMIP;
data.cYMIP=cYMIP;
data.cPrXMIP=cPrXMIP;
data.cPrYMIP=cPrYMIP;
