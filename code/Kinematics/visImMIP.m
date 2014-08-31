%% Visualize MIP and estimate initial velocity
function data=visImMIP(data)

% view the MIP

% loop over all time frames used
h=figure(1);
clf;
set(h,'Units','normalized','outerposition',data.guiSize);
hold on;

% wait button
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Wait...','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imWait);

% create the avi file
mov=avifile('./output/visImMIP.avi','compression','none','fps',4,'quality',100);

for i1=1:1:data.numSt
    if i1==1
        
        % reshape the MIP into a 2D array at intial frame
        im=reshape(data.imMIP(i1,:,:),data.MIPYLen,data.MIPXLen);
        
        % initialize sum image for plotting
        imSum=im;
        
    else
        
        % reshape the MIP into a 2D array at intial frame
        im=reshape(data.imMIP(i1,:,:),data.MIPYLen,data.MIPXLen);
        
        % sum the images
        imSum=imSum+im;
    end
    
    % plot images in X,Y coords in units of meters
    subplot(1,1,1);
    cla;
    hold on
    imagesc(data.xMMIPVec,data.yMMIPVec,im);
    
    % plot any restricted boundaries in red
    if ~isempty(data.restBdryX)
        for i4=1:1:length(data.restBdryX)
            % make vectors for boundary plotting
            xVec=[data.restBdryX(i4) data.restBdryX(i4)].*data.mPxXMIP;
            yVec=[data.MIPMinY data.MIPMaxY].*data.mPxYMIP;
            plot(xVec,yVec,'-r');
        end
        
    end
    
    set(gca,'YDir','normal')
    colormap(gray);
    %                 colorbar
    %             caxis([data.stMin data.stMax])
    caxis([0 1])
    axis([min(data.xMMIPVec) max(data.xMMIPVec) min(data.yMMIPVec) max(data.yMMIPVec)]);
    axis image
    axis tight
    xlabel('x [m]');
    ylabel('y [m]');
    title(sprintf('Frame %i, Channel %i',i1,1));
    drawnow;
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
end


% close the file handle
mov=close(mov); % closes the mov

% play the movie
if data.playMoviesON==1
    implay('./output/visImMIP.avi');
end

% Plot the normalized sum image for estimating the initial velocity field
figure(1);
% loop over all channels


% Normalize the summed image
imSum=imSum./max(max(imSum));

% plot images in X,Y coords in units of meters
subplot(1,1,1);
cla;
hold on;
imagesc(data.xMMIPVec,data.yMMIPVec,imSum);

% plot any restricted boundaries in red
if ~isempty(data.restBdryX)
    for i1=1:1:length(data.restBdryX)
        % make vectors for boundary plotting
        xVec=[data.restBdryX(i1) data.restBdryX(i1)].*data.mPxXMIP;
        yVec=[data.MIPMinY data.MIPMaxY].*data.mPxYMIP;
        plot(xVec,yVec,'-r');
    end
    
end

set(gca,'YDir','normal')
colormap(gray);
%         colorbar
%     caxis([data.stMin data.stMax])
caxis([0 1])
    axis([min(data.xMMIPVec) max(data.xMMIPVec) min(data.yMMIPVec) max(data.yMMIPVec)]);
axis image
axis tight
xlabel('x [m]');
ylabel('y [m]');
title(sprintf('Summed MIP Channel %i',1));
drawnow;


% output the figure to eps
figure(1);
print('-depsc2','-painters','./output/MIPVisualization.eps');

%% Get the ROI from the user
% display message to user
display('Select the ROI from any channel image, then press Next.');

% set local ROI boundaries
% get two points defining the box
pRect=ginput(2);

% assign components to variables for storage
pXMinROI=pRect(1,1);
pXMaxROI=pRect(2,1);
pYMinROI=pRect(1,2);
pYMaxROI=pRect(2,2);

% make another vector that is 133% of original for plotting
pXL=(pXMaxROI-pXMinROI)/3;
pYL=(pYMaxROI-pYMinROI)/3;

% create a vector defining ROI axis for plotting.
% pROIVec=[pXMinROI pXMaxROI pYMinROI pYMaxROI];
pROIVec=[pXMinROI-pXL pXMaxROI+pXL pYMinROI-pYL pYMaxROI+pYL];

% plot the ROI boundary (blink twice) in all frames
% loop over the number of "blinks"
for i2=1:1:4
    subplot(1,1,1);
    xBdry=[pXMinROI pXMaxROI pXMaxROI pXMinROI pXMinROI];
    yBdry=[pYMinROI pYMinROI pYMaxROI pYMaxROI pYMinROI];
    hold on;
    % plot the summed image
    imagesc(data.xMMIPVec,data.yMMIPVec,imSum);
    set(gca,'YDir','normal')
    colormap(gray);
    %             colorbar
    %     caxis([data.stMin data.stMax])
    %             caxis([0 1])
    axis([min(data.xMMIPVec) max(data.xMMIPVec) min(data.yMMIPVec) max(data.yMMIPVec)]);
    axis image
    axis tight
    xlabel('x [m]');
    ylabel('y [m]');
    title(sprintf('Summed MIP Channel %i',1));
    % blink green and white
    if mod(i2,2)==0
        plot(xBdry,yBdry,'-g');
    else
        plot(xBdry,yBdry,'-w');
    end
    
    % plot all channels first then draw
    drawnow;
    pause(0.05);
end

%% Next button GUI
% pause or wait for continue
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Next','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imNext);

% wait for the user to close the guiworkspaceAfterAllElasticity
uiwait(gcf);

% store the ROI bounds in data structure
data.pXMinROI=pXMinROI;
data.pXMaxROI=pXMaxROI;
data.pYMinROI=pYMinROI;
data.pYMaxROI=pYMaxROI;
data.pROIVec=pROIVec;

end


%% ---- implicit function for Next Button
function roi=imNext(hObj,event,ax)

roi=[];
uiresume(gcbf);
end

%% ---- implicit function for Wait Button
function roi=imWait(hObj,event,ax)
% do nothing
roi=[];
end



