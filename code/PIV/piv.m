% Example script how to use PIVlab from the commandline
% You can adjust the settings in "s" and "p", specify a mask and a region of interest
clear all
close all

%% add the PIVLab to the path
addpath('./PIVlab_1.32/');

%% Standard PIV Settings
s = cell(10,2);    % Create a "settings table"
%Parameter                       %Setting           %Options
s{1,1}= 'Int. area 1';           s{1,2}=128;         % window size of first pass
s{2,1}= 'Step size 1';           s{2,2}=64;         % step of first pass
s{3,1}= 'Subpix. finder';        s{3,2}=1;          % 1 = 3point Gauss, 2 = 2D Gauss
s{4,1}= 'Mask';                  s{4,2}=[];         % If needed, generate via: imagesc(image); [temp,Mask{1,1},Mask{1,2}]=roipoly;
s{5,1}= 'ROI';                   s{5,2}=[];         % Region of interest: [x,y,width,height] in pixels, may be left empty
s{6,1}= 'Nr. of passes';         s{6,2}=2;          % 1-4 nr. of passes
s{7,1}= 'Int. area 2';           s{7,2}=64;         % second pass window size
s{8,1}= 'Int. area 3';           s{8,2}=16;         % third pass window size
s{9,1}= 'Int. area 4';           s{9,2}=16;         % fourth pass window size
s{10,1}='Window deformation';    s{10,2}='*spline'; % '*spline' is more accurate, but slower

%% Standard image preprocessing settings
p = cell(8,1); % create another table of settings
%Parameter                       %Setting           %Options
p{1,1}= 'ROI';                   p{1,2}=s{5,2};     % same as in PIV settings
p{2,1}= 'CLAHE';                 p{2,2}=1;          % 1 = enable CLAHE (contrast enhancement), 0 = disable
p{3,1}= 'CLAHE size';            p{3,2}=20;         % CLAHE window size
p{4,1}= 'Highpass';              p{4,2}=0;          % 1 = enable highpass, 0 = disable
p{5,1}= 'Highpass size';         p{5,2}=15;         % highpass size
p{6,1}= 'Clipping';              p{6,2}=0;          % 1 = enable clipping, 0 = disable
p{7,1}= 'Clipping thresh.';      p{7,2}=0;          % 0-255 clipping threshold
p{8,1}= 'Intensity Capping';     p{8,2}=0;          % 1 = enable intensity capping, 0 = disable

%% Create list of images inside specified directory
% uncomment these for directory full of individual image files
% imPathName=uigetdir; %directory containing the images you want to analyze
% suffix='*.tif'; %*.bmp or *.tif or *.jpg
% direc = dir([imPathName,filesep,suffix]); filenames={};
% [filenames{1:length(direc),1}] = deal(direc.name);
% filenames = sortrows(filenames); %sort all image files
% frTot = length(filenames);

% uncomment this for a single tiff stack file 
[imFileName, imPathName]=uigetfile('*.tif','Select the image MIP TIFF file');; % select the tiff stack of the XYMIPZCT 
info=imfinfo(sprintf('%s%s',imPathName,imFileName));
display(sprintf('Total images in MIP: %i',length(info)));

% print the hyperstack details from the first image 
display(sprintf('MIP image info: \n%s',info(1).ImageDescription));

% get time, slice, and channel information from user
frTot=input('How many total frames are available ? ');
fr0=input('What number is the first frame to be used in analysis? ');
frFin=input('What number is the final frame to be used in analysis? ');
chTot=input('How many channels are available? ');
chPV=input('Which channel to use for kinematics measurement? ');

% Compute / input the total number of frames, slices, channels
numFr=frFin-fr0+1;
display(sprintf('Total frames used: %i',numFr));

% get the total number of resulting time points
tAnsys=input('How many total time points to analyze at (Rounded to regular increment)? ');
frInc=floor(numFr/tAnsys);

%% check if out directory exists and if not, make it, if so clear the existing files out
if ~exist(sprintf('%s/%s',imPathName,'out'),'dir')
    mkdir(sprintf('%s/%s',imPathName,'out'));
else
    delete(sprintf('%s/%s/*.*',imPathName,'out'));
end

% setup video output
vidObj=VideoWriter(sprintf('%s/%s/%s',imPathName,'out',sprintf('outCh%i.avi',chPV)));
open(vidObj);

% set the reference image for each step to be the frame at t=0
% image1 = imread(fullfile(imPathName, filenames{1})); % read images
image1=imread(sprintf('%s/%s',imPathName,imFileName),'Index',chPV);
image1 = PIVlab_preproc(image1,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2}); %preprocess images

% create a figure for display
h=figure(1);
figSize=size(image1);
figRect=[1 1 figSize(2) figSize(1)];
set(h,'OuterPosition',figRect);

% get reference image frame size for video output
prevFrame = getframe;
frameSize = size(prevFrame.cdata);
frameHeight=frameSize(1);
frameWidth=frameSize(2);
offsetWidth=200;
offsetHeight=50;
frameRect=[1+offsetWidth 1+offsetHeight frameWidth+offsetWidth frameHeight+offsetHeight];

%% PIV analysis loop
% init counter
cnt=chPV;

% iterate
for i=1:frTot-1
    
    % increment counter
    cnt=cnt+chTot*frInc;
    
    %     image2=imread(fullfile(imPathName, filenames{i+1}));
    image2=imread(sprintf('%s/%s',imPathName,imFileName),'Index',cnt);
    image2 = PIVlab_preproc (image2,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2});
    [x,y,u1(:,:,i),u2(:,:,i),typevector] = piv_FFTmulti (image1,image2,s{1,2},s{2,2},s{3,2},s{4,2},s{5,2},s{6,2},s{7,2},s{8,2},s{9,2},s{10,2});
    clc
    disp([int2str(i/frTot*100) ' %']);
    
    % Graphical output (disable to improve speed)
    imagesc(double(image1)+double(image2));colormap('gray');
    hold on

    % filter out vector coordinates whose vectors result in negative
    % overall coodrinates, avoiding moving frame in movies
    
%     quiver(x,y,u1,u2,'g','AutoScaleFactor', 1.5);
    quiver(x,y,u1(:,:,i),u2(:,:,i),0,'Color','g','AutoScale','off');
    hold off;
    axis image;
    title(sprintf('frame:%i',i),'interpreter','none')
    set(gca,'xtick',[],'ytick',[])
    set(gca,'XLim',[1 figSize(2)]);
    set(gca,'YLim',[1 figSize(1)]);
    
    drawnow;
        
    % Write each frame to the file.
    currFrame = getframe(h,frameRect);
    writeVideo(vidObj,currFrame);
    

    %% Output to out directory in images directory
    % construct an array of the x,y positions and the displacement values.
    %     wholeLOT=[reshape(x,size(x,1)*size(x,2),1) reshape(y,size(y,1)*size(y,2),1) reshape(u1(:,:,i),size(u1(:,:,i),1)*size(u1(:,:,i),2),1) reshape(u2(:,:,i),size(u2(:,:,i),1)*size(u2(:,:,i),2),1)];
    % write the file
    %   dlmwrite(sprintf('%s/%s/%s',imPathName,'out',strcat('PIV-',num2str(i),'.txt')), wholeLOT, '-append', 'delimiter', '\t', 'precision', 10, 'newline', 'pc');
    
end
% Close the video object file.
close(vidObj);

% compute the velocities between frames
v1=diff(u1,1,3);
v2=diff(u2,1,3);
