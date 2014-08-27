function []=plotSrchArea(data,i3,pX,pY,vX,vY,xBMin, xBMax, yBMin, yBMax)

% toolbar
global tb

% output verbosity for file
tV=3;

% plot the search area
if tb.verbose>=tV
    
    % plot search
    figure(212121);
    set(gca,'YDir','normal')
    hold on;
    cla;
    
    % plot the image
    imagesc(data.xPxVecCcdRoi,data.yPxVecCcdRoi, data.flMIPNorm{i3});
    
    % make green box around search area
    areaXBox=[xBMin xBMax xBMax xBMin xBMin];
    areaYBox=[yBMin yBMin yBMax yBMax yBMin];
    plot(areaXBox,areaYBox,'-g');
    
    % plot of the analysis ROI
    % x-coords of bounding box of Ansys ROI
    xBbAnsRoi=[min(tb.xPxVecAnsRoi) max(tb.xPxVecAnsRoi) max(tb.xPxVecAnsRoi) min(tb.xPxVecAnsRoi) min(tb.xPxVecAnsRoi)];
    yBbAnsRoi=[min(tb.yPxVecAnsRoi) min(tb.yPxVecAnsRoi) max(tb.yPxVecAnsRoi) max(tb.yPxVecAnsRoi) min(tb.yPxVecAnsRoi)];
    plot(xBbAnsRoi,yBbAnsRoi,'-r');
    
    % plot the starting centroid for each path, and a line
    % to the center of the search window
    plot(pX,pY,'.g');
    plot(pX+vX,pY+vY,'*r');
    plot([pX pX+vX],[pY pY+vY],'-g');
    
    axis equal
    axis([data.imColsAnsMin data.imColsAnsMax data.imRowsAnsMin data.imRowsAnsMax]);
    
    drawnow
    hold off;
end