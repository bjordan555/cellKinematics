function data = makePathTri(data)

% display algorithm step entry
display('Triangulating path steps');

%% make the triangulation from the triangulation of the complete paths
for i3=1:1:data.numSt

    % create triangulation for first path step
    if i3==1
        
        % make the triangulation from the initial PR and SPR path positions
        pathDT=delaunay(data.pX(:,i3),data.pY(:,i3));
        pathSprDT=delaunay(data.pSprX(:,i3),data.pSprY(:,i3));
    end
    
    % create a triRep object that conserves the connectivity for all frames
    pathTriRep{i3} = TriRep(pathDT, [data.pX(:,i3),data.pY(:,i3)]);
    pathTriRepSpr{i3}= TriRep(pathSprDT, [data.pSprX(:,i3),data.pSprY(:,i3)]);
    
    % create a triRep object whose nodes are displaced by the SPR step
    if i3~=data.numSt
        pathTriRepStep{i3}= TriRep(pathDT, [data.pX(:,i3)+data.stepSprX(:,i3+1),...
            data.pY(:,i3)+data.stepSprY(:,i3+1)]);
    end
    
end

% create a variable for the number of triangles, which is the same for both
% triangulations
numTri=size(pathTriRep{i3},1);

%% compute the centers and mesh quality statistics for the paths
for i3=1:1:data.numSt
    
    % compute the circumcenters and the radii of each triangle
    [cc rcc]=circumcenters(pathTriRep{i3},[1:numTri]');
    [ccSpr rccSpr]=circumcenters(pathTriRepSpr{i3},[1:numTri]');
    
    % loop over all triangles
    for i4=1:1:numTri
        
        % dereference the coordinates of the nodes of each PR triangle
        triPX1=pathTriRep{i3}.X(pathTriRep{i3}.Triangulation(i4,1),1);
        triPY1=pathTriRep{i3}.X(pathTriRep{i3}.Triangulation(i4,1),2);
        triPX2=pathTriRep{i3}.X(pathTriRep{i3}.Triangulation(i4,2),1);
        triPY2=pathTriRep{i3}.X(pathTriRep{i3}.Triangulation(i4,2),2);
        triPX3=pathTriRep{i3}.X(pathTriRep{i3}.Triangulation(i4,3),1);
        triPY3=pathTriRep{i3}.X(pathTriRep{i3}.Triangulation(i4,3),2);
        
        % dereference the coordinates of the nodes of each SPR triangle
        triSprPX1=pathTriRepSpr{i3}.X(pathTriRepSpr{i3}.Triangulation(i4,1),1);
        triSprPY1=pathTriRepSpr{i3}.X(pathTriRepSpr{i3}.Triangulation(i4,1),2);
        triSprPX2=pathTriRepSpr{i3}.X(pathTriRepSpr{i3}.Triangulation(i4,2),1);
        triSprPY2=pathTriRepSpr{i3}.X(pathTriRepSpr{i3}.Triangulation(i4,2),2);
        triSprPX3=pathTriRepSpr{i3}.X(pathTriRepSpr{i3}.Triangulation(i4,3),1);
        triSprPY3=pathTriRepSpr{i3}.X(pathTriRepSpr{i3}.Triangulation(i4,3),2);
        
        % store the x and y coords of each triangle as a vector
        triX{i3}(:,i4)=[triPX1;triPX2;triPX3];
        triY{i3}(:,i4)=[triPY1;triPY2;triPY3];
        triSprX{i3}(:,i4)=[triSprPX1;triSprPX2;triSprPX3];
        triSprY{i3}(:,i4)=[triSprPY1;triSprPY2;triSprPY3];
        
        % compute the mean coordinates of each triangle 
        mcX=mean(triX{i3}(:,i4));
        mcY=mean(triY{i3}(:,i4));
        mcSprX=mean(triSprX{i3}(:,i4));
        mcSprY=mean(triSprY{i3}(:,i4));
        
        % store the mean coordinates of each triangle
        triCc{i3}(:,i4)=[mcX;mcY];
        triSprCc{i3}(:,i4)=[mcSprX;mcSprY];
        
        % determine the side lengths of each triangle
        l1=sqrt((triPX1-triPX2)^2+(triPY1-triPY2)^2);
        l2=sqrt((triPX2-triPX3)^2+(triPY2-triPY3)^2);
        l3=sqrt((triPX3-triPX1)^2+(triPY3-triPY1)^2);
        lSpr1=sqrt((triSprPX1-triSprPX2)^2+(triSprPY1-triSprPY2)^2);
        lSpr2=sqrt((triSprPX2-triSprPX3)^2+(triSprPY2-triSprPY3)^2);
        lSpr3=sqrt((triSprPX3-triSprPX1)^2+(triSprPY3-triSprPY1)^2);
        
        % determine the angles apposite of each associated length
        alpha1=acos((l2^2+l3^2-l1^2)/(2*l2*l3));
        alpha2=acos((l1^2+l3^2-l2^2)/(2*l1*l3));
        alpha3=acos((l1^2+l2^2-l3^2)/(2*l1*l2));
        alphaSpr1=acos((lSpr2^2+lSpr3^2-lSpr1^2)/(2*lSpr2*lSpr3));
        alphaSpr2=acos((lSpr1^2+lSpr3^2-lSpr2^2)/(2*lSpr1*lSpr3));
        alphaSpr3=acos((lSpr1^2+lSpr2^2-lSpr3^2)/(2*lSpr1*lSpr2));
        
        % determine the area of each triangle
        aT(i3,i4)=0.5*l1*l2*sin(alpha3);
        aTSpr(i3,i4)=0.5*lSpr1*lSpr2*sin(alphaSpr3);
        
        % determine the radius and area of the equilateral triangle of the
        % circumcircle
        rC=rcc(i4);
        aC=pi*rC^2;
        rSprC=rccSpr(i4);
        aSprC=pi*rSprC^2;
        
        % determine skewness ratio
        skewTri(i3,i4)=(aC-aT(i3,i4))/aC;
        skewTriSpr(i3,i4)=(aSprC-aTSpr(i3,i4))/aSprC;
        
        % determine the circumradius to shortest edge ratio (Ruppert's algorithm condition)
        raQual(i3,i4)=rC/min([l1 l2 l3]);
        raQualSpr(i3,i4)=rSprC/min([lSpr1 lSpr2 lSpr3]);
        
    end
end

%% compute the centers and mesh quality statistics for the path steps
for i3=1:1:data.numSt-1
    
    % compute the circumcenters and the radii of each triangle
    [ccStep rccStep]=circumcenters(pathTriRepStep{i3},[1:numTri]');
    
    % loop over all triangles
    for i4=1:1:numTri
        
       
        % dereference the coordinates of the nodes of each SPR triangle
        triStepPX1=pathTriRepStep{i3}.X(pathTriRepStep{i3}.Triangulation(i4,1),1);
        triStepPY1=pathTriRepStep{i3}.X(pathTriRepStep{i3}.Triangulation(i4,1),2);
        triStepPX2=pathTriRepStep{i3}.X(pathTriRepStep{i3}.Triangulation(i4,2),1);
        triStepPY2=pathTriRepStep{i3}.X(pathTriRepStep{i3}.Triangulation(i4,2),2);
        triStepPX3=pathTriRepStep{i3}.X(pathTriRepStep{i3}.Triangulation(i4,3),1);
        triStepPY3=pathTriRepStep{i3}.X(pathTriRepStep{i3}.Triangulation(i4,3),2);
        
        % store the x and y coords of each triangle as a vector
        triStepX{i3}(:,i4)=[triStepPX1;triStepPX2;triStepPX3];
        triStepY{i3}(:,i4)=[triStepPY1;triStepPY2;triStepPY3];
        
        % compute the mean coordinates of each triangle 
        mcStepX=mean(triStepX{i3}(:,i4));
        mcStepY=mean(triStepY{i3}(:,i4));
        
        % store the mean coordinates of each triangle
        triStepCc{i3}(:,i4)=[mcStepX;mcStepY];
        
        % determine the side lengths of each triangle
        lStep1=sqrt((triStepPX1-triStepPX2)^2+(triStepPY1-triStepPY2)^2);
        lStep2=sqrt((triStepPX2-triStepPX3)^2+(triStepPY2-triStepPY3)^2);
        lStep3=sqrt((triStepPX3-triStepPX1)^2+(triStepPY3-triStepPY1)^2);
        
        % determine the angles apposite of each associated length
        alphaStep1=acos((lStep2^2+lStep3^2-lStep1^2)/(2*lStep2*lStep3));
        alphaStep2=acos((lStep1^2+lStep3^2-lStep2^2)/(2*lStep1*lStep3));
        alphaStep3=acos((lStep1^2+lStep2^2-lStep3^2)/(2*lStep1*lStep2));
        
        % determine the area of each triangle
        aTStep(i3,i4)=0.5*lStep1*lStep2*sin(alphaStep3);
        
        % determine the radius and area of the equilateral triangle of the
        % circumcircle
        rStepC=rccStep(i4);
        aStepC=pi*rStepC^2;
        
        % determine skewness ratio
        skewTriStep(i3,i4)=(aStepC-aTStep(i3,i4))/aStepC;
        
        % determine the circumradius to shortest edge ratio (Ruppert's algorithm condition)
        raQualStep(i3,i4)=rStepC/min([lStep1 lStep2 lStep3]);
        
    end
end

%% assign to data struct
data.pathTriRep=pathTriRep;
data.pathTriRepSpr=pathTriRepSpr;
data.pathTriRepStep=pathTriRepStep;

data.triX=triX;
data.triY=triY;
data.triCc=triCc;
data.aT=aT;
data.skewTri=skewTri;
data.raQual=raQual;

data.triSprX=triSprX;
data.triSprY=triSprY;
data.triSprCc=triSprCc;
data.aTSpr=aTSpr;
data.skewTriSpr=skewTriSpr;
data.raQualSpr=raQualSpr;

data.triStepX=triStepX;
data.triStepY=triStepY;
data.triStepCc=triStepCc;
data.aTStep=aTStep;
data.skewTriStep=skewTriStep;
data.raQualStep=raQualStep;

data.numTri=numTri;