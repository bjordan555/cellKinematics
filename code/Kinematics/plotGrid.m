% function to overlay a grid of the search and window size on the current
% image figure. Helpful in estimating the appropriate window and search size
function plotGrid(data,h)

global tb
tV=2;
if tb.verbose<=tV
    
    % set the figure to h
    figure(h);
    
    % optionally, plot an image
%     imagesc(data.flMIP{1});
%     set(gca,'YDir','normal');
    
    yMin=data.yPxVecAnsRoi(1);
    yMax=data.yPxVecAnsRoi(length(data.yPxVecAnsRoi));
    xMin=data.xPxVecAnsRoi(1);
    xMax=data.xPxVecAnsRoi(length(data.xPxVecAnsRoi));
    
    % for each search length, plot a green line
    ySearchVec=yMin:data.winStepSzPix:yMax;
    xSearchVec=xMin:data.winStepSzPix:xMax;
    
    % use current figure
    hold on
    % plot the horizontal lines of search region tiling
    for i1=1:1:length(ySearchVec)
        plot(xSearchVec,ySearchVec(i1)*ones(1,length(xSearchVec)),'-g');
    end
    % plot the vertical lines of search tiling
    for i1=1:1:length(xSearchVec)
        plot(xSearchVec(i1)*ones(length(ySearchVec),1),ySearchVec,'-g');
    end
    % pick a lucky number
    iRndX=ceil(length(xSearchVec)*rand);
    iRndY=ceil(length(ySearchVec)*rand);
    % plot a window size in red
    winX(1)=xSearchVec(iRndX)-data.winSzPix/2;
    winX(2)=xSearchVec(iRndX)+data.winSzPix/2;
    winX(3)=xSearchVec(iRndX)+data.winSzPix/2;
    winX(4)=xSearchVec(iRndX)-data.winSzPix/2;
    winX(5)=xSearchVec(iRndX)-data.winSzPix/2;
    winY(1)=ySearchVec(iRndY)-data.winSzPix/2;
    winY(2)=ySearchVec(iRndY)-data.winSzPix/2;
    winY(3)=ySearchVec(iRndY)+data.winSzPix/2;
    winY(4)=ySearchVec(iRndY)+data.winSzPix/2;
    winY(5)=ySearchVec(iRndY)-data.winSzPix/2;
    
    plot(winX,winY,'-r');
    
end
