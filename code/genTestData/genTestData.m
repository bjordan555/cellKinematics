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
lXPix=2000;
lYPix=400;
lZPix=nSl;

% microscope sampling density in meters
mPxX=8.7109856625714274E-08;
mPxY=8.7109856625714274E-08;
mPxZ=4.0999999999999973E-07;

% compute micron versions of lengths
lX=lXPix*mPxX;
lY=lYPix*mPxY;
lZ=lZPix*mPxZ;

% number of sub-pixels per pixel
sprF=100;  % in plane
sprZ=100;  % in z

% SPR grid for experiment model
lXSpr=lXPix*sprF;
lYSpr=lYPix*sprF;
lZSpr=lZPix*sprZ;

% number of tracking points to simulate
nC=1000;

% PSF parameters
% Specific constraints for image format tif require only certain values. Use <=64 for now.
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
R=200E-6;               % meters
L=2000E-6;              % meters
RPix=floor(R/mPxY);     % pixels
RSpr=RPix*sprF;         % subpixels
BigDeltaW=5E-6;         % meters
BigAlpha=0.12;          % radians
epsilonDotGf=0;      % isotropic growth strain rate (negative sign for increasing volume) (1/s)
deltaLx=1E-7;        % displacement per time step in x (m)
deltaLy=1E-7;     % ... and in y (m)

%% BF SERIES
% check if entire cell diameter in the first frame
if 2*R>lY
    display(sprintf('Cell initial condition has larger diameter than image plane Y dimension. 2*R=%f<%f=lY',2*R,lY));
end

%% midcurve generator of cell
SSpr=floor(lYSpr/2);   % a straight generator at half the image height
SPix=floor(lYPix/2);

%% Velocity and radius from Maple model
% specify velocity field from model solution.  The model velocities are given is given most generally as
% vx(x,y,z,t;BigAlpha0,BigDeltaW0,L0,R0) and vz(a,y,z,t;BigAlpha0,BigDeltaW0,L0,R0).  For image coordinates, z->X and x->Y. ,'z','t','BigAlpha0','BigDeltaW0','L0','R0');
% vY=inline('.200000000000000000000000000000e-39*(.424780142525866905782287084043e89*t^(213/50)-.185961792203940687128884296576e83*t^(497/100)+.766146708369886874843050607960e97*t^(71/25)+.126067997172271155316788148084e94*t^(71/20)-.266361605879971169233218236705e78*t^(142/25)+.374091333530035044193299026686e102*t^(71/100)+.858311622942238140296087836305e99*t^(213/100)+.313496914136728446131058408471e101*t^(71/50)-248727638196040190505372567669.*t^(781/100)-.500000000000000000000000000000e74+.459053957584694913371569400540e71*t^(639/100)+.419423472062604169532306056166e66*t^(71/10))*z/(299535476400000.+11776296633300.*t^(71/100)+799773893.*t^(71/50))^2/(t^(213/100)+40020.*t^(71/50)-319599262310.*t^(71/100)-9984515880000.)^2/(t^(71/100)+2000000.)^2/t^(29/100)','z','y','t','BigAlpha0','BigDeltaW0','L0','R0');
% vX=inline('-.100000000000000000000000000000e-40*(.210568871343602379941199893798e90*t^(213/50)-.886572358398088234648689164284e83*t^(497/100)-.389780062560133848973872802370e99*t^(71/25)+.585016352920387514190788328541e94*t^(71/20)-.130751367578885939745886693650e79*t^(142/25)-.188378654337836033414285890106e104*t^(71/100)-.442280243894237204737482336858e101*t^(213/100)-.161278507833918629221917559096e103*t^(71/50)+778617543418028029859450584541.*t^(781/100)+.846735255684435531494764207810e103+.220409874761785507114747147223e72*t^(639/100)+.205175290308338710506344601054e67*t^(71/10))*z/(299535476400000.+11776296633300.*t^(71/100)+799773893.*t^(71/50))^2/(t^(213/100)+40020.*t^(71/50)-319599262310.*t^(71/100)-9984515880000.)^2/(t^(71/100)+2000000.)^2/t^(29/100)','z','y','t','BigAlpha0','BigDeltaW0','L0','R0');
% vN=inline('.100000000000000000000000000000e-42*(.406709580880764697587033379371e88*t^(213/50)-.190073302149156549986446554439e82*t^(497/100)+.153172124284315365832709784295e98*t^(71/25)+.134314439483661465454133986825e93*t^(71/20)-.259419608429436145598232404138e77*t^(142/25)+.205269064089072104684071760148e103*t^(71/100)+.173797207556234242659008776556e100*t^(213/100)+.844076544256028247791041128171e101*t^(71/50)+112959050868360560597189011691.*t^(781/100)+.201522990852895656495753881418e104+.463898421301022867766709089300e70*t^(639/100)+.410916221721911570856639263088e65*t^(71/10))/(299535476400000.+11776296633300.*t^(71/100)+799773893.*t^(71/50))^2/(t^(213/100)+40020.*t^(71/50)-319599262310.*t^(71/100)-9984515880000.)^2/(t^(71/100)+2000000.)^2/t^(29/100)','z','y','t','BigAlpha0','BigDeltaW0','L0','R0');
% rCur=inline('.100000000000000000000000000000e-22*(419806561202485552433381895507.*t^(213/50)-.128805773951837222719772949629e42*t^(71/25)+.138946656474741222342335207194e36*t^(71/20)-.857999004107236158983904000000e52*t^(71/100)-.153287769356527898224462594872e51*t^(71/50)-.390229084697183956806641741700e47*t^(213/100)-.119628668829566609280000000000e54)/(t^(71/100)+2000000.)/(t^(213/100)+40020.*t^(71/50)-319599262310.*t^(71/100)-9984515880000.)/(299535476400000.+11776296633300.*t^(71/100)+799773893.*t^(71/50))','t','BigAlpha0','BigDeltaW0','L0','R0');

