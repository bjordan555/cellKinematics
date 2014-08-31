%% Gamma correction for channel used for PIV
function [data]=gammaMIP(data)

%% global toolbar object
% changes made from any function to ui are shared
global ui

% load the MIP images
ui.im=reshape(data.imMIP(:,:,:),data.numSt,data.MIPYLen,data.MIPXLen);

% data values used in GUI must be put in global
ui.gam=1.0;
ui.low=0.001;
ui.high=1.0;
ui.xPxMIPVec=data.xPxMIPVec;
ui.yPxMIPVec=data.yPxMIPVec;
ui.numSt=data.numSt;
ui.MIPXLen=data.MIPXLen;
ui.MIPYLen=data.MIPYLen;
ui.xMMIPVec=data.xMMIPVec;
ui.yMMIPVec=data.yMMIPVec;
ui.pROIVec=data.pROIVec;

% make a custom gui
h=figure(1);
clf;
set(h,'Units','Normalized','Position',data.guiSize);

% create the gui buttons
ui.a1=axes('Units','normalized','Position',[0.1 0.2 0.8 0.7]);

ui.s1=uicontrol('style','slider','min',0,'max',10,'value',ui.gam,'SliderStep',[0.001 0.1],'units','normalized','position', [0.03 0.03 0.74 0.04],...
    'callback',@imGamCb);
ui.s2=uicontrol('style','slider','min',0,'max',1,'value',ui.low,'SliderStep',[0.01 0.1],'units','normalized','position', [0.03 0.08 0.74 0.04],...
    'callback',@imLowCb);
ui.s3=uicontrol('style','slider','min',0,'max',1,'value',ui.high,'SliderStep',[0.01 0.1],'units','normalized','position', [0.03 0.13 0.74 0.04],...
    'callback',@imHighCb);
ui.b1=uicontrol('style', 'pushbutton', 'string', 'ok','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imOk);
ui.b2=uicontrol('style', 'pushbutton', 'string', 'play','units','normalized','position', [0.84 0.03 0.10 0.04],...
    'callback', @imPlay);
ui.b2=uicontrol('style', 'text', 'string', 'high','units','normalized','position', [0.78 0.13 0.05 0.04],...
    'callback', @imPlay);
ui.b2=uicontrol('style', 'text', 'string', 'low','units','normalized','position', [0.78 0.08 0.05 0.04],...
    'callback', @imPlay);
ui.b2=uicontrol('style', 'text', 'string', 'gamma','units','normalized','position', [0.78 0.03 0.05 0.04],...
    'callback', @imPlay);


% plot image in X,Y coords in units of meters
% get the first time frames for the channel used for PIV
imCur=reshape(ui.im(1,:,:),ui.MIPYLen,ui.MIPXLen);
imagesc(ui.xMMIPVec,ui.yMMIPVec,imCur);
set(gca,'YDir','normal')

% equalize the axis scales
axis equal

% remove outside whitespace from axes
axis tight

% set the axis using the ROI
axis(ui.pROIVec);

colormap(gray);
colorbar
xlabel('x [m]');
ylabel('y [m]');
title(sprintf('Frame %i',1));
drawnow;

% wait for the user to close the guiworkspaceAfterAllElasticity
uiwait(gcf);

% show the movie
plotIm();

% store gamma corrected MIP in a structure for next processing steps
data.imMIPGamma=ui.imGamma;

end


%% subfunctions called from callback
function out=imLowCb(hObj,event,ax)
% toolbar
global ui

% get the current value for the slider
ui.low = get(hObj,'value');

% display the value of the slider
display(sprintf('Lower Threshold=%f',ui.low));

% update the image series plot
plotIm();
end

function out=imHighCb(hObj,event,ax)
% toolbar
global ui

% get the current value for the slider
ui.high = get(hObj,'value');

% display the value of the slider
display(sprintf('Upper Threshold=%f',ui.high));

% update the image series plot
plotIm();
end


function out=imGamCb(hObj,event,ax)
% toolbar
global ui

% get the current value for the slider
ui.gam = get(hObj,'value');

% display the value of the slider
display(sprintf('Gamma Exponent=%f',ui.gam));

% update the image series plot
plotIm();
end

function out=imOk(hObj,event,ax)
uiresume(gcbf);
end

function out=imPlay(hObj,event,ax)

plotIm();

end


function plotIm()
% toolbar
global ui

% preallocate imGamma
imGamma=zeros(size(ui.im));

for i1=1:1:ui.numSt
    
    % get this time frames image
    imCur=reshape(ui.im(i1,:,:),ui.MIPYLen,ui.MIPXLen);
    
    % gamma correct
    imAdj=imadjust(imCur,[ui.low ui.high],[0 1],ui.gam);
    
    %% plot gamma corrected image
%     figure(1);
    % plot image in X,Y coords in units of meters
    imagesc(ui.xMMIPVec,ui.yMMIPVec,imAdj);
    set(gca,'YDir','normal')
    
    
    % equalize the axis scales
    axis equal
    % remove outside whitespace from axes
    axis tight
    % set the axis using the ROI
    axis(ui.pROIVec);
    
    colormap(gray);
    colorbar
    xlabel('x [m]');
    ylabel('y [m]');
    title(sprintf('Frame %i',i1));
    drawnow;
    
    % store the gamma corrected image
    imGamma(i1,:,:)=imAdj;
end
% store the gamma corrected MIP in the toolbar for passing back to main function
ui.imGamma=imGamma;
end
