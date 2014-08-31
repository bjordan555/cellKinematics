%% Refine the paths pX, pY, velocities vX, vY, and the displacements uX, uY to subpixel resolution.

function data=refineSpr(data)

% display algorithm step entry
display('Refining paths to sub-pixel resolution');

% counter for number of paths filtered
cntRsq=0;
% counter for big step correction
cntStep=0;
% counter for total # of paths
cnt=0;

% progress bar init
progressbar('% Refined to sub-pixel resolution');

% pre-allocate data structures
pSprX=zeros(data.numPaths,data.numSt);
pSprY=zeros(data.numPaths,data.numSt);
vSprX=zeros(data.numPaths,data.numSt);
vSprY=zeros(data.numPaths,data.numSt);
stepSprX=zeros(data.numPaths,data.numSt);
stepSprY=zeros(data.numPaths,data.numSt);
stepSprXCorr=zeros(data.numPaths,data.numSt);
stepSprYCorr=zeros(data.numPaths,data.numSt);
sprRsqX=zeros(data.numPaths,data.numSt);
sprSseX=zeros(data.numPaths,data.numSt);
sprRmseX=zeros(data.numPaths,data.numSt);
sprRsqY=zeros(data.numPaths,data.numSt);
sprSseY=zeros(data.numPaths,data.numSt);
sprRmseY=zeros(data.numPaths,data.numSt);

