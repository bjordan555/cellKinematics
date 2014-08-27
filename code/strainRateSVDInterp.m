function data = strainRateSVDInterp(data)

% display algorithm step entry
display('Interpolating the strain rates');

% set the interpolation method
interpMethod='natural';
% interpMethod='nearest';
% interpMethod='linear';


% loop for each path step in each time frame
for i3=1:1:data.numSt-1
    
    % create a DelaunayTri objects from the centers of each triangle, used
    % for interpolating the strain rates of each trianlge on to.
    DT=DelaunayTri(data.triSprCc{i3}');
    
    % Create the interpolant functions
    dXF{i3} = TriScatteredInterp(DT, data.dX(i3,:)',interpMethod);
    dYF{i3} = TriScatteredInterp(DT, data.dY(i3,:)',interpMethod);
    dXYF{i3} = TriScatteredInterp(DT, data.dXY(i3,:)',interpMethod);
    pSCF{i3} = TriScatteredInterp(DT, data.pSC(i3,:)',interpMethod);
    qSCF{i3} = TriScatteredInterp(DT, data.qSC(i3,:)',interpMethod);
    betaF{i3} = TriScatteredInterp(DT, data.beta(i3,:)',interpMethod);
end

% dereference the maximum and minumum path positions for plotting
pXMin=min(min(data.pSprX));
pXMax=max(max(data.pSprX));
pYMin=min(min(data.pSprY));
pYMax=max(max(data.pSprY));

% create the mesh grid for interpolated velocities
xVec=linspace(pXMin,pXMax,data.vGridDX);
yVec=linspace(pYMin,pYMax,data.vGridDX);
[xGrid yGrid]=meshgrid(xVec,yVec);

% loop for each path step in each time frame
for i3=1:1:data.numSt-1
    
    % evaluate the interpolant at the points in the grid
    dXGrid=dXF{i3}(xGrid,yGrid);
    dYGrid=dYF{i3}(xGrid,yGrid);
    dXYGrid=dXYF{i3}(xGrid,yGrid);
    pSCGrid=pSCF{i3}(xGrid,yGrid);
    qSCGrid=qSCF{i3}(xGrid,yGrid);
    betaGrid=betaF{i3}(xGrid,yGrid);
    
    %     % evaluate the interpolant at the points in the triangulation
    %     dXGrid=dXF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
    %     dYGrid=dYF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
    %     dXYGrid=dXYF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
    %     pSCGrid=pSCF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
    %     qSCGrid=qSCF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
    %     betaGrid=betaF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
    
    % assign to strain rate components
    dXSVDInterp{i3}=dXGrid;
    dYSVDInterp{i3}=dYGrid;
    dXYSVDInterp{i3}=dXYGrid;
    pSCSVDInterp{i3}=pSCGrid;
    qSCSVDInterp{i3}=qSCGrid;
    betaSVDInterp{i3}=betaGrid;
    
    %     dXSVDInterp(:,i3)=dXGrid;
    %     dYSVDInterp(:,i3)=dYGrid;
    %     dXYSVDInterp(:,i3)=dXYGrid;
    %     pSCSVDInterp(:,i3)=pSCGrid;
    %     qSCSVDInterp(:,i3)=qSCGrid;
    %     betaSVDInterp(:,i3)=betaGrid;
    
end

% store in the data structure
data.dXSVDInterp=dXSVDInterp;
data.dYSVDInterp=dYSVDInterp;
data.dXYSVDInterp=dXYSVDInterp;
data.dXF=dXF;
data.dYF=dYF;
data.dXYF=dXYF;
data.pSCSVDInterp=pSCSVDInterp;
data.qSCSVDInterp=qSCSVDInterp;
data.betaSVDInterp=betaSVDInterp;
data.pSCF=pSCF;
data.qSCF=qSCF;
data.betaF=betaF;