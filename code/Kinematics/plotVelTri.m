%% Function to plot the velocities at the SPR path steps.  The SPR path
%% path steps are the PR path steps in Eulerian=PIV mode
function data = plotVelTri(data)

% display algorithm step entry
display('Plotting the velocities');

% dereference the maximum and minumum path positions for plotting
pSprXMin=min(min(data.pSprX));
pSprXMax=max(max(data.pSprX));
pSprYMin=min(min(data.pSprY));
pSprYMax=max(max(data.pSprY));

% dereference and compute extrema of all velocities
vXMin=min(min(data.vSprX));
vXMax=max(max(data.vSprX));
vYMin=min(min(data.vSprY));
vYMax=max(max(data.vSprY));
vMin=min([vXMin vYMin]);
vMax=max([vXMax vYMax]);

%% Plots of the velocity field on the SPR triangulation

% make a figure for ROI display and selection by user
h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);
clf;

% create the avi file
mov=avifile('./output/vSpr.avi','compression','none','fps',1,'quality',100);

% loop for each path step in each time frame
for i3=1:1:data.numSt
    
    % vSprX
    subplot(2,1,1);
    cla;
    
    % plot of the  X- or Y- velocities of each triangle
    trisurf(data.pathTriRepSpr{i3}.Triangulation,data.pathTriRepSpr{i3}.X(:,1), ...
        data.pathTriRepSpr{i3}.X(:,2),data.vSprX(:,i3),...
        'EdgeColor','none','FaceAlpha',1,'FaceColor','interp');
    % configure figure and axes
     caxis([vXMin vXMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','vSprX',i3));
    xlabel('m');
    ylabel('m');
    axis off;
    daspect([1 1 1]);
    axis([pSprXMin pSprXMax pSprYMin pSprYMax]);
    view(2);
    
    % vSprY
    subplot(2,1,2);
    cla;
    
    % plot of the  X- or Y- velocities of each triangle
    trisurf(data.pathTriRepSpr{i3}.Triangulation,data.pathTriRepSpr{i3}.X(:,1), ...
        data.pathTriRepSpr{i3}.X(:,2),data.vSprY(:,i3),...
        'EdgeColor','none','FaceAlpha',1,'FaceColor','interp');
    
    % configure the figure and axes
    caxis([vYMin vYMax]);
    colormap(jet)
    colorbar
    title(sprintf('%s, frame=%i','vSprY',i3));
    xlabel('m');
    ylabel('m');
    axis off
    daspect([1 1 1]);
    axis([pSprXMin pSprXMax pSprYMin pSprYMax]);
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
    implay('./output/vSpr.avi')
end

%% Quiver plot of the velocity field

% make a figure for ROI display and selection by user
h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);

% create the avi file
mov=avifile('./output/vSprQuiver.avi','compression','none','fps',1,'quality',100);

% loop for each path step in each time frame
% 
for i3=1:1:data.numSt
    
    clf;
    % get the first time frames for the channel used for PIV

    % load the MIP images
    im=reshape(data.imMIP(i3,:,:),data.MIPYLen,data.MIPXLen);
    imagesc(data.xMMIPVec,data.yMMIPVec,im);
    set(gca,'YDir','normal');
    hold on;
    % quiver plot of the velocity field
    % scale x and y velocities for plotting
    xvSc=(10*pSprXMax/data.winSzPix)*data.vSprX(:,i3)./vMax;
    yvSc=(10*pSprXMax/data.winSzPix)*data.vSprY(:,i3)./vMax;
    
    quiver(data.pathTriRepSpr{i3}.X(:,1),data.pathTriRepSpr{i3}.X(:,2),...
        xvSc,yvSc,0,'-y');
    
    % configure figure and axes
    title(sprintf('%s, frame=%i','vSpr',i3));
    xlabel('m');
    ylabel('m');
    colormap(gray);
    axis off;
    daspect([1 1 1]);
    axis(data.pROIVec);
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
    implay('./output/vSprQuiver.avi')
end