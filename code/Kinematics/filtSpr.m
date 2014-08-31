function data=filtSpr(data)

% display algorithm step entry
display('Filtering out incomplete SPR paths after refinement');

% number of paths before filtering of SPR 
preFiltCnt=length(data.pSprX);

%% Remove the rows from pSprX, pSprY, vSprX, vSprY that have NaN's / -Infs in them
data.pSprX(any(data.filtSpr==1,2),:)=[];
data.pSprY(any(data.filtSpr==1,2),:)=[];
data.vSprX(any(data.filtSpr==1,2),:)=[];
data.vSprY(any(data.filtSpr==1,2),:)=[];
data.stepSprX(any(data.filtSpr==1,2),:)=[];
data.stepSprY(any(data.filtSpr==1,2),:)=[];
data.stepSprXCorr(any(data.filtSpr==1,2),:)=[];
data.stepSprYCorr(any(data.filtSpr==1,2),:)=[];
data.pX(any(data.filtSpr==1,2),:)=[];
data.pY(any(data.filtSpr==1,2),:)=[];
data.vX(any(data.filtSpr==1,2),:)=[];
data.vY(any(data.filtSpr==1,2),:)=[];
data.stepX(any(data.filtSpr==1,2),:)=[];
data.stepY(any(data.filtSpr==1,2),:)=[];
data.minSSD(any(data.filtSpr==1,2),:)=[];
data.minRsq(any(data.filtSpr==1,2),:)=[];
data.sprRsqX(any(data.filtSpr==1,2),:)=[];
data.sprSseX(any(data.filtSpr==1,2),:)=[];
data.sprRmseX(any(data.filtSpr==1,2),:)=[];
data.sprRsqY(any(data.filtSpr==1,2),:)=[];
data.sprSseY(any(data.filtSpr==1,2),:)=[];
data.sprRmseY(any(data.filtSpr==1,2),:)=[];

% number of paths after SPR filtering
postFiltCnt=length(data.pSprX);
cntSprFilt=preFiltCnt-postFiltCnt;

% update the number of paths
numPaths=size(data.pSprX,1);

%% output the path filtering stats
display(sprintf('%i path steps filtered. %i Remaining frames.  %i complete paths.',cntSprFilt,data.numSt,numPaths));

%% assign to data structure
data.numPaths=numPaths;