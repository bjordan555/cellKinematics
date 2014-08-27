%% To do: This function is not correctly filtering out strain rate values 
%% based on points selected. pNFilt filtering is disabled.  Works OK if all 
%% points in ROI are considered.

function plotStrainLocal(data)

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
    
    % clear the per selection filter list.
    clear pNFilt
    
    clf;
    hold on;
    
    
    % plot the image with all path starting points numbered in yellow
    maxX=max(max(data.dX(1,:)));
    maxY=max(max(data.dY(1,:)));
    maxXY=max(max(data.dXY(1,:)));
    imSc=im.*max(max(maxX,maxY),maxXY);
    imagesc(data.xMMIPVec,data.yMMIPVec ,imSc);
    plot(data.pSprX(pN,1),data.pSprY(pN,1),'.y');
    % put yellow labels on all paths
    for i4=1:1:size(data.pSprX,1)
        text(data.pSprX(i4,1), data.pSprY(i4,1),[num2str(i4)],'HorizontalAlignment','center','Color','yellow','FontSize',8);
    end

    axis equal
    axis tight
    axis(data.pROIVec);
    colormap(gray)
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
        axis tight
        axis(data.pROIVec);
        drawnow
        pause(0.25);
        
    end
    
    %% plot the averaged strain measure for a particular mesh vertex (path) choice

    clf;
    hold on

    % plot a dashed line at 0
    plot(data.tsm1,zeros(size(data.tsm1)),'--k');
    
    % dX error bar plot in red
    % compute average of each path included
%     dXMu=mean(data.dX(:,pNFilt),2);
%     dXSig=std(data.dX(:,pNFilt),0,2);

    dXMu=mean(data.dX(:,:),2);
    dXSig=std(data.dX(:,:),0,2);

    % plot the mean and std. dev
    errorbar(data.tsm1,dXMu,dXSig,'r','LineWidth',1);
%     plot(data.tsm1,dXMu,'-k','LineWidth',2);
%     plot([data.tsm1;data.tsm1],[-dXSig'+dXMu';dXSig'+dXMu'],'-k','LineWidth',2);
    
    % dY error bar plot in green
    % compute average of each path included
%     dYMu=mean(data.dY(:,pNFilt),2);
%     dYSig=std(data.dY(:,pNFilt),0,2);

    dYMu=mean(data.dY(:,:),2);
    dYSig=std(data.dY(:,:),0,2);
    
    % plot the mean and std. dev
        errorbar(data.tsm1,dYMu,dYSig,'g','LineWidth',1);
%     plot(data.tsm1,dYMu,'-k','LineWidth',2);
%     plot([data.tsm1;data.tsm1],[-dYSig'+dYMu';dYSig'+dYMu'],'-k','LineWidth',2);
    
    
    
    % dXY error bar plot in blue
    % compute average of each path included
%     dXYMu=mean(data.dXY(:,pNFilt),2);
%     dXYSig=std(data.dXY(:,pNFilt),0,2);
    
    dXYMu=mean(data.dXY(:,:),2);
    dXYSig=std(data.dXY(:,:),0,2);
    
    % plot the mean and std. dev
    errorbar(data.tsm1,dXYMu,dXYSig,'b','LineWidth',1);
%     plot(data.tsm1,dXYMu,'-k','LineWidth',2);
%     plot([data.tsm1;data.tsm1],[-dXYSig'+dXYMu';dXYSig'+dXYMu'],'-k','LineWidth',2);
    
    
    title(sprintf('Strain rates'));
    legend('Zero','dX','dY','dXY');
    xlabel('time (s)');
    ylabel('Strain rate');

 
 
    %% plot all the points in a lighter color
    % dX in red
    for i2=1:1:size(data.dX,2)
        % plot each measurement in a light color as background
        plot(data.tsm1,data.dX(:,i2),'.','Color',[1,0.75,0.75]);
        
    end
    
    % dY in green
    for i2=1:1:size(data.dY,2)
        % plot each measurement in a light color as background
        plot(data.tsm1,data.dY(:,i2),'.','Color',[0.75,1,0.75]);
        
    end
    
    % dXY in blue
    for i2=1:1:size(data.dXY,2)
        % plot each measurement in a light color as background
        plot(data.tsm1,data.dXY(:,i2),'.','Color',[0.75,0.75,1]);
        
    end
    drawnow;
end


% save the plot as an EPS file
print('-depsc2','-painters','./output/strainRateLocal.eps')

pause(5);