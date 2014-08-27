function plotStrainInterpLocal(data)


% make a vector of the path numbers
pN=1:1:size(data.pSprX,1);

% dereference the first image
im=reshape(data.imMIP(1,:,:),data.MIPYLen,data.MIPXLen);

% make a figure for ROI display and selection by user
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);

clf;
hold on;

% plot the image with all path starting points numbered in yellow
imagesc(data.xMMIPVec,data.yMMIPVec,im);

% put yellow labels on all paths
for i4=1:1:size(data.pSprX,1)
    text(data.pSprX(i4,1), data.pSprY(i4,1),[num2str(i4)],'HorizontalAlignment','center','Color','yellow','FontSize',8);
end


axis equal

axis(data.pROIVec);
colormap(gray)
colorbar
drawnow

% set local ROI boundaries
% get two points defining the box
pRect=ginput(2);
pXMin=pRect(1,1);
pXMax=pRect(2,1);
pYMin=pRect(1,2);
pYMax=pRect(2,2);

% plot the ROI boundary (blink twice)
xBdry=[pXMin pXMax pXMax pXMin pXMin];
yBdry=[pYMin pYMin pYMax pYMax pYMin];
plot(xBdry,yBdry,'-g');
pause(0.1);
plot(xBdry,yBdry,'-w');
pause(0.1);
plot(xBdry,yBdry,'-g');
pause(0.1);
plot(xBdry,yBdry,'-w');
pause(0.1);
plot(xBdry,yBdry,'-g');
drawnow;

% dereference the maximum and minumum path positions for plotting
pSprXMin=min(min(data.pSprX));
pSprXMax=max(max(data.pSprX));
pSprYMin=min(min(data.pSprY));
pSprYMax=max(max(data.pSprY));


%% PLot the evaluation points

for i3=1:1:data.numSt
    clf;
    hold on
    
    % dereference the image
    im=reshape(data.imMIP(i3,:,:),data.MIPYLen,data.MIPXLen);
    
    % plot the images, with intensity scaled with max and min strain
    % variable for overlaid plotting
    imagesc(data.xMMIPVec,data.yMMIPVec,im);
    
    % plot the positions of the paths and chosen paths
    plot(data.pSprX(pN,i3),data.pSprY(pN,i3),'.y');
    plot(data.pSprX(pN,i3),data.pSprY(pN,i3),'.r');
    
    % put yellow labels on all paths
    for i4=1:1:size(data.pSprX,1)
        text(data.pSprX(i4,i3), data.pSprY(i4,i3),[num2str(i4)],'HorizontalAlignment','center','Color','yellow','FontSize',8);
    end
    
    % filter paths not in ROI in the first frame and put red labels on chosen paths
    cntFilt=0;
    
    % filter out in the first frame
    if i3==1
        for i4=1:1:length(pN)
            pXCur=data.pSprX(pN(i4),i3);
            pYCur=data.pSprY(pN(i4),i3);
            
            % filter
            if pXCur >= pXMin && pXCur <=pXMax && pYCur >= pYMin && pYCur <=pYMax
                cntFilt=cntFilt+1;
                pNFilt(cntFilt)=pN(i4);
                text(pXCur, pYCur,[num2str(pN(i4))],'HorizontalAlignment','center','Color','red','FontSize',8);
            end
        end
        % ... or use the filtered points in the remaining frames
    elseif i3>1
        for i4=1:1:length(pNFilt)
            pXCur=data.pSprX(pNFilt(i4),i3);
            pYCur=data.pSprY(pNFilt(i4),i3);
            text(pXCur, pYCur,[num2str(pNFilt(i4))],'HorizontalAlignment','center','Color','red','FontSize',8);
        end
    end
    
    
    axis equal
    axis(data.pROIVec);
    colormap(gray)
    colorbar
    drawnow
    
end

%% plot the averaged strain measure for a particular mesh vertex (path) choice

clf;
hold on

% plot a dashed line at 0
plot(data.ts,zeros(size(data.ts)),'--k');

% dXInterp error bar plot in red
% compute average of each path included
for i3=1:1:data.numSt
    dXMu(i3)=nanmean(nanmean(data.dXInterp{i3}));
    dXSig(i3)=nanstd(nanstd(data.dXInterp{i3}));
end
% plot the mean and std. dev, excluding the first user estimated value
errorbar(data.ts(2:end),dXMu(2:end),dXSig(2:end),'r','LineWidth',1);

% dY error bar plot in green
% compute average of each path included
for i3=1:1:data.numSt
    dYMu(i3)=nanmean(nanmean(data.dYInterp{i3}));
    dYSig(i3)=nanstd(nanstd(data.dYInterp{i3}));
end
% plot the mean and std. dev, excluding the first user estimated value
errorbar(data.ts(2:end),dYMu(2:end),dYSig(2:end),'g','LineWidth',1);

% dXY error bar plot in blue
% compute average of each path included
for i3=1:1:data.numSt
    dXYMu(i3)=nanmean(nanmean(data.dXYInterp{i3}));
    dXYSig(i3)=nanstd(nanstd(data.dXYInterp{i3}));
end
% plot the mean and std. dev, excluding the first user estimated value
errorbar(data.ts(2:end),dXYMu(2:end),dXYSig(2:end),'b','LineWidth',1);

title(sprintf('Strain rates'));
legend('Zero','dX','dY','dXY');
xlabel('time (s)');
ylabel('Strain rate');

% save the plot as an EPS file
print('-depsc2','-painters','./output/strainRateInterpLocal.eps')

pause(5);