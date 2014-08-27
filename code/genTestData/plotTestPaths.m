function plotTestPaths(cXStSpr,cYStSpr,cZStSpr,sprF,lXSpr,SSpr,rNSprBar)


% display algorithm step entry
display('Plotting test data paths');

%% plot of the time series of points in 3D
figure(347883443);
clf;
hold on;
for i1=1:1:size(cXStSpr,2)
    plot3(cXStSpr(:,i1),cYStSpr(:,i1),cZStSpr(:,i1),'.k');
    axis equal;
    axis tight
    title(sprintf('Points at SPR in frame %i',i1));
    drawnow;
    pause(0.25);
end
hold off;

% % plot the top (max) and bottom (min) radii, and generator in the above figure
% for i1=1:1:size(cXStSpr,2)
%     hold on
%
%     xCrv=[1 lXSpr];
%     yMin=[SSpr-rNSprBar(i1) SSpr-rNSprBar(i1)];
%     yMax=[SSpr+rNSprBar(i1) SSpr+rNSprBar(i1)];
%     yMid=[SSpr SSpr];
%
%     hold on
%     plot(xCrv, yMin,'--r');
%     plot(xCrv, yMax,'--r');
%     plot(xCrv, yMid,'--r');
%     hold off
%
%     drawnow;
%
% end


% divide into the PR scale, with non-integer values
cXPr=cXStSpr./sprF;
cYPr=cYStSpr./sprF;

%% sorting of paths
% no sorting
cXPrSort=cXPr;
cYPrSort=cYPr;

% BEN - BROKEN % sort the paths into ascending by X coordinate
% [cXPrSort idxX]=sort(cXStPr,1);
% cYPrSort=cYStPr(idxX);

%% plot of the individual PR paths

% vector of path time frames
pTfVec=1:1:size(cXPrSort,2);
% vector of path numbers
pnVec=1:1:size(cXPrSort,1);
% mesh of above two vectors for plotting
[pTfMesh,pnMesh]=meshgrid(pTfVec,pnVec);

figure(86995309);
clf;
hold on
%     surf(pTfMesh,pnMesh,cXPrSort);
imagesc(pTfVec,pnVec,cXPrSort);
hold off
title('Individual X PR-scale paths');
xlabel('Time frame');
ylabel('Path #');
zlabel('pX');
set(gca,'YDir','normal')
colorbar;
colormap(jet);
view(2);

figure(8675310);
cla;
hold on
%     surf(pTfMesh,pnMesh,cYPrSort);
imagesc(pTfVec,pnVec,cYPrSort);
hold off
title('Individual Y PR-scale paths');
xlabel('Time frame');
ylabel('Path #');
zlabel('pY');
set(gca,'YDir','normal')
colorbar;
colormap(jet);
view(2);

% Compute the velocities from the paths
vXPrSort=diff(cXPrSort,1,2);
vYPrSort=diff(cYPrSort,1,2);

%% plot of the individual PR velocities
% vector of path time frames
vTfVec=1:1:size(vXPrSort,2);
% vector of path numbers
vnVec=1:1:size(vXPrSort,1);
% mesh of above two vectors for plotting
[vTfMesh,vnMesh]=meshgrid(vTfVec,vnVec);

figure(86995409);
cla;
hold on
%     surf(vTfMesh,vnMesh,vXPrSort);
imagesc(vTfVec,vnVec,vXPrSort);
hold off
title('Individual X PR-scale velocities');
xlabel('Time frame');
ylabel('Path #');
zlabel('vX');
set(gca,'YDir','normal')
colorbar;
colormap(jet);
view(2);

figure(8675410);
cla;
hold on
%     surf(vTfMesh,vnMesh,vYPrSort);
imagesc(vTfVec,vnVec,vYPrSort);
hold off
title('Individual Y PR-scale velocities');
xlabel('Time frame');
ylabel('Path #');
zlabel('vY');
set(gca,'YDir','normal')
colorbar;
colormap(jet);
view(2);

