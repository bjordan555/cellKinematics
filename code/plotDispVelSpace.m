function plotDispVelSpace(data)

% display algorithm step entry
display('Plotting velocity and displacement space');

% Plots of the velocities fitted linearly by coordinate
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);

% create the avi file
mov=avifile('./output/velFit.avi','compression','none','fps',1,'quality',100);

for i3=1:1:data.numSt
    clf;
    
    % dereference
    vSprX=data.vSprX(:,i3);
    vSprY=data.vSprY(:,i3);
    pSprX=data.pSprX(:,i3);
    pSprY=data.pSprY(:,i3);
    vX=data.vX(:,i3);
    vY=data.vY(:,i3);
    pX=data.pX(:,i3);
    pY=data.pY(:,i3);
    
    % find the extrema along x
    minpX=min(pSprX);
    maxpX=max(pSprX);
    
    options=fitoptions('poly1');
    type=fittype('poly1');
    
    % fit and plot the velocities in x
    [vXFitX gofvXFitX]=fit(pSprX,vSprX,type,options);
    [vYFitX gofvYFitX]=fit(pSprX,vSprY,type,options);
    
    % fit of the velocities in Y
    [vXFitY gofvXFitY]=fit(pSprY,vSprX,type,options);
    [vYFitY gofvYFitY]=fit(pSprY,vSprY,type,options);
    
    % plot of the fitted x-velocities along x
    subplot(1,2,1)
    hold on
    plot(vXFitX,'-b',pX,vX,'.b');
    plot(vXFitX,'-k',pSprX,vSprX,'.k');
    title(sprintf('Linear fit of vX in x-direction at t=%i',i3*data.tStepInc));
    legend('vSprX data', sprintf('vXFitX,p(x)=%fx+%f',vXFitX.p1,vXFitX.p2));
    xlabel('x (m)');
    ylabel('v (m/s)');
    
    % plot of the fitted y-velocities along x
    subplot(1,2,2)
    hold on
    plot(vYFitX,'-b',pX,vY,'.b');
    plot(vYFitX,'-k',pSprX,vSprY,'.k');
    title(sprintf('Linear fit of vY in x-direction at t=%i',i3*data.tStepInc));
    legend('vSprY data', sprintf('vYFitX,%fx+%f',vYFitX.p1,vYFitX.p2));
    xlabel('x (m)');
    ylabel('v (m/s)');
    
    drawnow;
    pause(1);
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
    
end
% close the file handle
mov=close(mov); % closes the mov

% play the movie
if data.playMoviesON==1
    implay('./output/velFit.avi');
end