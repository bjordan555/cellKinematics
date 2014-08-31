%% imPp2.m

%% Cell Geometry and Kinematics Measurement

%% Ben M. Jordan, 2013

%% To Do
% Fit cylinder to radius surfaces instead of circles
%
% Improve boundary detection algorithm, currently using bwtraceboundary,
% which ins't as accurate as gradient methods
%
% Add in axial radius and length measurement
%
% Add user input initial velocity from image series. Draw some paths...
% 
% Add ROI selector.  
%
% Unify all figures, set size once, generate images and movies for all
% plots that need to be used after run.
%
% Check for long axis curvature by examing radial generator.  Is the
% curvature in this axis significant.  Fit an exponential, circle,
% hyperbolic, etc. to it. 
%
% Check for rotation of cell w.r.t. coordinate axis.  If there is a
% rotation, the velocities should be rotated to remove this effect.
%
% Add code to sca-data.restBdryXWidthn over a range of window sizes in a subset of the paths
% and determine the optimum. 
%
% Update triSVD to use simplicies with >3 verticies, resulting in a
% least-squares regression fitting of deformation, which will average out
% the spatial inhomogeneity.
%
% Add code to automatically load images from specified directories, and
% determine the size and number of frames and slices.  Do this for both
% MIP and stack.  Also read XML metadata to get other params?
%
% Automatically compute the optimal window edge length by computing the
% size of the window s.t. the average # of features in the window is around
% 12.  Why 12? Because that's what Miguel said worked? Empirically, this
% seems to be true, but why?!
%
% Fix pNFilt fitlering in plotStrainLocal.m
%

%% INIT
clear all;
close all;

%% log output to display
display(sprintf('Cell Geometry and Kinematics Measurement'));

%% timer for reporting computation time
timeStart=tic;

%% Load the data set by selecting a directory with a valid dataPars.m
% load the parameters
data.codeDir=cd;
[data.ParsFile,data.imDirPp,idx] = uigetfile('./','Select dataPars.m for the dataset to be analyzed.');
cd(data.imDirPp);
data=dataPars(data);
cd(data.codeDir);

%% Run analysis for geometry
data.loadSt=input('Load the stack for geometry measurement? y/n [y]: ', 's');
if strcmp(data.loadSt,'y')
    
    %% Load and preprocess the stack
    data=loadSt(data);
    
    %% Visualize the Stack
    data=visImSt(data);
    
    %% Measure the inside and outside radius of the cell using YZ slices (lateral slices)
    data=getLatRadSt(data);
   
    %% Clear the stack images to reduce file amd memory size
    data.imSt=[];
end

%% Run analysis for PV
data.loadMIP=input('Load the MIP for kinematics? y/n [y]: ', 's');
if strcmp(data.loadMIP,'y')
    
    %% Load and preprocess the MIP
    data=loadMIP(data);
    
    %% Visualize the MIP and estimate initial velocity
    data=visImMIP(data);
    
    %% PV: Compute the displacements and velocities by searching around each window
    data=pathAnsysWin(data);
    
    %% Kinematics: Compute the strain rates from the PV data
    data= strainFit(data);
    
    %% Clear the MIP images to reduce file memory size
    data.imMIP=[];
    
end

%% Timer for reporting computation time
timeEnd=toc(timeStart);
display(sprintf('Completed in %f seconds',timeEnd));

% Save for future analysis
save('./output/finalWorkspace.mat','-v7.3');