for i2=1:1:data.numPaths
    
    % for each step in the path, excluding the first
    for i3=1:1:data.numSt
        
        % correct all path steps to SPR except first path
        if i3==1

            % There is no SPR correction for the first frame, since the
            % centroid detection determines it. The step is the step TO
            % this location at this time.
            stepSprXCorr(i2,i3)=0;
            stepSprYCorr(i2,i3)=0;
            stepSprX(i2,i3)=data.stepX(i2,i3);
            stepSprY(i2,i3)=data.stepY(i2,i3);
            
            % set the SPR path location for the first frame to match the PR
            % location. 
            pSprX(i2,i3)=data.pX(i2,i3);
            pSprY(i2,i3)=data.pY(i2,i3);
            
            % likewise, set the R^2 value to 1 for this first step
            sprRsqX(i2,i3)=1;
            sprRsqY(i2,i3)=1;
            
        else
            % counter for vector quantities
            cnt=cnt+1;
            
            % dereference minimum indexes for SSD and Rsq
            minX=data.minX(i2,i3);
            minY=data.minY(i2,i3);
            
            % size of the subpixel fit
            nL=data.nL;  %% MUST BE ODD
            
            % define the minimum and maximum step index correction in SPR
            minIdxXSpr=minX-(nL-1)/2;
            maxIdxXSpr=minX+(nL-1)/2;
            minIdxYSpr=minY-(nL-1)/2;
            maxIdxYSpr=minY+(nL-1)/2;
            
            % check for sub-pixel fitting grid within bounds of stepVec
            if minIdxXSpr<1 || maxIdxXSpr>length(data.stepXVec) || ...
                    minIdxYSpr<1 || maxIdxYSpr>length(data.stepYVec)
                
                display(sprintf('Warning (refineSpr.m): Filtering path %i at frame %i. SPR fit out of SSD bounds',i2,i3));
                % discard them and set to Nan/-Inf. Keeping them would
                % increase the error, given properly working sub-pixel
                % resolution algorithm
                pSprX(i2,i3)=NaN;
                pSprY(i2,i3)=NaN;
                sprRsqX(i2,i3)=-Inf;
                sprSseX(i2,i3)=NaN;
                sprRmseX(i2,i3)=NaN;
                sprRsqY(i2,i3)=-Inf;
                sprSseY(i2,i3)=NaN;
                sprRmseY(i2,i3)=NaN;
                stepSprX(i2,i3)=NaN;
                stepSprY(i2,i3)=NaN;
                filtSpr(i2,i3)=1;
                
            else
                
                % Make neighborhood around mean (nL x nL pixel neighborhood)
                nX=minIdxXSpr:1:maxIdxXSpr;
                nY=minIdxYSpr:1:maxIdxYSpr;
                
                % Dereference the SSD and make the min a max by computing its additive inverse for
                % comparison with a normal distribution.
                tSSD=data.SSD{i2,i3}(nX,nY);
                invSSD=(max(max(tSSD))-tSSD); 
                
                %% Fit the SSD subregion with two 1D gaussians
                
                % extract the central vectors
                %                 invSSDX=invSSD((nL+1)/2,:);
                %                 invSSDY=invSSD(:,(nL+1)/2);
                invSSDX=invSSD(:,(nL+1)/2);
                invSSDY=invSSD((nL+1)/2,:);
               
                % make the Y vector into a  column vector
                invSSDY=invSSDY';
                
                % set the options for the fitting to be sure accuracy
                 fitOpts=fitoptions('Normalize','off','Method','NonlinearLeastSquares',...
                     'TolFun',data.tolFunSpr,'TolX',data.tolXSpr,'MaxIter',data.maxIterSpr,...
                     'MaxFunEvals',data.maxFunEvalsSpr,'Display','notify');
                
                 % fit the two vectors in each coordinate axis
                 [gaussFitX,gofX,outFitX]=fit(nX',invSSDX,'gauss1',fitOpts);
                [gaussFitY,gofY,outFitY]=fit(nY',invSSDY,'gauss1',fitOpts);
                
                % extract the SPR centroid (mean) and variances
                maxXSpr=gaussFitX.b1;
                maxYSpr=gaussFitY.b1;
                ampSpr=[gaussFitX.a1 gaussFitY.a1];   %==gaussFitY.a1
                muSpr=[gaussFitX.b1 gaussFitY.b1];
                sigSpr=[gaussFitX.c1 0; 0 gaussFitY.c1];
                
                % Make a higher resolution vectors and meshgrid for evaluating
                % fitted curves and surfaces
                nXSpr=linspace(minIdxXSpr,maxIdxXSpr,data.sprFitGridDX);
                nYSpr=linspace(minIdxYSpr,maxIdxYSpr,data.sprFitGridDX);
                [xxi,yyi]=meshgrid(nXSpr,nYSpr);
                
                % construct the 2d Gaussian from the two 1D 3-pt Gaussian fits
                gauss2dSpr = mvnpdf([xxi(:) yyi(:)],muSpr,sigSpr);
                gauss2dSpr = reshape(gauss2dSpr,length(nYSpr),length(nXSpr));
                
                % normalize and multiply by the averaged amplitude of the fitted means
                aMean=mean([gaussFitX.a1 gaussFitY.a1]);
                gauss2dSprMax=max(max(gauss2dSpr));
                gauss2dSprMin=min(min(gauss2dSpr));
                gauss2dSpr=aMean.*(gauss2dSpr-gauss2dSprMin)./(gauss2dSprMax-gauss2dSprMin);
                
%                 % plot the original and fitted surface and correction
%                 figure(1);
%                 clf;
%                 hold on;
%                 pcolor(nX,nY,invSSD);
%                 alpha(0.5);
%                 shading interp
%                 pcolor(nXSpr,nYSpr,gauss2dSpr);
%                 alpha(0.5);
%                 shading interp
%                 plot(maxXSpr,maxYSpr,'*r');
%                 plot(minX,minY,'*g');
%                 plot([maxXSpr minX],[maxYSpr minY],'-y');
% %                 view(2);
%                 hold off;
%                 title(sprintf('Fitted 1/SSD to SPR for path=%i at t=%i',i2,i3));
%                 xlabel('xSpr');
%                 ylabel('ySpr');
%                 colorbar;
%                 drawnow
% %                 pause();
                
                % compute the SPR correction by subtracting the fitted min
                % to the pixel resolution min
                stepSprXCorr(i2,i3)=maxXSpr-minX;
                stepSprYCorr(i2,i3)=maxYSpr-minY;
                                
                % Correct the step to SPR resolution
                stepSprX(i2,i3)=data.stepX(i2,i3)+stepSprXCorr(i2,i3);
                stepSprY(i2,i3)=data.stepY(i2,i3)+stepSprYCorr(i2,i3);
            
                %% use the same starting path location for each step if the
                %% PIV frame (Eulerian) is on
                if data.PIVFrameON==0
                    % Correct the path location at this step for PTV
                    pSprX(i2,i3)=data.pX(i2,i3)+stepSprXCorr(i2,i3);
                    pSprY(i2,i3)=data.pY(i2,i3)+stepSprYCorr(i2,i3);
                else
                    % for PIV the evaluation grid locations are fixed
                    pSprX(i2,i3)=data.pX(i2,i3);
                    pSprY(i2,i3)=data.pY(i2,i3);
                end
                
                % store SSE and Rsq for SPR fitting
                sprRsqX(i2,i3)=gofX.rsquare;
                sprSseX(i2,i3)=gofX.sse;
                sprRmseX(i2,i3)=gofX.rmse;
                sprRsqY(i2,i3)=gofY.rsquare;
                sprSseY(i2,i3)=gofY.sse;
                sprRmseY(i2,i3)=gofY.rmse;
                
                filtSpr(i2,i3)=0;
                % Check for non-finite values in inputs
                if any(any(isnan(xxi))) || any(any(isnan(yyi))) || any(any(isnan(gauss2dSpr))) || ...
                        any(any(isinf(xxi))) || any(any(isinf(yyi))) || any(any(isinf(gauss2dSpr)))
                    display(sprintf('Error (refineSpr.m): non-finite data for fitting, i2=%i, i3=%i',i2,i3));
                end
                
                
                % Filter out any paths that have bad R^2 fit
                if sprRsqX(i2,i3) < data.RsqThSpr || sprRsqY(i2,i3) < data.RsqThSpr
                    cntRsq=cntRsq+1;
                    display(sprintf('Warning (refineSpr.m): Filtered path %i at step %i: sprRsqX=%f, sprRsqY=%f, RsqThSpr=%f',i2,i3,sprRsqX(i2,i3),sprRsqY(i2,i3),data.RsqThSpr));
                    % set to Nan/-Inf for filtering
                    filtSpr(i2,i3)=1;
                    stepSprX(i2,i3)=NaN;
                    stepSprY(i2,i3)=NaN;
                    pSprX(i2,i3)=NaN;
                    pSprY(i2,i3)=NaN;
                    sprRsqX(i2,i3)=-Inf;
                    sprSseX(i2,i3)=NaN;
                    sprRmseX(i2,i3)=NaN;
                    sprRsqY(i2,i3)=-Inf;
                    sprSseY(i2,i3)=NaN;
                    sprRmseY(i2,i3)=NaN;
                end
                
                % Filter out any steps larger than data.maxSprC.
                % The assumption here is that the centroid identification
                % and subsequent image matching are AT LEAST pixel-accurate.
                if abs(stepSprXCorr(i2,i3)) > data.maxSprC || abs(stepSprYCorr(i2,i3)) > data.maxSprC
                    % if the step is too large, warn and set to NaN
                    display(sprintf('Warning (refineSpr.m): Filtered path %i at step %i: Pixel correction=(%f,%f) > %f pixels. sprRsqX=%f,sprRsqY=%f',i2,i3,stepSprX(i2,i3),stepSprY(i2,i3),data.maxSprC,sprRsqX(i2,i3),sprRsqY(i2,i3)));
                    % set to Nan/-Inf for filtering
                    filtSpr(i2,i3)=1;
                    stepSprX(i2,i3)=NaN;
                    stepSprY(i2,i3)=NaN;
                    pSprX(i2,i3)=NaN;
                    pSprY(i2,i3)=NaN;
                    sprRsqX(i2,i3)=-Inf;
                    sprSseX(i2,i3)=NaN;
                    sprRmseX(i2,i3)=NaN;
                    sprRsqY(i2,i3)=-Inf;
                    sprSseY(i2,i3)=NaN;
                    sprRmseY(i2,i3)=NaN;
                    filtSpr(i2,i3)=1;
                    cntStep=cntStep+1;
                end
            end
        end
    end
    
    %% progress bar refining
    progressbar(i2/data.numPaths);
end

% assign the SPR velocities, paths, and statistics from the SPR corrected steps
data.pSprX=pSprX;
data.pSprY=pSprY;
data.stepSprX=stepSprX;
data.stepSprY=stepSprY;
data.vSprX=stepSprX;
data.vSprY=stepSprY;
data.stepSprXCorr=stepSprXCorr;
data.stepSprYCorr=stepSprYCorr;
data.sprRsqX=sprRsqX;
data.sprSseX=sprSseX;
data.sprRmseX=sprRmseX;
data.sprRsqY=sprRsqY;
data.sprSseY=sprSseY;
data.sprRmseY=sprRmseY;

data.filtSpr=filtSpr;