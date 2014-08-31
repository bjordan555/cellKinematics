function [SSDNew,RsqNew,minXNew,minYNew,minRsqNew,minSSDNew,stepXNew,stepYNew,filtPrev,imWinPrev,imWinCur] = ...
    windowSSD(pathDataIn,pXPrev, pYPrev, pXAppr, pYAppr, imPrev, imCur, pathNum, frNum,filtPrev)

% dereference 
winVec=pathDataIn.winVec;
stepXVec=pathDataIn.stepXVec;
stepYVec=pathDataIn.stepYVec;
restBdryX=pathDataIn.restBdryX;
restBdryXWidth=pathDataIn.restBdryXWidth;
MIPMinX=pathDataIn.MIPMinX;
MIPMaxX=pathDataIn.MIPMaxX;
MIPMinY=pathDataIn.MIPMinY;
MIPMaxY=pathDataIn.MIPMaxY;
RsqThWin=pathDataIn.RsqThWin;

% define the boundaries for the previous window
xBMinPrev=pXPrev+min(winVec);
xBMaxPrev=pXPrev+max(winVec);
yBMinPrev=pYPrev+min(winVec);
yBMaxPrev=pYPrev+max(winVec);

% define the boundaries for the current window and search area
xBMinCur=pXAppr+min(stepXVec)+min(winVec);
xBMaxCur=pXAppr+max(stepXVec)+max(winVec);
yBMinCur=pYAppr+min(stepYVec)+min(winVec);
yBMaxCur=pYAppr+max(stepYVec)+max(winVec);

% initialize the filter for restricted boundary crossings
filtRest=0;

% compute which restricted boundaries pXPrev and pXAppr cross
if ~isempty(restBdryX)
    for i1=1:1:length(restBdryX)
        
        % compute distance to restricted boundary for path step
        pXPrevBdryDist=abs(pXPrev-restBdryX(i1));
        pXApprBdryDist=abs(pXAppr-restBdryX(i1));
        
        % check to see if previous or current step is near restricted boundary
        if pXPrevBdryDist<=restBdryXWidth || pXApprBdryDist<=restBdryXWidth
            
            % the path being analyzed crosses a restricted boundary region
            filtRest=1;
        
        end
    end
end
%% check the various conditions for filtering this path step

% if previous path was filtered, filter all remaining paths
if filtPrev==1
    
    %     display(sprintf('Warning (windowSSD.m): Filtered path because previous path was filtered'));
    
    SSDNew=[];
    RsqNew=[];
    minXNew=NaN;
    minYNew=NaN;
    stepXNew=NaN;
    stepYNew=NaN;
    minRsqNew=NaN;
    minSSDNew=NaN;
    imWinPrev=[];
    imWinCur=[];
    
    % Check for restricte boundary crosssing filter
elseif filtRest==1
    
    display(sprintf('Filtered path %i at frame %i: Path crossed restricted boundary',pathNum,frNum));
    
    SSDNew=[];
    RsqNew=[];
    minXNew=NaN;
    minYNew=NaN;
    stepXNew=NaN;
    stepYNew=NaN;
    minRsqNew=NaN;
    minSSDNew=NaN;
    imWinPrev=[];
    imWinCur=[];
   
    
    % set the paths in future frames to be filtered
    filtPrev=1;
    
    
    
    %% Filter paths with search or windows placed outside of image boundaries
elseif xBMinPrev < (MIPMinX+1) || yBMinPrev < (MIPMinY+1) || ...
        xBMaxPrev > (MIPMaxX)  || yBMaxPrev > (MIPMaxY) || ...
        xBMinCur < (MIPMinX+1) || yBMinCur < (MIPMinY+1) || ...
        xBMaxCur > (MIPMaxX)  || yBMaxCur > (MIPMaxY)
    
    % Check to be sure neither the image window around the feature in the
    % previous frame, nor the image search window around the feature in the current frame are
    % outside the image. if outside of CCD ROI, set values to flag filtering
    
    display(sprintf('Filtered path %i at frame %i: Search outside image.',pathNum,frNum));
    
    SSDNew=[];
    RsqNew=[];
    minXNew=NaN;
    minYNew=NaN;
    stepXNew=NaN;
    stepYNew=NaN;
    minSSDNew=NaN;
    minRsqNew=NaN;
    imWinPrev=[];
    imWinCur=[];
    
    
    % set the paths in future frames to be filtered
    filtPrev=1;
