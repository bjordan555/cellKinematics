%% function to compute the paths of beads
function data = pathAnsysWin(data)

% display algorithm step entry
display('Analyzing paths');

% %% Gamma correction for PIV feature identification
data=gammaMIP(data);

%% Find the features in first frame
data=findPIVFeat(data);

%% Use either the detected features or a regular grid for evaluation
if data.evalGridON==0
    % Using the features in the first frame as the evaluation points, triangulate the
    % points, and remove edges less than some threshold to avoid heavily overlapped
    % evaluation regions where points are very close to each other
    data=useFeatPIV(data);
else
    % Create a regular grid fo evaluation points
    data=gridFeatPIV(data);
end

%% Find the paths for each centroid in the first time frame, fitting forward in time with the window SSD
data=getAllPaths(data);

%% filter PR paths to only complete paths
data=filtPr(data);

%% Plot PR paths by centroid or time step
plotPaths(data);

%% refine each path coordinate to subpixel resolution by finding best-fit normal distribution to the ssd data
data=refineSpr(data);

%% filter SPR paths to only complete paths
data=filtSpr(data);

%% Plot SPR paths by centroid or time step
plotPathsSpr(data);

% %% Convert the paths into the length and time scales of the experiment
data=pathVelScale(data);

%% plot the displacement and velocity space by time frame
plotDispVelSpace(data);

%% compute triangulation for each path step in each time frame
data=makePathTri(data);

%% plot the triangulated velocities
plotVelTri(data);