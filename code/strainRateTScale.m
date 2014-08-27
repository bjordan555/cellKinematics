%% Function to convert the strain rates computed from the paths into 1/s units. 
% NOTE: the strain rates interpolated from the velocities are already in
% these units. 

function data=strainRateTScale(data)

% scale all computed strain rates, canonical, and strain cross values
data.dX=data.dX/data.tStepInc;
data.dY=data.dY/data.tStepInc;
data.dXY=data.dXY/data.tStepInc;

for i1=1:1:data.numSt-1
    data.dXSVDInterp{i1}=data.dXSVDInterp{i1}/data.tStepInc;
    data.dYSVDInterp{i1}=data.dYSVDInterp{i1}/data.tStepInc;
    data.dXYSVDInterp{i1}=data.dXYSVDInterp{i1}/data.tStepInc;
end