function plotStrainSVDInterpLocal(data)

% how many times to repeat user selection?
numSel=1;

% make a vector of the path numbers
pN=1:1:size(data.pSprX,1);

% dereference the first image
im=reshape(data.imMIP(1,:,:),data.MIPYLen,data.MIPXLen);

% make a figure for ROI display and selection by user
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);


% loop over number of selections
for i1=1:1:numSel
    
    
    clf;
    hold on;
    
    % plot the image with all path starting points numbered in yellow
    maxX=max(max(data.dX(1,:)));
    maxY=max(max(data.dY(1,:)));
    maxXY=max(max(data.dXY(1,:)));
    imSc=im.*max(max(maxX,maxY),maxXY);
    imagesc(data.xMMIPVec,data.yMMIPVec,imSc);
    
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
    
    
    %% Sub-pixel res: plot strain map in triangulation for each path step in each time frame
    
    
    for i3=1:1:data.numSt-1
        clf;
        hold on
        
        % dereference for this time frame
        dX=data.dX(i3,:);
        dY=data.dY(i3,:);
        dXY=data.dXY(i3,:);
        
        % dereference the image
        im=reshape(data.imMIP(i3,:,:),data.MIPYLen,data.MIPXLen);
        
        % plot the images, with intensity scaled with max and min strain
        % variable for overlaid plotting
        imSc=im.*max(max(dX));
        imagesc(data.xMMIPVec,data.yMMIPVec,imSc);
        
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
    plot(data.tsm1,zeros(size(data.tsm1)),'--k');
    
    % dXInterp error bar plot in red
    % compute average of each path included
        for i3=1:1:data.numSt-1
            dXMu(i3)=nanmean(nanmean(data.dXSVDInterp{i3}));
            dXSig(i3)=nanstd(nanstd(data.dXSVDInterp{i3}));
        end
%     for i3=1:1:data.numSt-1
%         dXMu(i3)=nanmean(data.dXSVDInterp(:,i3));
%         dXSig(i3)=nanstd(data.dXSVDInterp(:,i3));
%     end
    % plot the mean and std. dev
    errorbar(data.tsm1,dXMu,dXSig,'r','LineWidth',1);
    %     plot(data.tsm1,dXMu,'-k','LineWidth',2);
    %     plot([data.tsm1;data.tsm1],[-dXSig'+dXMu';dXSig'+dXMu'],'-k','LineWidth',2);
    
    % dY error bar plot in green
    % compute average of each path included
        for i3=1:1:data.numSt-1
            dYMu(i3)=nanmean(nanmean(data.dYSVDInterp{i3}));
            dYSig(i3)=nanstd(nanstd(data.dYSVDInterp{i3}));
        end
%     for i3=1:1:data.numSt-1
%         dYMu(i3)=nanmean(data.dYSVDInterp(:,i3));
%         dYSig(i3)=nanstd(data.dYSVDInterp(:,i3));
%     end
    % plot the mean and std. dev
    errorbar(data.tsm1,dYMu,dYSig,'g','LineWidth',1);
    %     plot(data.tsm1,dYMu,'-k','LineWidth',2);
    %     plot([data.tsm1;data.tsm1],[-dYSig'+dYMu';dYSig'+dYMu'],'-k','LineWidth',2);
    
    
    
    % dXY error bar plot in blue
    % compute average of each path included
        for i3=1:1:data.numSt-1
            dXYMu(i3)=nanmean(nanmean(data.dXYSVDInterp{i3}));
            dXYSig(i3)=nanstd(nanstd(data.dXYSVDInterp{i3}));
        end
%     for i3=1:1:data.numSt-1
%         dXYMu(i3)=nanmean(data.dXYSVDInterp(:,i3));
%         dXYSig(i3)=nanstd(data.dXYSVDInterp(:,i3));
%     end
    % plot the mean and std. dev
    errorbar(data.tsm1,dXYMu,dXYSig,'b','LineWidth',1);
    %     plot(data.tsm1,dXYMu,'-k','LineWidth',2);
    %     plot([data.tsm1;data.tsm1],[-dXYSig'+dXYMu';dXYSig'+dXYMu'],'-k','LineWidth',2);
    
    
    title(sprintf('Strain rates'));
    legend('Zero','dX','dY','dXY');
    xlabel('time (s)');
    ylabel('Strain rate');
end


% save the plot as an EPS file
print('-depsc2','-painters','./output/strainRateSVDInterpLocal.eps')
