function data=triSVD(data)

% display algorithm step entry
display('Computing strain rates by SVD');

%% Center each starting paths triangle in each frame
for i3=1:1:data.numSt
    
    % loop over all the triangles
    for i4=1:1:data.numTri
        
        % dereference the x and y coords and make into row vectors
        triX=data.triX{i3}(:,i4)';
        triY=data.triY{i3}(:,i4)';
        
        % compute the centered coordinates (coords - mean for each axis)
        triXCent=triX-mean(triX);
        triYCent=triY-mean(triY);

        % check to be sure that coord are centered (to tolerance)
        if sum(triXCent)>1E-8 ||sum(triYCent)>1E-8
            display('PR triangle not centered properly');
        end
        
        % assemble the complete vector of centered coords of the triangles
        triCent{i3,i4}=[triXCent;triYCent];
        
    end
end

%% Center each starting path step triangle in each frame
for i3=1:1:data.numSt-1
    
    % loop over all the triangles
    for i4=1:1:data.numTri
        
        % dereference the x and y coords and make into row vectors
        triStepX=data.triStepX{i3}(:,i4)';
        triStepY=data.triStepY{i3}(:,i4)';
        
        % compute the centered coordinates (coords - mean for each axis)
        triXCentStep=triStepX-mean(triStepX);
        triYCentStep=triStepY-mean(triStepY);

        % check to be sure that coord are centered (to tolerance)
        if sum(triXCentStep)>1E-8 ||sum(triYCentStep)>1E-8
            display('Step triangle not centered properly');
        end
        
        % assemble the complete vector of centered coords of the triangles
        triCentStep{i3,i4}=[triXCentStep;triYCentStep];
        
    end
end


%% Find the transformation between centered triangles in successive frames
for i3=1:1:data.numSt-1
    
    % loop over all the triangles
    for i4=1:1:data.numTri
        
        % compute the linear transformation F between the two triangles.
        % F*A=B is the equation.  F here is the deformation rate gradinet
        % tensor. A is the PR triangulation. B is the SPR triangulation at
        % the next frame.  This is an important distinction, since the
        % window matching relates PR positions to SPR corrected positions
        % in the next frame.  Therefore, the strains that need to be
        % measured must be computed between the PR and SPR triangulations,
        % to avoid errors. 
        A=triCent{i3,i4};
        B=triCentStep{i3,i4};
        F=B/A;

        % store the resulting matrix for plotting of triangles
        triTrans{i3,i4}=F;

        % compute the strain rate tensor directly from F.
        I=[1 0; 0 1];
        epsilonDot=0.5*(transpose(F)+F)-I;
        
        % compute the strain cross parameters using SVD directly.
        % Technical note: triTrans=U*S*V' as computed by matlab's svd().  This
        % doesn't matter for the following computation, however, as we only
        % are using the (1,1) component of the calculated matricies, and
        % V(1,1)=V(1,1)'.
        % see matlab svd() docs for details
        % Note: svd() automatically computes non-negative diagonal
        % elements in decreasing order, as required in G&G paper
        [U,S,Vs] = svd(F);
        
        % compute V from V*
        V=ctranspose(Vs);
        
        % compute the components of the polar decomposition
        R=U*Vs;
        %         Fu=V*S*Vs;

        % extract the principal stretches from S
        lambda1=S(1,1);               % major axis principal stretch rate
        lambda2=S(2,2);               % minor axis principal stretch rate

        % compute the rotation and un-rotation angles theta and phi, resp.
        theta=acos(U(1,1));
        phi=acos(V(1,1));
     
        % compute the rotation angle taking the principal axis to the
        % global coordinate axis.  CHECK THIS!  
%         beta(i3,i4)=phi-theta;
        beta(i3,i4)=phi+theta;
        
        % compute the principal engineering strain rates
        DEng1=lambda1-1;
        DEng2=lambda2-1;
        
        % form the principal strain tensor
        Dm=[DEng1 0; 0 DEng2];
        
        % form the rotation matrix to take Dm to dm. This is R'
        Qm=[cos(beta(i3,i4)) -sin(beta(i3,i4)); sin(beta(i3,i4)) cos(beta(i3,i4))];
        
        % rotate the principal strains to global axis
        dm=Qm*Dm*transpose(Qm);
        
       % assign the strain rate components from the SVD
        % the shear strain is the sum of the two symmetric terms
