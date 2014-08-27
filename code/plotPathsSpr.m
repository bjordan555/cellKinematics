function plotPathsSpr(data)

% display algorithm step entry
display('Plotting SPR paths');

%% Plot of the paths by coordiante to compare pixel and subpixel
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);
clf;

%% plot of subpixel resolution paths by centroid
subplot(2,1,1);
cla;
hold on;

% sum the image series to show the tracers of each centroid
for i3=1:1:data.numSt
    
    % dereference the image
    im=reshape(data.imMIP(i3,:,:),data.MIPYLen,data.MIPXLen);
    
    if i3==1
        imSum=im;
    else
        %             imSum=imSum+data.flMIPNorm{i3};
        imSum=imSum+im;
    end
end

% normalize the summed image for display
imSumNorm=(imSum-min(min(imSum)))./(max(max(imSum))-min(min(imSum)));

% plot the summed image series
imagesc(imSumNorm);

caxis([0 1]);
set(gca,'YDir','normal')
colorbar;
colormap(gray);
set(gca,'YDir','normal')
axis([min(data.xMMIPVec) max(data.xMMIPVec) min(data.yMMIPVec) max(data.yMMIPVec)]);
axis equal
axis tight
xlabel('pSprX');
ylabel('pSprY');
title('Sub-pixel resolution paths');
view(2);
drawnow;

% plot the individual SPR paths
for i2=1:1:data.numPaths
    % the offset number labels on the paths
    text(data.pSprX(i2,1), data.pSprY(i2,1),[num2str(i2)],'HorizontalAlignment','center','Color','red','FontSize',8);
    
    % for each frame pair, show the path step.  In the case of the fixed reference
    % frame, all path steps start at same point. 
    for i3=1:1:data.numSt-1
        % create line vectors for plotting each path step
        xPlVec=[data.pSprX(i2,i3) data.pSprX(i2,i3)+data.stepSprX(i2,i3+1)];
        yPlVec=[data.pSprY(i2,i3) data.pSprY(i2,i3)+data.stepSprY(i2,i3+1)];
        
        % Pixel res paths
        plot(xPlVec,yPlVec,'.g');
        plot(xPlVec,yPlVec,'-b');
    end
end
drawnow;

pause(2.0);

%% plot of the individual SPR velocities

% vector of velocity time frames
vTfVec=1:1:size(data.vSprX,2);
% vector of velocity path numbers
vnVec=1:1:size(data.vSprX,1);
% mesh of above two vectors for plotting
[vTfMesh,vnMesh]=meshgrid(vTfVec,vnVec);

subplot(2,3,4)
cla;
hold on
imagesc(vTfVec,vnVec,data.vSprX);
hold off
title('Individual X SPR velocities');
xlabel('Time frame');
ylabel('Path #');
zlabel('vSprX (px/fr)');
set(gca,'YDir','normal')
colorbar;
colormap(gray);
view(2);

subplot(2,3,5)
cla;
hold on
imagesc(vTfVec,vnVec,data.vSprY);
hold off
title('Individual Y SPR velocities');
xlabel('Time frame');
ylabel('Path #');
zlabel('vSprX (px/fr)');
set(gca,'YDir','normal')
colorbar;
colormap(gray);
view(2);

% %% Plot of the maximizing R^2 for SPR by time frame and bead number
% % Note that centroid finding algorithm numbers paths from lower left to
% % upper right of screen.
% subplot(2,4,3)
% cla;
% imagesc(data.sprRsqX)
% xlabel('Time Frame');
% ylabel('Path #');
% title('Minimizing R^2 value for each SPR path step in X');
% set(gca,'YDir','normal')
% view(2)
% colorbar;
% colormap(gray);
% drawnow;
%
% subplot(2,4,4)
% cla;
% imagesc(data.sprRsqY)
% xlabel('Time Frame');
% ylabel('Path #');
% title('Minimizing R^2 value for each SPR path step in Y');
% set(gca,'YDir','normal')
% view(2)
% colorbar;
% colormap(gray);
% drawnow;





%% bivariate histogram of the sub-pixel resolution correction distance
subplot(2,3,6)
for i3=1:1:data.numSt
    
    % make bins for putting corrections into
    hist3([data.stepSprXCorr(:,i3) data.stepSprYCorr(:,i3)],[25 25]);
    xlabel('x-correction'); ylabel('y-correction');
    title(sprintf('Distribution of sub-pixel resolution corrections at frame %i',i3));
    % color the bars by height.
    % set(gcf,'renderer','opengl');
    % set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    pause(1);
    
    
end
drawnow;


pause(3)