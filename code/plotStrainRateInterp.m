function data = plotStrainRateInterp(data)

% display algorithm step entry
display('Plotting the interpolated strain rates');

% dereference the maximum and minumum path positions for plotting
pXMin=min(min(data.pSprX));
pXMax=max(max(data.pSprX));
pYMin=min(min(data.pSprY));
pYMax=max(max(data.pSprY));

% dereference and compute extrema of all interpolated strain rates
for i1=2:1:data.numSt
    dXMinVec(i1)=min(min(data.dXInterp{i1})); 
    dXMaxVec(i1)=max(max(data.dXInterp{i1})); 
    dYMinVec(i1)=min(min(data.dYInterp{i1})); 
    dYMaxVec(i1)=max(max(data.dYInterp{i1})); 
    dXYMinVec(i1)=min(min(data.dXYInterp{i1})); 
    dXYMaxVec(i1)=max(max(data.dXYInterp{i1})); 
end
dXMin=min(dXMinVec);
dXMax=min(dXMaxVec);
dYMin=min(dYMinVec);
dYMax=min(dYMaxVec);
dXYMin=min(dXYMinVec);
dXYMax=min(dXYMaxVec);
dMin=min([dXMin dYMin dXYMin]);
dMax=max([dXMax dYMax dXYMax]);

% create the mesh grid for plotting the interpolated velocities
xVec=linspace(pXMin,pXMax,data.vGridDX);
yVec=linspace(pYMin,pYMax,data.vGridDX);
[xGrid yGrid]=meshgrid(xVec,yVec);

%% Plots of the strain rate fields

h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);
clf;
% create the avi file
mov=avifile('./output/dInterp.avi','compression','none','fps',1,'quality',100);


% loop for each path step in each time frame
for i3=2:1:data.numSt
    
    %% dXInterp
    subplot(3,1,1);
    % evaluate the interpolant at the points in the grid
    zGrid=data.dXInterp{i3};
    
    % plot the interpolated surface
    surf(xGrid,yGrid,zGrid,'EdgeColor','none','FaceColor','interp');
    
    % configure figure and axes
    caxis([dXMin dXMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','dXInterp',i3));
    set(gca,'YDir','normal')
    axis([pXMin pXMax pYMin pYMax]);
    axis equal
%     axis tight
    axis off
    xlabel('m');
    ylabel('m');
    view(2);
    
    
    %% dYInterp
    subplot(3,1,2);
    % evaluate the interpolant at the points in the grid
    zGrid=data.dYInterp{i3};
    
    % plot the interpolated surface
    surf(xGrid,yGrid,zGrid,'EdgeColor','none','FaceColor','interp');
    
    % configure figure and axes
    caxis([dYMin dYMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','dYInterp',i3));
    set(gca,'YDir','normal')
    axis([pXMin pXMax pYMin pYMax]);
    axis equal
%     axis tight
    axis off
    xlabel('m');
    ylabel('m');
    view(2);
    
    
    %% dXYInterp
    subplot(3,1,3);
    % evaluate the interpolant at the points in the grid
    zGrid=data.dXYInterp{i3};
    
    % plot the interpolated surface
    surf(xGrid,yGrid,zGrid,'EdgeColor','none','FaceColor','interp');
    
    % configure figure and axes
    caxis([dXYMin dXYMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','dXYInterp',i3));
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

% play the movie
if data.playMoviesON==1
    implay('./output/dInterp.avi');
end