function data = plotTriQual(data)

% Plots the animation of the triangulation quality.  Only performed if the
% Lagrangian mode is on, in which a set of points forming the mesh are
% tracked. 

if data.PIVFrameON==0
    % display algorithm step entry
    display('Plotting triangulation quality');
    
    % dereference the maximum and minumum path positions for plotting
    pSprXMin=min(min(data.pSprX));
    pSprXMax=max(max(data.pSprX));
    pSprYMin=min(min(data.pSprY));
    pSprYMax=max(max(data.pSprY));
    
    %% Plots of the mesh quality field using the PR triangulation
    
    % loop for each path step in each time frame
    h=figure(1);
    set(h,'units','normalized','outerposition',data.guiSize);
    clf;
    
    % create the avi file
    mov=avifile('./output/raQual.avi','compression','none','fps',1,'quality',100);
    
    % display algorithm step entry
    display(sprintf('Plotting %s surface time series','raQual'));
    
    for i3=1:1:data.numSt-1
        
        % clear the figure at each time step
        cla;
        
        % plot the mesh quality on the triangulation
        patch(data.triX{i3}(:,:),data.triY{i3}(:,:),data.raQual(i3,:))
        
        title(sprintf('%s at frame=%i','raQual',i3));
        xlabel('px');
        ylabel('px');
        
        % configure axes
        caxis([min(min(data.raQual)) data.raQualTh]);
        colormap(jet)
        colorbar
        axis([pSprXMin pSprXMax pSprYMin pSprYMax]);
        axis tight
        axis equal
        axis off
        view(2);
        
        drawnow;
        pause(1);
        
        % grab and store the movie frame
        f2=getframe(gcf); % gets the gcf
        mov=addframe(mov,f2); % adds the frame into mov
        
    end
    
    % close the file handle
    mov=close(mov); % closes the mov
    
    if data.playMoviesON==1
        implay('./output/raQual.avi')
    end
    
end