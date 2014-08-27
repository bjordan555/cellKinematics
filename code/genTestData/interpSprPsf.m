%% Make a SPR PSF Gaussian approximation to Airy disc and interpolate onto PR grid
function [zzRenormPr,xPrPr,yPrPr]=interpSprPsf(muXSpr,muYSpr,rC,sprF,rCSpr,rCSigSqSpr,auMean,auDev)

% This should be replaced with a one step interpolator using the the Fourier or Green's function solution to the field. 

% muXSpr, muYSpr are mean of Gaussian in SPR grid
% sigX, sigY are std. dev. of Gaussian in PR grid
% rC is the total radius of the Gaussian in pixels
% sprF is the number of subpixels per pixel

% file specific verbosity
tV=3;

% mean and std. dev. of Gaussian
muSpr=[muXSpr,muYSpr];
sigSpr=[rCSigSqSpr 0;0 rCSigSqSpr];

% the PR means (floor implies that each pixel starts in the lower left and
% extends to the upper right)
muX=ceil(muXSpr/sprF);
muY=ceil(muYSpr/sprF);

% vectors for x and y PR grid lines that define the pixel boundaries
% note that the pixel grid is centered at the origin, which splits 4 pixels

% the minimum, maximum pixel centers at SPR
xMin=muX*sprF-rC*sprF;
xMax=muX*sprF+rC*sprF;
yMin=muY*sprF-rC*sprF;
yMax=muY*sprF+rC*sprF;

% the grid of pixel centers at SPR
xPrSpr=xMin:sprF:xMax;
yPrSpr=yMin:sprF:yMax;

% the minimum, maximum pixel centers at PR
xMinPr=muX-rC;
xMaxPr=muX+rC;
yMinPr=muY-rC;
yMaxPr=muY+rC;

% the grid of pixel centers at PR
xPrPr=xMinPr:1:xMaxPr;
yPrPr=yMinPr:1:yMaxPr;

% vectors and grid for creating Gaussian
xSprMin=muXSpr-rCSpr;
xSprMax=muXSpr+rCSpr;
ySprMin=muYSpr-rCSpr;
ySprMax=muYSpr+rCSpr;

% make row vectors for SPR Gaussian function input
xi = linspace(xMin,xMax,length(xPrSpr)*sprF);
yi = linspace(yMin,yMax,length(yPrSpr)*sprF);

% make grid of points to evaluate at.
[xx,yy]=meshgrid(xi,yi);

% make the SPR Gaussian
% zzNormSpr=gauss2dNormal(xx,yy,muSpr,sigSpr);
zzNormSpr = mvnpdf([xx(:) yy(:)],muSpr,sigSpr);
zzNormSpr = reshape(zzNormSpr,length(yi),length(xi));



%% sum up the SPR Gaussian and interpolate into the PR grid
% init the PR Gaussian
zzNormPr=zeros(length(xPrPr),length(xPrPr));

% sum up the SPR Gaussian in each pixel to the PR Gaussian
for i1=1:1:(2*rC+1)
    for i2=1:1:(2*rC+1)
        xIdx=(1:1:sprF)+(i1-1)*sprF;
        yIdx=(1:1:sprF)+(i2-1)*sprF;
        zzNormPr(i1,i2)=sum(sum(zzNormSpr(xIdx,yIdx)));
    end
end
   
% renormalize the normal distribution so that the maximum value is auMean,
% and varies by  auDev around it.  The variation helps to increase std
% deviations of window matching algorithm. 
zzRenormPr=auMean*zzNormPr./(max(max(zzNormPr)))+auDev*randi(1);

% plot the SPR Gaussian and PR Gaussian on top of each other
if tV<=2
    figure(12342349)
    clf;
    hold on;
    
    % plot of the SPR Gaussian contour
    contour(xi,yi,zzNormSpr,10);
    
    % plot of the PR Gaussian image
    imagesc(xPrSpr,yPrSpr,zzRenormPr);
    alpha(0.75);    
    %caxis([0,1]);
    colorbar;
    colormap(jet);
    
    hold off;
    title('SPR Gaussian Contour and PR image');
    set(gca,'YDir','normal')
    xlabel('x');
    ylabel('y');
    axis([min(xMin,xSprMin) max(xMax,xSprMax) min(yMin,ySprMin) max(yMax,ySprMax)]);
    view(2);
    axis equal
    axis tight
    drawnow;

    pause
end