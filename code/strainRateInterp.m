function data = strainRateInterp(data)

% display algorithm step entry
display('Computing strain rates from interpolated velocities');

% dereference the maximum and minumum path positions
pXMin=min(min(data.pSprX));
pXMax=max(max(data.pSprX));
pYMin=min(min(data.pSprY));
pYMax=max(max(data.pSprY));

% compute the distance in microns between grid points
deltaPX=(pXMax-pXMin)./data.vGridDX;
deltaPY=(pYMax-pYMin)./data.vGridDX;

% create the mesh grid for interpolated velocities.  A regular grid is used
% here for ease of computing the step size for the gradient computation.
% Alternately, the distance between points in the triangulation must be
% computed for each evaluation point, and this is not currently
% implemented. The resulting interpolated velocity field on the regular
% grid may disproportionately weight larger triangles, due to the regular
% spacing.  For a good triangulation of homogeneous element size, this
% effect is minimized. 
xVec=linspace(pXMin,pXMax,data.vGridDX);
yVec=linspace(pYMin,pYMax,data.vGridDX);
[xGrid yGrid]=meshgrid(xVec,yVec);

% loop for each path step in each time frame
for i3=1:1:data.numSt
    
    % evaluate the interpolant at the points in the grid
    vXGrid=data.vXF{i3}(xGrid,yGrid);
    vYGrid=data.vYF{i3}(xGrid,yGrid);
    
    % compute the gradients for the interpolated velocities
    [vXX vXY]=gradient(vXGrid,deltaPX);
    [vYX vYY]=gradient(vYGrid,deltaPY);
    
    % assign to strain rate components
    dXInterp{i3}=vXX;
    dYInterp{i3}=vYY;
    dXYInterp{i3}=vYX-vXY;
    
end

% store in the data structure
data.dXInterp=dXInterp;
data.dYInterp=dYInterp;
data.dXYInterp=dXYInterp;