%% planar linear constitutive velocities in x with isotropic homogeneous volumetric growth (see np.12.149)
vY=inline('(1/2)*(deltaLy0/(2*pi*R0))*z+epsilonDotGf0*y','z','y','t','BigAlpha0','BigDeltaW0','L0','R0','epsilonDotGf0','deltaLx0','deltaLy0');
vX=inline('(deltaLx0/L0)*z+epsilonDotGf0*z','z','y','t','BigAlpha0','BigDeltaW0','L0','R0','epsilonDotGf0','deltaLx0','deltaLy0');
% vN=inline('?','z','y','t','BigAlpha0','BigDeltaW0','L0','R0','epsilonDotGf0','deltaLx0','deltaLy0');
% radius.  This is very large to infinite in the planar case. 
rCur=inline('R0','t','BigAlpha0','BigDeltaW0','L0','R0','epsilonDotGf0','deltaLx0','deltaLy0');
% length. A useful quantity for determining the coupling of anisotropy and aspect ratio
lCur=inline('L0','t','BigAlpha0','BigDeltaW0','L0','R0','epsilonDotGf0','deltaLx0','deltaLy0');
% the strain rates. 
epsDotCX=inline('deltaLx0/L0','L0','deltaLx0');
epsDotCY=inline('epsilonDotGf0','epsilonDotGf0');
epsDotCN=inline('-epsilonDotGf0','epsilonDotGf0');
epsDotCXY=inline('(1/2)*deltaLy0/(2*pi*R0)','deltaLy0','R0');

%% Plot of the strain rates

%compute each time point as a vector
for i1=1:1:nT
    epsDotCXVec(i1)=epsDotCX(L,deltaLx);
    epsDotCYVec(i1)=epsDotCY(epsilonDotGf);
    epsDotCNVec(i1)=epsDotCN(epsilonDotGf);
    epsDotCXYVec(i1)=epsDotCXY(deltaLy,R);
end

% plot the strain rates
figure(234843443)
clf;
hold on
plot(tVec,epsDotCXVec,'-c');
plot(tVec,epsDotCYVec,'-m');
plot(tVec,epsDotCNVec,'-y');
plot(tVec,epsDotCXYVec,'-k');
title('Simulated Strain Rates');
legend('epsX','epsY','epsN','epsXY');
xlabel('time (s)');
ylabel('strain rate (1/s)');
drawnow;

