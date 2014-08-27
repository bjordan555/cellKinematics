%% Visualize stack
function data=visImSt(data)


% setup the figures
h=figure(1);
set(h,'Units','normalized','outerposition',data.guiSize);

% wait button
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Wait...','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imWait);

% create the avi file
mov=avifile('./output/visImSt.avi','compression','none','fps',4,'quality',100);

% loop over all time frames
for i1=1:1:data.numSt
    clf;
    % plot of the YZ slices
    
    % set slice position
    yzSlXPos=floor(data.stXLen/2);
    
    % reshape the image into a 2D array at a particular X
    imYZ=reshape(data.imSt(i1,:,:,yzSlXPos),data.numSl,data.stYLen);
    
    % plot image in X,Y coords in units of meters
    subplot(1,2,1);
    cla;
    imagesc(data.yMStVec,data.zMStVec,imYZ);
    set(gca,'YDir','normal')
    colormap(gray);
    axis([min(data.yMStVec) max(data.yMStVec) min(data.zMStVec) max(data.zMStVec)]);
    axis image
    axis tight
    xlabel('y [m]');
    ylabel('z [m]');
    title(sprintf('Frame %i, Channel %i, YZ-Slice X-Pos %i',i1,data.chGeom,yzSlXPos));
    
    % plot of the XZ slices
    
    % set slice position
    xzSlYPos=floor(data.stYLen/2);
    
    % reshape the image into a 2D array at a particular X
    imXZ=reshape(data.imSt(i1,:,xzSlYPos,:),data.numSl,data.stXLen);
    
    % plot image in X,Y coords in units of meters
    subplot(1,2,2);
    cla;
    imagesc(data.xMStVec,data.zMStVec,imXZ);
    set(gca,'YDir','normal')
    colormap(gray);
    axis([min(data.xMStVec) max(data.xMStVec) min(data.zMStVec) max(data.zMStVec)]);
    axis image
    axis tight
    xlabel('x [m]');
    ylabel('z [m]');
    title(sprintf('Frame %i, Channel %i, XZ-Slice Y-Pos %i',i1,data.chGeom,xzSlYPos));
    drawnow
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
    
end

% close the file handle
mov=close(mov); % closes the mov

% play the movie
if data.playMoviesON==1
    implay('./output/visImSt.avi');
end

% output the figure to eps
figure(1);
print('-depsc2','-painters','./output/stackVisualization.eps');

%% Next button GUI
% pause or wait for continue
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Next','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imNext);

% wait for the user to close the guiworkspaceAfterAllElasticity
uiwait(gcf);

end

% ---- implicit functions
function out=imNext(hObj,event,ax)

uiresume(gcbf);
end

function out=imWait(hObj,event,ax)
% do nothing
end