else
    % get the image windows and compute the SSD
    
    % plot the window searching
    %     plotWinArea(pathDataIn,pXPrev,pYPrev,pXAppr,pYAppr,xBMinCur,xBMaxCur,yBMinCur,yBMaxCur,imCur);
    
    % Compute image window in search region around starting position in previous time frame
    imWinPrev=getImageWindow(pathDataIn, pXPrev, pYPrev,imPrev);
    
    % pre-allocate the matrix of SSDs within the search radius
    SSDNew=zeros(length(stepXVec),length(stepYVec));
    RsqNew=zeros(length(stepXVec),length(stepYVec));
    
    for i4=1:length(stepXVec)
        for i5=1:1:length(stepYVec)
            
            % assign steps from vector for search area
            stepXSearch=stepXVec(i4);
            stepYSearch=stepYVec(i5);
            
            % define the current path center offset by search
            pXSearch=pXAppr+stepXSearch;
            pYSearch=pYAppr+stepYSearch;
            
            % get the window to test from the current time frame
            imWinCur=getImageWindow(pathDataIn, pXSearch, pYSearch,imCur);
            
            % compute residuals and SSD grid
            res=imWinCur-imWinPrev;
            
            % The normalized SSD, allowing for multiscale analysis (Gui and Merzkirch 1996)
            SSDNew(i4,i5)=sum(sum(res.^2))./(length(stepXVec)*length(stepYVec));
            
            % compute the R^2
            meanPrev=mean(mean(imWinPrev));
            SStot=sum(sum((imWinPrev-meanPrev).^2))./(length(stepXVec)*length(stepYVec));
            RsqNew(i4,i5)=1-SSDNew(i4,i5)./SStot;
        end
    end
    
    
    
    %% Find the minimum to determine the pixel-level accuracy
    % brute force minimum finder guarantees global min
    for i4=1:1:length(stepXVec)
        for i5=1:1:length(stepYVec)
            if i4==1 && i5==1
                minSSDNew=SSDNew(i4,i5);
                minXNew=i4;
                minYNew=i5;
            else
                val=SSDNew(i4,i5);
                if val<minSSDNew
                    minXNew=i4;
                    minYNew=i5;
                    minSSDNew=SSDNew(i4,i5);
                end
            end
        end
    end
    
    % ... and Rsq for later stats
    minRsqNew=RsqNew(minXNew,minYNew);
    
    % check for paths that don't satisfy R^2 criteria
    if minRsqNew < RsqThWin
        display(sprintf('Filtered path %i at frame %i: R^2=%f<%f',pathNum,frNum,minRsqNew,RsqThWin));
        
        
        % set the paths in future frames to be filtered
        filtPrev=1;
        
        % assign the empty or Nan values to filtered paths
        SSDNew=[];
        RsqNew=[];
        minXNew=NaN;
        minYNew=NaN;
        stepXNew=NaN;
        stepYNew=NaN;
        minSSDNew=NaN;
        minRsqNew=NaN;
        
    else
        
        % display success message at final path
        if frNum==pathDataIn.numSt
            display(sprintf('Path %i at frame %i: Complete.',pathNum,frNum));
        end
        
        % convert SSD index step into actual pixel step
        stepXNew=stepXVec(minXNew);
        stepYNew=stepYVec(minYNew);
        
        % get the winning image window from the next time frame offset by the step
        imWinCur=getImageWindow(pathDataIn, pXAppr+stepXNew, pYAppr+stepYNew,imCur);
        
    end
    
end


% % plots of the winning SSD, image windows, and residuals
% 
%         % When a fitted path is returned, plot some results
%         if ~isempty(SSD{pathNum,frNum}) && frNum~=1
%             
%             
%             
%             % Plot the SSD surface for each feature at each time step
%             subplot(2,3,3);
%             cla;
%             hold on
%             pcolor(stepXVec,stepYVec, SSD{pathNum,frNum}');
%             plot(stepXVec(minX(pathNum,frNum)),stepYVec(minY(pathNum,frNum)),'.y');
%             shading interp
%             xlabel('x=cols=j'); ylabel('y=rows=i');
%             title(sprintf('SSD surface for path %i, frame %i',frNum));
%             axis tight
%             axis equal
%             colorbar
%             colormap(jet);
%             
%             % plot of the previous and current image windows
%             % plot the previous window
%             subplot(2,3,4);
%             cla;
%             imagesc(imWinPrev{pathNum,frNum});
%             set(gca,'YDir','normal')
%             colorbar
%             colormap(jet);
%             title('Previous window');
%             axis equal;
%             axis tight;
%             
%             % plot the winning window
%             subplot(2,3,5);
%             cla;
%             imagesc(imWinCur{pathNum,frNum});
%             set(gca,'YDir','normal')
%             colorbar
%             colormap(jet);
%             title('Current window');
%             axis equal;
%             axis tight;
%             
%             % compute the residuals
%             res=imWinCur{pathNum,frNum}-imWinPrev{pathNum,frNum};
%             
%             % plot the squared res
%             subplot(2,3,6);
%             cla;
%             imagesc(res.^2);
%             set(gca,'YDir','normal')
%             colorbar
%             colormap(jet);
%             title('Squared-Residuals of Previous and Current Window');
%             axis equal;
%             axis tight;
%             
%             drawnow;
%             
%         end








