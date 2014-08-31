%% compute image feature window around a coordinate
function imWin=getImageWindow(pathDataIn,pX,pY,imCur)

% dereference variables used from data structure
winVec=pathDataIn.winVec;

% set the window boundaries
xWinMin=pX+min(winVec);
xWinMax=pX+max(winVec);
yWinMin=pY+min(winVec);
yWinMax=pY+max(winVec);

% vector of window pixel coordinates
winXVec=xWinMin:1:xWinMax;
winYVec=yWinMin:1:yWinMax;

% get the image in the window.
imWin=imCur(winYVec,winXVec);
% return the window and its bound