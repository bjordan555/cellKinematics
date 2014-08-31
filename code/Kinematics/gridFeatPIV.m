%% Function to create a regular grid of evenly spaced points as starting
%% locations for paths. 
% For the window matching PIV algorithm, a pattern within a window is
% matched forward in time. In some instances, it is useful to analyze a set
% of features determined by the centroid of some actual object, such as in
% cell and tissue mechanics, or anywhere that the physical structures
% location is relevant to the underlying velocity field. In the case of a
% randomly placed set of marker particles, the actual location of the
% markers themselves don't have meaning w.r.t. the field being analyzed,
% other than that they move with it. In this case, a regularly spaced set
% of evaluation points is useful.  Evenly spaced grids also have the
% advantage that the strain rate field, as determined by the linear
% transformation of the triangulation, is guaranteed to be evenly weighted
% amongst the triangles, as their size and aspect ratios start as equal.

function data=gridFeatPIV(data)

% Regular grid of evaluation points (hlaf the window size implies average
% of half the window areas overlapping
data.evalGriddX=data.winSzPix/2;
data.evalGriddY=data.winSzPix/2;

%% Create the vectors of evenly spaced path starting locations
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);
clf;

% setup vectors for extracting only bw image in ROI
pXROIVec=round(data.pXMinROI/data.mPxXMIP):1:round(data.pXMaxROI/data.mPxXMIP);
pYROIVec=round(data.pYMinROI/data.mPxYMIP):1:round(data.pYMaxROI/data.mPxYMIP);

% use the gamma corrected MIP for finding beads
im=reshape(data.imMIP(1,pYROIVec,pXROIVec),length(pYROIVec),length(pXROIVec));

% plot of the image in the ROI
subplot(2,1,2)
imagesc(pXROIVec,pYROIVec,im);
set(gca,'YDir','normal');
colormap(gray);
% equalize the axis scales
 axis equal
% remove outside whitespace from axes
axis tight
% set the axis using the ROI
xlabel('px');
ylabel('px');
view(2);
drawnow;

% compute the number of evaluation points based on distance between
% evaluation points from parameters. 
evalGridNX=round((data.pXMaxROI/data.mPxXMIP-data.pXMinROI/data.mPxXMIP)./data.evalGriddX);
evalGridNY=round((data.pYMaxROI/data.mPxYMIP-data.pYMinROI/data.mPxYMIP)./data.evalGriddY);

% setup vectors of evenly spaced evaluation points in ROI
xEROIVec=round(linspace((data.pXMinROI/data.mPxXMIP),data.pXMaxROI/data.mPxXMIP,evalGridNX));
yEROIVec=round(linspace((data.pYMinROI/data.mPxYMIP),data.pYMaxROI/data.mPxYMIP,evalGridNY));

% make a grid using the regularly spaced evaluation points in the above
% vector, and make a vector containing all points in the grid
[xGr,yGr]=meshgrid(xEROIVec,yEROIVec);
xGrVec=reshape(xGr,evalGridNX*evalGridNY,1);
yGrVec=reshape(yGr,evalGridNX*evalGridNY,1);
 
% set the starting values to be the points in the above vectors.  The
% regular gruid is defined at the pixel values, so there is no difference
% between the PR starting paths and the SPR starting paths.  In
% findFeatPIV.m, the SPR values detected by centroid are saved separately. 
cXMIP{1}=xGrVec;
cYMIP{1}=yGrVec;
cPrXMIP{1}=xGrVec;
cPrYMIP{1}=yGrVec;

%% report centroid stats
numFeats(1)=length(cXMIP{1});
display(sprintf('%i evaluation points in time frame %i',numFeats(1),1));

% Triangulate the gridded features
cFiltTri=delaunay(cXMIP{1},cYMIP{1});

% Plot the triangulated grid
subplot(2,1,1)
trimesh(cFiltTri,cXMIP{1},cYMIP{1});
title(sprintf('Gridded feature triangulations at frame=%i',1));
axis equal
axis tight
colormap(gray)
view(2)
%         pause(0.1)
drawnow;

% save the figure as a tif
print('-depsc2','-painters','./output/evalGrid.eps');

%% plot centroids in the ROI on the entire image in 2D

subplot(2,1,2)
hold on;
% the centroids
plot(cXMIP{1},cYMIP{1},'g.');

% the integer valued centroids
%     plot(cPrXMIP{1},cPrYMIP{1},'r.');

% plot the number labels on the centroids
for i2=1:1:numFeats(1)
    
    % the number labels on the MIP centroids
    text(cPrXMIP{1}(i2),cPrYMIP{1}(i2),[num2str(i2)],'HorizontalAlignment','center','Color',[0.75 1 0.5],'FontSize',7);
end
drawnow;

pause(4);

%% store centroid information with the data structure
data.numFeats=numFeats;
data.cXMIP=cXMIP;
data.cYMIP=cYMIP;
data.cPrXMIP=cPrXMIP;
data.cPrYMIP=cPrYMIP;