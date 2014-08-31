function data = plotVelInterp(data)

% display algorithm step entry
display('Plotting the interpolated velocities');

% dereference the maximum and minumum path positions for plotting
pXMin=min(min(data.pSprX));
pXMax=max(max(data.pSprX));
pYMin=min(min(data.pSprY));
pYMax=max(max(data.pSprY));

% dereference and compute extrema of all velocities
vXMin=min(min(data.vSprX));
vXMax=max(max(data.vSprX));
vYMin=min(min(data.vSprY));
vYMax=max(max(data.vSprY));
vMin=min([vXMin vYMin]);
vMax=max([vXMax vYMax]);
    
% create the mesh grid for plotting the interpolated velocities
xVec=linspace(pXMin,pXMax,data.vGridDX);
yVec=linspace(pYMin,pYMax,data.vGridDX);
[xGrid yGrid]=meshgrid(xVec,yVec);

%% Plots of the velocity field

h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);

% create the avi file
mov=avifile('./output/vSprInterp.avi','compression','none','fps',1,'quality',100);

% loop for each path step in each time frame
for i3=1:1:data.numSt

    %% vSprX
    subplot(2,1,1);
    
%     % plot the interpolated surface
%     surf(xGrid,yGrid,data.vXInterp{i3},'EdgeColor','none','FaceColor','interp');
    
    % plot the interpolated surface
    trisurf(data.pathTriRepSpr{i3}.Triangulation,data.pathTriRepSpr{i3}.X(:,1), ...
        data.pathTriRepSpr{i3}.X(:,2),data.vXInterp(:,i3),...
        'EdgeColor','none','FaceAlpha',1,'FaceColor','interp');
    
    % configure figure and axes
    caxis([vXMin vXMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','vSprXInterp',i3));
    set(gca,'YDir','normal')
    axis([pXMin pXMax pYMin pYMax]);
    axis equal
%     axis tight
    axis off
    xlabel('m');
    ylabel('m');
    view(2);
    
    
    %% vSprY
    subplot(2,1,2);
%     
%     % plot the interpolated surface
%     surf(xGrid,yGrid,data.vYInterp{i3},'EdgeColor','none','FaceColor','interp');

    % plot the interpolated surface
    trisurf(data.pathTriRepSpr{i3}.Triangulation,data.pathTriRepSpr{i3}.X(:,1), ...
        data.pathTriRepSpr{i3}.X(:,2),data.vYInterp(:,i3),...
        'EdgeColor','none','FaceAlpha',1,'FaceColor','interp');
    
    % configure figure and axes
    caxis([vYMin vYMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','vSprYInterp',i3));
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
    implay('./output/vSprInterp.avi');
end