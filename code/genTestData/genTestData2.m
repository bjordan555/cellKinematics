%% Create test data for strain rate analysis

%% To Do
% %% Introduce more complex velocity and strain rate fields to simulate real cells
% %% Project onto cylinder and then back into MIP or image stack
% %% Introduce noise to simulate background
% %% Does rounding do best job of simulating how CCD converts from microscope?  Splitting light intensity between pixels by difference is better
% %% Warnings about non-mathing chekcsums are false usually, due to machine precision. Fix this by truncation of value and then comparing
% %% Add in transient noise
% %% Output paths of each point to SPR and PR for comparison with data
% %% Fix feature and random noise to work with new interpolation
% %% Output slices as well as MIP, for 3D tracking and reconstruction
% %% Implement 3D PSF and output stacks
% %% Add simple Beer's law to Bf simulation to show stripes
% %% Increase total radius of PSF to eliminate boundaries in fl images
% %% Rewrite PSF distribution routine as the convolution of a discrete number
%       of Gaussians, i.e. the fundamental solution at some small time step,
%       without any further evolution.  This is given by Fourier series of
%       discrete pixel intensity valules over the entire image, and the
%       resulting continuous function is used to represent the entire image
%       field. This is also useful for analyzing higher order velocity and
%       deformation corrections, as well as for utilizing the FFT.
% %% Compute the z-slicing when cylindrical transformation is used. It is
%       not equal to the value currently set in the roi.

%% Initialize
clear all
close all

%% Remove existing images from output directory
delete './simData/current/*.tif';

%% Time

% time between frames in material model and experiment model
ts=1800;

% offset for time to start, short for elastic, long for growth, plasmolyse
% intermediate, any other scales?
tOff=7200;

% number of time frames
nT=5;

% vector of times
tVec=tOff:ts:(nT-1)*ts+tOff;

%% Slices
% the number of optical slices to output
% nSl=21;   % cylindrical model
nSl=1;      % planar model

%% on/off of cylindrical transformation.
cylTransform=0;

%% Experiment Model Parameters
% interpolation grid to simulate CCD
lXPix=512;
lYPix=512;
lZPix=nSl;

% microscope sampling density in meters
mPxX=8.7109856625714274E-08;
mPxY=8.7109856625714274E-08;
mPxZ=4.0999999999999973E-07;

% compute micron versions of lengths
lX=lXPix*mPxX;
lY=lYPix*mPxY;
lZ=lZPix*mPxZ;

% make a vector of lengths in microns
lXVec=lX*(0:1:lXPix-1);
lYVec=lX*(0:1:lYPix-1);
lZVec=lX*(0:1:lZPix-1);

% number of sub-pixels per pixel
sprF=100;  % in plane
sprZ=1;  % in z

% SPR grid for experiment model
lXSpr=lXPix*sprF;
lYSpr=lYPix*sprF;
lZSpr=lZPix*sprZ;

% number of tracking points to simulate
nC=2000;

% PSF parameters
% a.u. intensity value for points to track.
auMean=60000;
auDev=5536;  % how much to vary above and below mean intensity

% covariance of PSF in pixels, equal in both directions.
rCSigSq=12^2;
% Radius in pixels over which to distribute the light from a single point
rC=ceil(sqrt(rCSigSq)/2);
% effective finite radius of Airy disc Gaussian approximation
rCSpr=rC*sprF;
rCSigSqSpr=rCSigSq*sprF;

% X = horizontal offset from fixed base of cell along cell axis for location of images taken on cell
% lXOff=5E-4; % model from Maple
lXOff=0; % linear velocites with iso-homo-growth
lXOffPix=lXOff/mPxX;
lXOffSpr=lXOffPix*sprF;

%% Material Model BCs, ICs and Parameters
% Geometry initial conditions of cell at simulated / experimental time t=0.
R=lY;               % meters
L=lX;              % meters
RPix=floor(R/mPxY);     % pixels
RSpr=RPix*sprF;         % subpixels

%% midcurve generator of cell
SSpr=floor(lYSpr/2);   % a straight generator at half the image height
SPix=floor(lYPix/2);

%% Velocity field functions
vX=inline('1E-11+1E-9*x/L0','x','L0');
vY=inline('-1E-11-0.5E-9*x/L0','x','L0');
% vY=inline('0','x','L0');

%% Radius
rCur=inline('R0','R0');
lCur=inline('L0','x','y','t','L0');

for i1=1:1:nT
    
    rNBar(i1)=rCur(R);
    rNPixBar(i1)=floor((1/mPxX)*rNBar(i1));
    rNSprBar(i1)=floor(sprF*(1/mPxX)*rNBar(i1));
    
end

