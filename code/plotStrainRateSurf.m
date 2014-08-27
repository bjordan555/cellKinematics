function plotStrainRateSurf(data)

% dereference the maximum and minumum path positions for plotting
pSprXMin=min(min(data.pSprX));
pSprXMax=max(max(data.pSprX));
pSprYMin=min(min(data.pSprY));
pSprYMax=max(max(data.pSprY));

% dereference and compute extrema of all strain rates
dXMin=min(min(data.dX)); 
dXMax=max(max(data.dX)); 
dYMin=min(min(data.dY)); 
dYMax=max(max(data.dY)); 
dXYMin=min(min(data.dXY)); 
dXYMax=max(max(data.dXY)); 

dMin=min([dXMin dYMin dXYMin]); 
dMax=max([dXMax dYMax dXYMax]); 

%% Plots of the strain rates

% loop for each path step in each time frame
h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);
clf;

% create the avi file
mov=avifile('./output/strainRatesd.avi','compression','none','fps',1,'quality',100);

for i3=1:1:data.numSt-1
    
        % dX
    subplot(3,1,1)
    cla;
    % plot the strain on the triangulation
    patch(data.triX{i3}(:,:),data.triY{i3}(:,:),data.dX(i3,:),'EdgeColor','none');
    
    title(sprintf('%s at frame=%i','dX',i3));
    xlabel('px');
    ylabel('px');
    
    % configure axes
    caxis([dXMin dXMax]);
    colormap(jet)
    colorbar
    axis([pSprXMin pSprXMax pSprYMin pSprYMax]);
%     axis tight
     axis equal    
    axis off
    view(2);
       
    % dY
    
    subplot(3,1,2)
    cla;
    % plot the strain on the triangulation
    patch(data.triX{i3}(:,:),data.triY{i3}(:,:),data.dY(i3,:),'EdgeColor','none');

    
    title(sprintf('%s at frame=%i','dY',i3));
    xlabel('px');
    ylabel('px');
    
    % configure axes
    caxis([dXMin dXMax]);
    colormap(jet)
    colorbar
    axis([pSprXMin pSprXMax pSprYMin pSprYMax]);
%     axis tight
     axis equal
    axis off
    view(2);
    
    
    % dXY
    
    subplot(3,1,3)
    cla;
    % plot the strain on the triangulation
    patch(data.triX{i3}(:,:),data.triY{i3}(:,:),data.dXY(i3,:),'EdgeColor','none');
    
    
    title(sprintf('%s at frame=%i','dXY',i3));
    xlabel('px');
    ylabel('px');
    
    % configure axes
    caxis([dXYMin dXYMax]);
    colormap(jet)
    colorbar
    axis([pSprXMin pSprXMax pSprYMin pSprYMax]);
%     axis tight
     axis equal
    axis off
    view(2);
    
    drawnow;
    pause(0.25);
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
    
end

% close the file handle
mov=close(mov); % closes the mov

if data.playMoviesON==1
    implay('./output/strainRatesd.avi');
end
