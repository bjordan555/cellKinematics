%% Plotting routine for saved workspaces

%% Initialize
clear all
close all

%% Load a saved workspace and dereference the data struct

%% Elasticity CMLE 1040x1263x22
% load '/home/benjordan/Documents/completeWorkspaces/elasticityFINAL.mat';
% data=data{18};

% % linearVx512x512
% load '/home/benjordan/Documents/completeWorkspaces/linearVxFINAL.mat';
% data=data{20};     

% Growth Orig 1040x1263x126
load '/home/benjordan/Documents/completeWorkspaces/growthFINAL.mat';
data=data{24};

% Only look at 1 data set at a time
i1=1;

%% Plot paths by centroid or time step
plotPaths(data,i1);

%% plot the displacement and velocity space by time frame
plotDispSpace(data,i1);

%% plot the triangulations for each path step in each time frame
plotTri(data);

%% compute the spatial averages of the strains and strain rates, after filtering by std. dev. 
data=avgStrains(data);

%% plot the strain cross measures on the triangulation
plotStrainCross(data);

%% plot the strain cross measures on the triangulation
plotNN(data);
