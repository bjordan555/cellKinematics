function data = plotStrainRateSVDInterp(data)

% display algorithm step entry
display('Plotting the interpolated SVD strain rates');

% dereference the maximum and minumum path positions for plotting
pXMin=min(min(data.pSprX));
pXMax=max(max(data.pSprX));
pYMin=min(min(data.pSprY));
pYMax=max(max(data.pSprY));

% % dereference and compute extrema of all interpolated strain rates
% dXMin=min(min(data.dXSVDInterp));
% dXMax=max(max(data.dXSVDInterp));
% dYMin=min(min(data.dYSVDInterp));
% dYMax=max(max(data.dYSVDInterp));
% dXYMin=min(min(data.dXYSVDInterp));
% dXYMax=max(max(data.dXYSVDInterp));

% dereference and compute extrema of all interpolated strain rates
for i3=1:1:data.numSt-1
    dXMin=min(min(data.dXSVDInterp{i3}));
    dXMax=max(max(data.dXSVDInterp{i3}));
    dYMin=min(min(data.dYSVDInterp{i3}));
    dYMax=max(max(data.dYSVDInterp{i3}));
    dXYMin=min(min(data.dXYSVDInterp{i3}));
    dXYMax=max(max(data.dXYSVDInterp{i3}));
end
dMin=min([dXMin dYMin dXYMin]);
dMax=max([dXMax dYMax dXYMax]);

% create the mesh grid for plotting the interpolated velocities
xVec=linspace(pXMin,pXMax,data.vGridDX);
yVec=linspace(pYMin,pYMax,data.vGridDX);
[xGrid yGrid]=meshgrid(xVec,yVec);

%% Plots of the velocity field

% make a figure for ROI display and selection by user
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);

% create the avi file
mov=avifile('./output/dSVDInterp.avi','compression','none','fps',1,'quality',100);

% loop for each path step in each time frame
for i3=1:1:data.numSt-1

    %% dX
    subplot(3,1,1);
    
%     % plot the interpolated surface
%     trisurf(data.pathTriRepSpr{i3}.Triangulation,data.pathTriRepSpr{i3}.X(:,1), ...
%         data.pathTriRepSpr{i3}.X(:,2),data.dXSVDInterp(:,i3),...
%         'EdgeColor','none','FaceAlpha',1,'FaceColor','interp');
    
    % evaluate the interpolant at the points in the grid
    zGrid=data.dXSVDInterp{i3};
    
    % plot the interpolated surface
    surf(xGrid,yGrid,zGrid,'EdgeColor','none','FaceColor','interp');
    
    % configure figure and axes
    caxis([dXMin dXMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','dXSVDInterp',i3));
    set(gca,'YDir','normal')
    axis([pXMin pXMax pYMin pYMax]);
    axis equal
%     axis tight
    axis off
    xlabel('m');
    ylabel('m');
    view(2);
    
     %% dY
    subplot(3,1,2);
    
%         % plot the interpolated surface
%     trisurf(data.pathTriRepSpr{i3}.Triangulation,data.pathTriRepSpr{i3}.X(:,1), ...
%         data.pathTriRepSpr{i3}.X(:,2),data.dYSVDInterp(:,i3),...
%         'EdgeColor','none','FaceAlpha',1,'FaceColor','interp');
    
    % evaluate the interpolant at the points in the grid
    zGrid=data.dYSVDInterp{i3};
    
    % plot the interpolated surface
    surf(xGrid,yGrid,zGrid,'EdgeColor','none','FaceColor','interp');
    
    % configure figure and axes
    caxis([dYMin dYMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','dYSVDInterp',i3));
    set(gca,'YDir','normal')
    axis([pXMin pXMax pYMin pYMax]);
     axis equal
%     axis tight
    axis off
    xlabel('m');
    ylabel('m');
    view(2);
    
     %% dXY
    subplot(3,1,3);
    
%     % plot the interpolated surface
%     trisurf(data.pathTriRepSpr{i3}.Triangulation,data.pathTriRepSpr{i3}.X(:,1), ...
%         data.pathTriRepSpr{i3}.X(:,2),data.dXYSVDInterp(:,i3),...
%         'EdgeColor','none','FaceAlpha',1,'FaceColor','interp');
    
    % evaluate the interpolant at the points in the grid
    zGrid=data.dXYSVDInterp{i3};
    
    % plot the interpolated surface
    surf(xGrid,yGrid,zGrid,'EdgeColor','none','FaceColor','interp');
    
    % configure figure and axes
    caxis([dXYMin dXYMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','dXYSVDInterp',i3));
    set(gca,'YDir','normal')
    axis([pXMin pXMax pYMin pYMax]);
     axis equal
%     axis tight
    axis off
    xlabel('m');
    ylabel('m');
    view(2);
    
    
    drawnow;
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
end

% close the file handle
mov=close(mov); % closes the mov

% Play the movie
if data.playMoviesON==1
    implay('./output/dSVDInterp.avi');
end