%% plot of the radius
display('Plot of the average (homogeneous) radius');
h=figure(34343432);
clf;
plot(tVec,rNBar);
title(sprintf('Average radius'));
xlabel('time (s)'); ylabel('rNBar (m)');
drawnow;

%% FEATURE SERIES %%
%% Create tracking points and apply velocity field
display('Creating random bead distribution');
%% progress bar init
progressbar('% Tracking Features Generated');

for i1=1:1:nT
    
    % Note below that the velocity fields use the R and RSpr values to
    % parameterize the function.
    if i1==1
        % make vector of random points on SPR grid at t=1
        % Horizontally oriented cell, so anywhere in X...
        cXSpr0=randi(lXSpr,[nC,1]);
        % ... and within the cell diameter in Y, centered in the middle of
        % the frame in Y.
        % Note that the beads in the first frame that is simulated is at
        % t=tOff.  The beads are then displaced at a velocity given for the
        % subsequent simulated strains
        cYSpr0=randi(lYSpr,[nC,1]);
%         cYSpr0=randi(2*RSpr,[nC,1])-RSpr+SSpr;
                
        % dereference the X position to determine velocity field (velocity
        % fields for perfect cylinder model do not depend on X.
        cXCur=mPxX.*(cXSpr0+lXOffSpr)./sprF;
        cYCur=mPxY.*(cYSpr0)./sprF;
        
        % displace these first points to their positions at t=tOff
        vXSpr(:,i1)=sprF*vX(cXCur,L)*ts./mPxX;
        vYSpr(:,i1)=sprF*vY(cXCur,L)*ts./mPxY;
        cXSpr(:,i1)=cXSpr0+vXSpr(:,i1);
        cYSpr(:,i1)=cYSpr0+vYSpr(:,i1);
        
    else
        % convert velocity field from material model from um to spr pixels.  Note that both velocity functions
        % take in the previous axial coordinate X as their argument, as v is only a
        % function of axial position and time
        tCur=(i1-1)*ts+tOff;
        cXCur=mPxX.*(cXSpr(:,i1-1)+lXOffSpr)./sprF;
        cYCur=mPxY.*(cYSpr(:,i1-1))./sprF;
        % displace the previous frames points to their positions at t=tOff+(i-1)*ts
        vXSpr(:,i1)=sprF*vX(cXCur,L)*ts./mPxX;
        vYSpr(:,i1)=sprF*vY(cXCur,L)*ts./mPxY;
        cXSpr(:,i1)=cXSpr(:,i1-1)+vXSpr(:,i1);
        cYSpr(:,i1)=cYSpr(:,i1-1)+vYSpr(:,i1);
    end
    %% Display a progress bar for this loop
    progressbar(i1/nT);
end

%% Transform points in unrolled cylinder into stack and MIP (see np 12.70)
for i1=1:1:nT
    
    % if cylTransform==1, the points are projected onto the cylinder, if it
    % equals zero, then it is not transformed, and the planar point
    % coordinates are used for the next steps
    if cylTransform==0
        if i1==1
            display('Cylinder transformation: OFF');
        end
        cXStSpr(:,i1)=cXSpr(:,i1);
        cYStSpr(:,i1)=cYSpr(:,i1);
        cZStSpr(:,i1)=zeros(nC,1);            % the unrolled plane
    elseif cylTransform==1
        if i1==1
            display('Cylinder transformation: ON');
        end
        % Note that the functions below use rNSprBar(i1) to transform the plane
        % onto the cylinder.
        
        % center y at origin (horizontally oriented cylinder)
        cyCylCentSpr(:,i1)=cYSpr(:,i1)-SSpr;
        % find the cylindrical angle
        thetaCyl(:,i1)=-cyCylCentSpr(:,i1)./rNSprBar(i1)+pi/2;
        % project into stack
        cyStCentSpr(:,i1)=rNSprBar(i1).*cos(thetaCyl(:,i1));
        czStCentSpr(:,i1)=rNSprBar(i1).*sin(thetaCyl(:,i1));
        % shift y back to image coords
        cYStSpr(:,i1)=cyStCentSpr(:,i1)+SSpr;
        % x and z don't change
        cXStSpr(:,i1)=cXSpr(:,i1);
        cZStSpr(:,i1)=czStCentSpr(:,i1);
    else
        display('Error (genTestData.m): cylTransform must be 0 or 1');
    end
end

%% Plot the tracking points
plotTestPaths(cXStSpr,cYStSpr,cZStSpr,sprF,lXSpr,SSpr,rNSprBar);

%% Distribute intensities around points in SPR image

% compute the min and max z values for features in all time steps to set
% the bounds on the image stack size
zStMinMin=min(min(cZStSpr));
zStMaxMax=max(max(cZStSpr));

% compute the total z-length spanned by all features in stack
lZPixSpan=ceil(zStMaxMax-zStMinMin)./sprF;

% compute the number of slices needed from the voxel dimensions
xzSampRat=mPxX/mPxZ;
numSl=ceil(lZPixSpan*xzSampRat)+1;

% init the images
for i1=1:1:nT
    imMIP{i1}=zeros(lYPix,lXPix);
    imSt{i1}=zeros(lYPix,lXPix,numSl);
end
% progress bar init
progressbar('% Tracking Point PSF Generation Complete');
display('Generating SPR PSFs');
for i2=1:1:nC
    for i1=1:1:nT
        pXSpr=cXStSpr(i2,i1);
        pYSpr=cYStSpr(i2,i1);
        pZSpr=ceil((cZStSpr(i2,i1)-zStMinMin)*xzSampRat./sprF);
        
        % check if point is inside SPR image stack boundaries
        if (pXSpr+rCSpr)<=lXSpr && (pYSpr+rCSpr)<=lYSpr ...
                && (pXSpr-rCSpr)>0 && (pYSpr-rCSpr)>0 && ...
                pZSpr>=0 && pZSpr<=numSl;
            
            % compute the PR normal distribution (binomial)
            [zzRenormPr,xPrPr,yPrPr]=interpSprPsf(pXSpr,pYSpr,rC,sprF,rCSpr,rCSigSqSpr,auMean, auDev);
            
            % Make 3D image and then do MIP
            % multiply the intensities of the normal by the tracking point intensity
            % add this to the total slice image
            % subtract the min z coordinate to minimize stack size
            zPrPr=pZSpr+1;
            imSt{i1}(yPrPr,xPrPr,zPrPr)=zzRenormPr+imSt{i1}(yPrPr,xPrPr,zPrPr);
            % Make the MIP
            [imMIP{i1} zIdx{i1}]=max(imSt{i1},[],3);
        end
        
    end
    % Display a progress bar for this loop
    progressbar(i2/nC)
end

%% Round images to the nearest integer for storage as indexed image file
for i1=1:1:nT
    imMIPInt{i1}=uint16(round(imMIP{i1}));
    imStInt{i1}=uint16(round(imSt{i1}));
end

%% Add noise and filter images to make more realistic CCD simulation
for i1=1:1:nT
    
    % add noise (Gaussian, Poisson, etc)
    imMIPInt{i1}=imnoise(imMIPInt{i1},'gaussian',0.01,0.001);
    imStInt{i1}=imnoise(imStInt{i1},'gaussian',0.01,0.001);
    
    % filter 
    H = fspecial('gaussian',[20 20],1);
    imMIPInt{i1}= imfilter(imMIPInt{i1},H,'replicate');
    imStInt{i1}= imfilter(imStInt{i1},H,'replicate');

end

%% Display the feature image series
display('Displaying the feature image series');
h=figure(2);
set(h,'Position',[1 1 2*lXPix lYPix])
cla;
for i1=1:1:nT
    hold on
    imagesc(imMIPInt{i1});
    set(gca,'YDir','Normal')
    title(sprintf('Simulated %ix%i (rowsxcols) feature MIP image at t=%i',lYPix,lXPix,i1));
    colormap(gray);
    colorbar
    xlabel('x=j'); ylabel('y=i');
    axis equal
    drawnow;
    pause(0.25)
end

%% Save the feature MIP and Stack series to files
display('Saving feature images');
for i1=1:1:nT
    % write the MIP
    imDirFile=sprintf('./simData/current/simImMIP_t%1.3i_z000_c000.tif',i1);
    %     imwrite(im{i1},gray,imDirFile,'tif','Compression','none');
    % See "Exporting to images" in MATLAB help for details on TIFF
    tifImg= Tiff(imDirFile,'w');
    tagstruct.ImageLength = size(imMIPInt{i1},1);
    tagstruct.ImageWidth = size(imMIPInt{i1},2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.RowsPerStrip = 16;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software = 'MATLAB';
    tagstruct.Compression=Tiff.Compression.None;
    tifImg.setTag(tagstruct);
    tifImg.write(imMIPInt{i1});
    tifImg.close();
    
    % write the stack
    for i2=1:1:numSl
        imDirFile=sprintf('./simData/current/simImSt_t%1.3i_z%1.3i.tif',i1,i2-1);
        % See "Exporting to images" in MATLAB help for details on TIFF
        tifImg= Tiff(imDirFile,'w');
        tagstruct.ImageLength = size(imStInt{i1}(:,:,i2),1);
        tagstruct.ImageWidth = size(imStInt{i1}(:,:,i2),2);
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.RowsPerStrip = 16;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'MATLAB';
        tagstruct.Compression=Tiff.Compression.None;
        tifImg.setTag(tagstruct);
        tifImg.write(imStInt{i1}(:,:,i2));
        tifImg.close();
    end
    
end