% check if entire cell diameter in each frame
for i1=1:1:nT
    if 2*rCur((i1-1)*ts+tOff,BigAlpha,BigDeltaW,L,R,epsilonDotGf,deltaLx,deltaLy)>lY
        display(sprintf('Warning(genTestData.m): Cell has larger in frame %i diameter than image plane Y dimension. 2*R=%f<%f=lY',i1,2*R,lY));
    end
end

%% create MIP Bf projection model for radius measurement
display('Building Bf model data for radius measurement');

%% progress bar init
progressbar('% BF MIPs Generated');

for i1=1:1:nT
    yVec=1:1:lYPix;
    yVec=yVec';
    % make vertical strips
    for i2=1:1:lXPix
        % dereference rCur for this point
        rN=rCur((i1-1)*ts+tOff,BigAlpha,BigDeltaW,L,R,epsilonDotGf,deltaLx,deltaLy);
        
        filtGt=any(abs(yVec-1-SPix) > (1/mPxY)*rN,2);
        filtEq=any(abs(yVec-1-SPix) == floor((1/mPxY)*rN),2);
        % make intensity here propotional to difference. rDiff is < 1
        rDiff=((1/mPxY)*rN-floor((1/mPxY)*rN));
        filtGtVal=filtGt*auMean;
        filtEqVal=floor(filtEq*rDiff*auMean);
        imBfMIP{i1}(:,i2)=uint16(filtGtVal)+uint16(filtEqVal);
    end
    rNBar(i1)=mean(rCur((i1-1)*ts+tOff,BigAlpha,BigDeltaW,L,R,epsilonDotGf,deltaLx,deltaLy));
    rNPixBar(i1)=floor((1/mPxX)*rNBar(i1));
    rNSprBar(i1)=floor(sprF*(1/mPxX)*rNBar(i1));
    
    %% Display a progress bar for this loop
    progressbar(i1/nT);
end

%% plot of the radius
display('Plot of the average (homogeneous) radius');
h=figure(34343432);
clf;
plot(tVec,rNBar);
title(sprintf('Average radius'));
xlabel('time (s)'); ylabel('rNBar (m)');
drawnow;


%% Display the BF image series
display('Displaying the BF image series');
h=figure(2);
set(h,'Position',[1 1 lXPix lYPix])
clf;
for i1=1:1:nT
    
    %     % plot of the sum of the images
    %     if i1==1
    %         imSum=imBfMIP{i1}./nT;
    %     else
    %         imSum=imSum+imBfMIP{i1}./nT;
    %     end
    %     % plot the sum of the Bf images
    %     imagesc(imSum);
    
    % plot each of the Bf images
    imagesc(imBfMIP{i1});
    
    set(gca,'YDir','normal')
    title(sprintf('Sum of simulated %ix%i (rowsxcols) BF MIP CCD image at t=%i',lYPix,lXPix,i1));
    colormap(gray);
    colorbar
    xlabel('x=j'); ylabel('y=i');
    % axis equal
    drawnow;
    pause(0.25)
end

% plot the top (max) and bottom (min) radii, and generator in the above figure
for i1=1:1:nT
    
    xCrv=[1 lXPix];
    yMin=[SPix-rNPixBar(i1) SPix-rNPixBar(i1)];
    yMax=[SPix+rNPixBar(i1) SPix+rNPixBar(i1)];
    yMid=[SPix SPix];
    
    hold on
    plot(xCrv, yMin,'--r');
    plot(xCrv, yMax,'--r');
    plot(xCrv, yMid,'--r');
    hold off
    
    drawnow;
    
end

