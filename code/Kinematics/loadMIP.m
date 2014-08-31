%% Load the MIPs

% Note that images should be loaded into imageJ or Fiji before running
% code. Images should be arranged into hyperstack and saved as tiff stack.
% stacks should be 8 bit greyscale images. 
% Code below assumes these steps have been taken. The images in stacks made
% this way are organized into a structured array, arranged in linear
% indexing by channels x frames such that images 1-4 are the four
% channels in the first frame. 

function data=loadMIP(data)


% select the TIFF image, exported as hyperstack from Imagej
[data.MIPFile,data.MIPDir,idx] = uigetfile('*.tif','Select the image MIP TIFF file');


% get the info about the stack
info=imfinfo(sprintf('%s/%s',data.MIPDir,data.MIPFile));
display(sprintf('Total images in MIP: %i',length(info)));

% print the hyperstack details from the first image 
display(sprintf('MIP image info: \n%s',info(1).ImageDescription));

% get time, slice, and channel information from user
data.frTot=input('How many total frames are available ? ');
data.fr0=input('What number is the first frame to be used in analysis? ');
data.frFin=input('What number is the final frame to be used in analysis? ');
data.chTot=input('How many channels are available? ');
data.chPV=input('Which channel to use for kinematics measurement? ');

% Compute / input the total number of frames, slices, channels
data.numFr=data.frFin-data.fr0+1;
display(sprintf('Total frames used: %i',data.numFr));

% get the total number of resulting time points
data.tAnsys=input('How many total time points to analyze at (Rounded to regular increment)? ');
data.frInc=floor(data.numFr/data.tAnsys);

% make a vector of time frame numbers
data.tsVec=data.fr0:data.frInc:data.frFin;

% used time points
data.numSt=length(data.tsVec);

% reference time and frame step vectors
data.tsFr=(0:1:data.numSt-1);

% incremental time step and vector of steps
data.tStepInc=data.stept*data.frInc;
data.ts=data.tStepInc.*data.tsFr;
data.tsm1=data.ts(1:1:(end-1));

% get the window size for window matching from use
data.winSzPix=input('Window edge-length for window matching (Must be even)? ');

% get the search size in X and Y (do not have to be equal)
winStepX=input('Window search size in X (Must be even)? ');
winStepY=input('Window search size in Y (Must be even)? ');
% Space the search region around the center of the approximated path location
data.winStepXMin=-winStepX/2;
data.winStepXMax=winStepX/2;
data.winStepYMin=-winStepY/2;
data.winStepYMax=winStepY/2;

% progress bar init
progressbar('% MIPs loaded');

% counter for loaded images (starts with the channel)
cnt=data.chPV;

% loop over all time frames
for i1=1:1:data.numSt
    
    % read the image
    im=imread(sprintf('%s/%s',data.MIPDir,data.MIPFile),'Index',cnt);
    
    
    % flip the image over its horizontal axis. This ensures that
    % X,Y is in lower right hand corner of original image, matching
    % acquisition
    im=flipud(im);
    
    % convert to double (scaled to [0,1])
    im=im2double(im);
    
    % filter PIV image channel
    %  See Gui et. al. "Digital Filters for Reducing ..."
    
    %                 % Wiener noise filtering
    %                 imWie=wiener2(im,[3 3]);
    
    %                 % Median filtering
    %                 imMed=medfilt2(im,[3 3]);
    
    % Smooth to smooth local variation
    rSmo=1;
    f3=(1/((2*rSmo+1)^2))*ones((2*rSmo+1),(2*rSmo+1));
    imSmo=imfilter(im,f3);
    
    %                 % Smooth twice
    %                  imSmo2X=imfilter(imSmo,f3);
    
    % Unsharp to remove high-frequency background noise
    rUns=75;
    f4=(1/((2*rUns+1)^2))*ones((2*rUns+1),(2*rUns+1));
    imUns=imfilter(im,f4);
    
    % Smooth - Unsharp (µPIV filter)
    imSmoUns=imSmo-imUns;
    
    %                 % Set all negative values in µPIV filter to zero
    %                 imSmoUnsNN=imSmoUns.*(double(imSmoUns>=0));
    
    % Median then Smooth
    %                 imMedSmo=imfilter(imMed,f3);
    
    
    % Replace the original image with filtered images
    imFilt=imSmoUns;
    
    
    % store the images in the structure
    imMIP(i1,:,:)=imFilt;
            
    % increment the counter of loaded images
    cnt=cnt+data.chTot*data.frInc;
    
    % Display a progress bar for this loop
    progressbar(i1/data.numSt);

end





% set the image size parameters from the final image
% XY image sizes
data.MIPMinX=0;
data.MIPMinY=0;
data.MIPMaxX=size(im,2);
data.MIPMaxY=size(im,1);
data.MIPXLen=data.MIPMaxX-data.MIPMinX;
data.MIPYLen=data.MIPMaxY-data.MIPMinY;
data.camMIPROI=[data.MIPMinY+1 data.MIPMinX+1 data.MIPMaxY+1 data.MIPMaxX+1];
data.xPxMIPVec=data.MIPMinX:1:data.MIPMaxX;
data.yPxMIPVec=data.MIPMinY:1:data.MIPMaxY;
data.zPxMIPVec=1;
data.xMMIPVec=data.xPxMIPVec*data.mPxXMIP;
data.yMMIPVec=data.yPxMIPVec*data.mPxYMIP;
data.zMMIPVec=data.zPxMIPVec*data.mPxZMIP;

% normalize the data to the max of the entire stack per channel
% loop over all channels that are active
minMIP=min(min(min(min(imMIP))));
maxMIP=max(max(max(max(imMIP))));
imMIP=(imMIP-minMIP)./(maxMIP-minMIP);


% store in the data structure
data.imMIP=imMIP;