%         dX(i3,i4)=dm(1,1);
%         dY(i3,i4)=dm(2,2);
%         dXY(i3,i4)=dm(1,2)+dm(2,1);

        % assign the strain rate components directly from F
        % the shear strain is the sum of the two symmetric terms
        dX(i3,i4)=epsilonDot(1,1);
        dY(i3,i4)=epsilonDot(2,2);
        dXY(i3,i4)=epsilonDot(1,2)+epsilonDot(2,1); 
        
        % check to be sure strain tensor is symmetric, i.e.
        % dm(1,2)=dm(2,1), to some error near machine precision
        if dm(1,2)-dm(2,1)>1E-12
            display(sprintf('global strain rate tensor not symmetric. diff=%e',dm(1,2)-dm(2,1)));
        end
        
        % compute the canonical parameters
        tC(i3,i4)=sqrt( ((F(1,1)+F(2,2))^2 + (F(1,2)-F(2,1))^2) );    % areal expansion
        wC(i3,i4)=sqrt( ((F(1,1)-F(2,2))^2 + (F(1,2)+F(2,1))^2) );    % anisotropy
        tauC(i3,i4)=atan2( (F(1,2)+F(2,1)) , (F(1,1)-F(2,2)) );        % twice mean inclination of major axis
        omegaC(i3,i4)=atan2( (F(1,2)-F(2,1)) , (F(1,1)+F(2,2)) );      % vorticity
        
%         % assign the components, derived from the SVD definition in G&G.
%         pSC(i3,i4)=(tC(i3,i4)+wC(i3,i4))/2;             % major axis principal stretch rate
%         qSC(i3,i4)=(tC(i3,i4)-wC(i3,i4))/2;               % minor axis principal stretch rate
%         thetaSC(i3,i4)=(tauC(i3,i4)-omegaC(i3,i4))/2;     % pre-rotation
%         phiSC(i3,i4)=(tauC(i3,i4)+omegaC(i3,i4))/2;       % post-rotation
%         
        % assign the components, derived from the SVD definition in G&G.
        pSC(i3,i4)=lambda1;             % major axis principal stretch rate
        qSC(i3,i4)=lambda2;               % minor axis principal stretch rate
        thetaSC(i3,i4)=theta;     % pre-rotation
        phiSC(i3,i4)=phi;       % post-rotation
        
    end
end

% %% Plot the triangles and the transformed triangles for each frame
% 
% h=figure(1);
% set(h,'units','normalized','Position',[0.03 0.03 0.48 0.97]);
% clf;
% % loop over all the triangles
% for i4=1:1:data.numTri
%     
%     for i3=1:1:data.numSt-1
%        
%         % defererence the coords of the triangle in the current frame. This
%         % is the PR triangulation
%         tXC=triCent{i3,i4}(1,:);
%         tYC=triCent{i3,i4}(2,:);
%         
%         % dereference the transformation taking the PR triangle to the SPR
%         % triangle
%         F=triTrans{i3,i4};
%                 
%         % dereference the coordinates of the next triangle
%         tXCNext=triCentStep{i3+1,i4}(1,:);
%         tYCNext=triCentStep{i3+1,i4}(2,:);
%                        
%         % transform the triangle from the current to next frame using the
%         % linear transformation calculated.
%         tTNext=F*[tXC;tYC];
%         
%         % compute a per frame error measure in triangle transformation
%         triErr(i3)=sum(sqrt((tXCNext-tTNext(1,:)).^2+(tYCNext-tTNext(2,:)).^2));
%                 
%         %% plot the triangles in the current and next frame, comparing the 
%         %% PR and SPR triangles and the transformation between them. 
%         subplot(1,2,1)
%         cla;
%         hold on
%         % plot the triangle in the current frame in green
%         patch(tXC,tYC,dX(i3,i4),'EdgeColor','g','FaceColor','none','LineWidth',3);
%         % plot the actual triangle in the next frame
%         patch(tXCNext,tYCNext,dX(i3,i4),'EdgeColor','r','FaceColor','none','LineWidth',3);
%         % plot the transformed triangle from the previous frame
%         patch(tTNext(1,:),tTNext(2,:),dX(i3,i4),'EdgeColor','b','FaceColor','none','LineWidth',1);
%         % plot the origin
%         plot(0,0,'*r');
%         title(sprintf('Path (red) and transformed (blue) triangle # %i',i4));
%         axis equal
%         axis tight
%         hold off;
%          
%     end
%     
% 
%     
%     % plot the error in the trangulation per frame
%     subplot(1,2,2)
%     hold on
%     plot(i4*ones(data.numSt-1),triErr,'.k');
%     title('Sum of triangulation per-node distance error');
%     
%     drawnow;
%     %     pause(0.1)
%     
% end

%% assign to the data struct
data.dX=dX;
data.dY=dY;
data.dXY=dXY;
data.beta=beta;
data.tC=tC;
data.wC=wC;
data.tauC=tauC;
data.omegaC=omegaC;
data.pSC=pSC;
data.qSC=qSC;
data.thetaSC=thetaSC;
data.phiSC=phiSC;

