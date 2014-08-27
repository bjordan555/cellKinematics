%% Load the stack of images

% Note that images should be loaded into imageJ or Fiji before running
% code. Images should be arranged into hyperstack and saved as tiff stack.
% stacks should be 8 bit greyscale images. 
% Code below assumes these steps have been taken. The images in stacks made
% this way are organized into a structured array, arranged in linear
% indexing by channel x slices x frames such that images 1-4 are the four
% channels of the first slice in the first frame. 

function data=loadSt(data)

% select the TIFF image, exported as hyperstack from Imagej
[data.stFile,data.stDir,idx] = uigetfile('*.tif','Select the image stack TIFF file');

% get the info about the stack
info=imfinfo(sprintf('%s/%s',data.stDir,data.stFile));
display(sprintf('Total images in stack: %i',length(info)));

% print the hyperstack details from the first image 
display(sprintf('Stack image info: \n%s',info(1).ImageDescription));

% get time, slice, and channel information from user
data.frTot=input('How many total frames are available ? ');
data.fr0=input('What number is the first frame to be used in analysis (1) ? ');
data.frFin=input('What number is the final frame to be used in analysis ? ');
data.slTot=input('How many total slices are available ?');
data.sl0=input('What number is the first slice to be used in analysis (1) ? ');
data.slFin=input('What number is the final slice to be used in analysis ? ');
data.chTot=input('How many channels are available?');
data.chGeom=input('Which channel to use for geometry measurement? ');

% Compute / input the total number of frames, slices, channels
data.numFr=data.frFin-data.fr0+1;
data.numSl=data.slFin-data.sl0+1;
display(sprintf('Total frames used: %i',data.numFr));
display(sprintf('Total slices used: %i',data.numSl));

% get the total number of resulting time points
data.tAnsys=input('How many total time points to analyze at? ');
data.frInc=floor(data.numFr/data.tAnsys);

% make a vector of time frame numbers
data.tsVec=data.fr0:data.frInc:data.frFin;

% make a vector of slice numbers
data.slVec=data.sl0:1:data.slFin;

% used time points
data.numSt=length(data.tsVec);

% reference time and frame step vectors
data.tsFr=(0:1:data.numSt-1);

% incremental time step and vector of steps
data.tStepInc=data.stept*data.frInc;
data.ts=data.tStepInc.*data.tsFr;
data.tsm1=data.ts(1:1:(end-1));

% progress bar init
progressbar('% stacks loaded');

% counter for loaded images (starts with the channel)
cnt=data.chGeom;

% loop over all time frames
for i1=1:1:data.numSt
    
    % loop to load all slices in each stack
    for i2=1:1:data.numSl
        
        % read the image
        im=imread(sprintf('%s/%s',data.stDir,data.stFile),'Index',cnt);
        
        
        % flip the image over its horizontal axis. This ensures that
        % X,Y is in lower right hand corner of original image, matching
        % acquisition
        im=flipud(im);
        
        % convert to double (scaled to [0,1])
        im=im2double(im);
        
        %% filter geometry image channel
        %  See Gui et. al. "Digital Filters for Reducing ..."
        
        % Smooth
        rSmo=1;
        f3=(1/((2*rSmo+1)^2))*ones((2*rSmo+1),(2*rSmo+1));
        imSmo=imfilter(im,f3);
        
        % Replace the original image with filtered images
        imFilt=imSmo;
        
        % store the images in the structure
        imSt(i1,i2,:,:)=imFilt;
        
        % increment the counter of loaded images
        cnt=cnt+data.chTot;
        
    end
    
    %% Display a progress bar for this loop
    progressbar(i1/data.numSt);
end

% set the image size parameters from the final image
data.stMinX=0;
data.stMinY=0;
data.stMaxX=size(im,2);
data.stMaxY=size(im,1);
data.stXLen=data.stMaxX-data.stMinX;
data.stYLen=data.stMaxY-data.stMinY;
data.camStROI=[data.stMinY+1 data.stMinX+1 data.stMaxY+1 data.stMaxX+1];
data.xPxStVec=data.stMinX:1:data.stMaxX;
data.yPxStVec=data.stMinY:1:data.stMaxY;
data.zPxStVec=1:1:data.numSl;
data.xMStVec=data.xPxStVec*data.mPxXSt;
data.yMStVec=data.yPxStVec*data.mPxYSt;
data.zMStVec=data.zPxStVec*data.mPxZSt;

% normalize the data to the max of the entire stack per channel
minSt=min(min(min(min(imSt))));
maxSt=max(max(max(max(imSt))));
imSt=(imSt-minSt)./(maxSt-minSt);

% store in the data structure
data.imSt=imSt;