%% Save the Bf radius image series to files
display('Saving Bf radius images');
for i1=1:1:nT
    imDirFile=sprintf('./simData/current/simBf_t%1.3i_z000.tif',i1);
    %     imwrite(im{i1},gray,imDirFile,'tif','Compression','none');
    
    % See "Exporting to images" in MATLAB help for details on TIFF
    tifImg= Tiff(imDirFile,'w');
    tagstruct.ImageLength = size(imBfMIP{i1},1);
    tagstruct.ImageWidth = size(imBfMIP{i1},2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.RowsPerStrip = 16;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software = 'MATLAB';
    tagstruct.Compression=Tiff.Compression.None;
    tifImg.setTag(tagstruct);
    tifImg.write(imBfMIP{i1});
    tifImg.close();
end

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
        cYSpr0=randi(2*RSpr,[nC,1])-RSpr+SSpr;
        
        % dereference the X position to determine velocity field (velocity
        % fields for perfect cylinder model do not depend on X.
        cXCur=mPxX.*(cXSpr0+lXOffSpr)./sprF;
        cYCur=mPxY.*(cYSpr0)./sprF;
        
        % displace these first points to their positions at t=tOff
        vXSpr(:,i1)=sprF*vX(cXCur,cYCur,tOff,BigAlpha,BigDeltaW,L,R,epsilonDotGf,deltaLx,deltaLy)*ts./mPxX;
        vYSpr(:,i1)=sprF*vY(cXCur,cYCur,tOff,BigAlpha,BigDeltaW,L,R,epsilonDotGf,deltaLx,deltaLy)*ts./mPxY;
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
        vXSpr(:,i1)=sprF*vX(cXCur,cYCur,tCur,BigAlpha,BigDeltaW,L,R,epsilonDotGf,deltaLx,deltaLy)*ts./mPxX;
        vYSpr(:,i1)=sprF*vY(cXCur,cYCur,tCur,BigAlpha,BigDeltaW,L,R,epsilonDotGf,deltaLx,deltaLy)*ts./mPxY;
        cXSpr(:,i1)=cXSpr(:,i1-1)+vXSpr(:,i1);
        cYSpr(:,i1)=cYSpr(:,i1-1)+vYSpr(:,i1);
    end
    %% Display a progress bar for this loop
    progressbar(i1/nT);
end

%% Transform points in unrolled cylinder into stack and MIP (see np 12.70)
display('Transforming onto the cylinder, or not...');
for i1=1:1:nT
    
    % if cylTransform==1, the points are projected onto the cylinder, if it
    % equals zero, then it is not transformed, and the planar point
    % coordinates are used for the next steps
    if cylTransform==0
        cXStSpr(:,i1)=cXSpr(:,i1);
        cYStSpr(:,i1)=cYSpr(:,i1);
        cZStSpr(:,i1)=zeros(nC,1);            % the unrolled plane
    elseif cylTransform==1
        
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

%% Flip the images about the horizontal axis (xy)
progressbar('% Images Flipped about horizontal axis');
display('Flipping images');
for i1=1:1:nT
    imMIPIntHf{i1}=flipud(imMIPInt{i1});
    for i2=1:1:size(imStInt{i1},3)
        imStIntHf{i1}(:,:,i2)=flipud(imStInt{i1}(:,:,i2));
    end
    % Display a progress bar for this loop
    progressbar(i1/nT);
end

%% Display the feature image series
display('Displaying the feature image series');
h=figure(2);
set(h,'Position',[1 1 2*lXPix lYPix])
cla;
for i1=1:1:nT
    hold on
    imagesc(imMIPIntHf{i1});
     set(gca,'YDir','reverse')
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
    imDirFile=sprintf('./simData/current/simImMIP_t%1.3i_z000.tif',i1);
    %     imwrite(im{i1},gray,imDirFile,'tif','Compression','none');
    % See "Exporting to images" in MATLAB help for details on TIFF
    tifImg= Tiff(imDirFile,'w');
    tagstruct.ImageLength = size(imMIPIntHf{i1},1);
    tagstruct.ImageWidth = size(imMIPIntHf{i1},2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.RowsPerStrip = 16;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software = 'MATLAB';
    tagstruct.Compression=Tiff.Compression.None;
    tifImg.setTag(tagstruct);
    tifImg.write(imMIPIntHf{i1});
    tifImg.close();
    
    % write the stack
    for i2=1:1:numSl
        imDirFile=sprintf('./simData/current/simImSt_t%1.3i_z%1.3i.tif',i1,i2-1);
        % See "Exporting to images" in MATLAB help for details on TIFF
        tifImg= Tiff(imDirFile,'w');
        tagstruct.ImageLength = size(imStIntHf{i1}(:,:,i2),1);
        tagstruct.ImageWidth = size(imStIntHf{i1}(:,:,i2),2);
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.RowsPerStrip = 16;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'MATLAB';
        tagstruct.Compression=Tiff.Compression.None;
        tifImg.setTag(tagstruct);
        tifImg.write(imStIntHf{i1}(:,:,i2));
        tifImg.close();
    end
    
end

