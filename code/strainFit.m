function data = strainFit(data)

% display algorithm step entry
display('Computing strains and strain rates');

%% Compute strain rates by interpolating the velocity field and derivating

% interpolate the velocity field directly from the triangulation
data=interpDVel(data);

% plot the interpolated velocities
plotVelInterp(data);

% Compute the strain rates from the interpolated velocities
data=strainRateInterp(data);

% plot the interpolated strain rates
plotStrainRateInterp(data);
 
% plot the local averages of strain measures using neareast neighbors to a triangle 
plotStrainInterpLocal(data);

%% Compute the strain rates by find the linear transformation between triangles
% Compute strain rates by SVD for each triangle from paths
data=triSVD(data);

% filter out elements whose verticies cross restricted boundaries
data=filtTri(data);

% plot the triangulation quality
plotTriQual(data);

% interpolate the strain rate field from the SVD strain rates
data=strainRateSVDInterp(data);

% Convert the strain rates to 1/s units
data=strainRateTScale(data);

% Histogram of the strain rates
% plotStrainRateHisto(data);

% plot the triangulation colored by strain rate
plotStrainRateSurf(data);

% plot the strain cross measures in the triangulation
plotStrainRateCross(data);

% plot the average of strain rates taken at each triangulation with no interpolation 
plotStrainLocal(data);

% plot the interpolated strain rates
plotStrainRateSVDInterp(data);

% % plot the local averages of strain measures using neareast neighbors to a triangle 
plotStrainSVDInterpLocal(data);

% plot the strain cross measures interpolated on the nodes triangulation
% plotStrainRateCrossSVD(data);
