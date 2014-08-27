%% Function to convert from pixels to meters

function data=pathVelScale(data)

%% convert the paths and velocities in pixels to meters
data.pSprX=data.pSprX*data.mPxXMIP;
data.pSprY=data.pSprY*data.mPxYMIP;
data.vSprX=data.vSprX*data.mPxXMIP;
data.vSprY=data.vSprY*data.mPxYMIP;
data.pX=data.pX*data.mPxXMIP;
data.pY=data.pY*data.mPxYMIP;
data.vX=data.vX*data.mPxXMIP;
data.vY=data.vY*data.mPxYMIP;
data.stepX=data.stepX*data.mPxXMIP;
data.stepY=data.stepY*data.mPxYMIP;
data.stepSprX=data.stepSprX*data.mPxXMIP;
data.stepSprY=data.stepSprY*data.mPxYMIP;

%% convert the velocities into time scale from frames
data.vSprX=data.vSprX/data.tStepInc;
data.vSprY=data.vSprY/data.tStepInc;
data.vX=data.vX/data.tStepInc;
data.vY=data.vY/data.tStepInc;
