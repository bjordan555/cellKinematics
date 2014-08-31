%% Find the inside and outside radius using YZ-slice for all X-positions
function data=getLatRadSt(data)

%% Params (move to dataPars)

% number of boundaries to detect.  Currently only works with 2
numBdrs=2;

% progress bar
% progressbar('% Lateral radius measurement complete');

% prepare figure
h=figure(1);
clf;
set(h,'Units','normalized','outerposition',data.guiSize);

% wait button
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Wait...','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imWait);

% create the avi file
mov=avifile('./output/getLadRadSt.avi','compression','none','fps',10,'quality',100);


% loop over all times
for i1=1:1:data.numSt
    % loop over all x positions
    for i2=1:1:data.stXLen
        
        %% Load image data for slice
        
        % dereference the image
        imYZ=reshape(data.imSt(i1,:,:,i2),data.numSl,data.stYLen);
        
        % subtract the user specified background
        imYZ=imYZ-data.bgSt;
        
        % subtract the min and normalize the image to [0,1]
        maxIm=max(max(imYZ));
        minIm=min(min(imYZ));
        imYZ=(imYZ-minIm)./(maxIm-minIm);
        
        % compute the mean of each slice and use it as the paramter in the
        % threshold function for converting to bw.  This threshold function
        % scales the width of the wall, and should be calibrated with
        % another measurement of wall thickness.
        muSl=mean(mean(imYZ));
        
        % convert the image to b&w
%         imBw=im2bw(imYZ,0.2);
        imBw=im2bw(imYZ,muSl);
        
        % use filling algorithm to fill in wall
        imBwFill = imfill(imBw,'holes');
        
        % plot the image bkgd subtracted and normalized image
        
        if mod(i2,30)==0    % only plot every so often
            figure(1)
            subplot(1,2,1)
            cla;
            hold on;
            set(gca,'YDir','normal');
            title(sprintf('Boundary detection at frame=%i, slice=%i',i1,i2));
            imagesc(data.yMStVec,data.zMStVec,imYZ);
            colormap(gray);
            axis equal
            axis tight
            
            % plot the BW image in a separate subfigure
            subplot(1,2,2)
            cla;
            hold on;
            set(gca,'YDir','normal');
            title(sprintf('Boundary detection at frame=%i, slice=%i',i1,i2));
            % plot the image bkgd subtracted and normalized image
            imagesc(data.yMStVec,data.zMStVec,imBw);
            colormap(gray);
            axis equal
            axis tight
        end
        
        % Set the starting position for detection
        dim = size(imBw);
        % use the center column
        col = round(dim(2)/2);
        % use the row containing the maximum value in the center column
        row = max(find(imBw(:,col)));
        
        % check for empty bw image, and skip remaining steps if empty
        if isempty(row) ||isempty(col)
            % set bdry to be empty, which triggers skipping below
            bdry=[];
        else
            % find the boundary, looking South='S' first
            bdry = bwtraceboundary(imBw,[row, col],'S',8);
        end
        %         % check the size of the detected boundary and only continue if it
        %         % is larger than at least the width of the image
        %         while size(bdry,1)<data.stYLen || row < size(imBw,1) || col < size(imBw,2)
        %             % display when this is used
        %             display('Perturbing boundary search starting value');
        %
        %             % detected boundary not correct, problem with bwtraceboundary
        %             % above. perturb row and column and recheck
        %             row=row+1;
        %             col=col+1;
        %
        %             % find the boundary, looking South='S' first
        %             bdry = bwtraceboundary(imBw,[row, col],'S');
        %         end
        
        %% check to see that bdry is not empty or too small, and skip remaining steps if so
        if isempty(bdry) || size(bdry,1)<2*data.stYLen
            % display the warning
            display('Incomplete boundary detection. frame-slice unused. ');
            
            % Set the radius and wall thickness to NaN to avoid use in
            % statistics computation
            for i3=1:1:numBdrs
                
                % set the radius to NaN
                rad(i1,i2,i3)=NaN;
                
                % set centers to zero
                center(i1,i2,i3,:)=[NaN NaN];
            end
            
            % Pause the process iterations, allowing inspection of plot
            %             pause(0.25);
            
        else
            
            % assign the boundary vectors
            bdryY=bdry(:,2);
            bdryZ=bdry(:,1);
            
            % Refine the boundaries for concave up facing membranes
            cnt=0;
            
            % initialize the boundary vectors
            clear bdryRY bdryRZ;
            
            for i3=2:1:length(bdryY)
                
                % only take changed successive y-values
                if bdryY(i3)~=bdryY(i3-1)
                    cnt=cnt+1;
                    bdryRY(cnt)=bdryY(i3);
                    bdryRZ(cnt)=bdryZ(i3);
                end
            end
            
            
            % separate the layers of refined boundaries for concave up facing membranes
            bdryLvl=zeros(size(bdryRY));
            
            % determine how many points are above or below each point
            for i3=1:1:length(bdryRY)
                
                % find all the y-coord indicies matching this one
                idx=find(bdryRY==bdryRY(i3));
                
                % get the z-coord values matching the indicies
                zVal=bdryRZ(idx);
                
                % determine which layer the point is in, counting up from 1 from bottom of image
                % Currently only searches for 2 layers
                if bdryRZ(i3) >= max(zVal)
                    bdryLvl(i3)=2;
                elseif bdryRZ(i3) <= min(zVal)
                    bdryLvl(i3)=1;
                else
                    bdryLvl(i3)=NaN;
                end
            end
            
            
            % initialize the separate layer vectors
            clear bdryRSY bdryRSZ
            
            % using the levels, separate the boundaries
            cntL1=0;
            cntL2=0;
            for i3=1:1:length(bdryLvl)
                
                if bdryLvl(i3)==1
                    cntL1=cntL1+1;
                    bdryRSY{1}(cntL1)=bdryRY(i3);
                    bdryRSZ{1}(cntL1)=bdryRZ(i3);
                elseif bdryLvl(i3)==2
                    cntL2=cntL2+1;
                    bdryRSY{2}(cntL2)=bdryRY(i3);
                    bdryRSZ{2}(cntL2)=bdryRZ(i3);
                elseif isnan(bdryLvl(i3))
                    % do nothing for NaN
                else
                    display('Error in separating boundary layers');
                end
                
            end
            
            
            % sort the boundaries by increasing y-coordinate
            [bdryRSY{1} idxL1]=sort(bdryRSY{1});
            [bdryRSY{2} idxL2]=sort(bdryRSY{2});
            bdryRSZ{1}=bdryRSZ{1}(idxL1);
            bdryRSZ{2}=bdryRSZ{2}(idxL2);
            
            %% plot the pixel boundaries in red and green
            if mod(i2,30)==0    % only plot every so often
                figure(1)
                subplot(1,2,1);
                hold on;
                plot(bdryRSY{1}*data.mPxYSt,bdryRSZ{1}*data.mPxZSt,'.r','LineWidth',1);
                plot(bdryRSY{2}*data.mPxYSt,bdryRSZ{2}*data.mPxZSt,'.g','LineWidth',1);
            end
            
            
            %%  fit circle to each boundary, using the first boundary to determine cell center
            % Modified from MATLAB help:
            % Rewrite the basic equation of a circle:
            % (y-yc)^2 + (z-zc)^2 = radius^2
            % where (yc,zc) is the center, in terms of parameters a, b, c as
            % y^2 + z^2 + a*y + b*z + c = 0
            % where a = -2*yc, b = -2*zc, and c = yc^2 + zc^2 - radius^2.
            % You can solve for parameters a, b, and c using the least squares method.
            % Rewrite the above equation as
            % a*x + b*y + c = -(y^2 + z^2)
            % which can also be rewritten as
            % [y z 1] * [a;b;c] = -y^2 - z^2.
            % To solve for radius only, rewrite as
            % c = -y^2 - z^2 - a*y - b*z
            % Solve these equations using the backslash(\) operator.
            
            for i3=1:1:numBdrs
                
                % deref y and z for loop use
                y=bdryRSY{i3}';
                z=bdryRSZ{i3}';
                
                % find the center using the first layer
                if i3==1
                    
                    % solve the least squares problem
                    abc = [y z ones(length(y),1)] \ (-y.^2 - z.^2);
                    a = abc(1); b = abc(2); c = abc(3);
                    
                    % assign the centers and radius
                    yc = -a/2;
                    zc = -b/2;
                    r(i3)= sqrt((yc^2 + zc^2) - c);
                    
                    % compute the residuals of the lsq problem above
                    rData=sqrt(y.^2+z.^2);
                    
                    
                else
                    % use the center from the first fit for the remaining layers,
                    % requiring concentric circles
                    c = ones(length(y),1) \ (-y.^2 - z.^2 -a.*y -b.*z);
                    
                    % assign the radius
                    r(i3)=sqrt((yc^2 + zc^2) - c);
                end
            end
            
            % compute half angle beta (see np14.100)
            beta=asin(data.stYLen/(2*r(i3)));
            
            % only plot a portion using a fitted circles, based on the
            % radius measured and the width of the image
            theta = (3*pi/2-beta):0.01:(3*pi/2+beta);
            
            %% display the fit info
            % loop over number of boundaries
            for i3=1:1:numBdrs
                % convert to m
                rm(i3)=r(i3)*data.mPxZSt;
                
                % compute and store the centers in meters
                ycm=yc*data.mPxYSt;
                zcm=zc*data.mPxZSt;
                
                center(i1,i2,i3,:)=[ycm zcm];
                % store the radius in meters in structure
                rad(i1,i2,i3)=rm(i3);
            end
            
            %% plot the fitted circles on top of BW image
            if mod(i2,30)==0    % only plot every so often
                figure(1)
                subplot(1,2,1);
                for i3=1:1:numBdrs
                    yFit = rm(i3)*cos(theta)+ycm;
                    zFit = rm(i3)*sin(theta)+zcm;
                    
                    % plot the sections of the fitted radii
                    plot(yFit,zFit,'-y','LineWidth',3);
                    
                    % plot the center of the fit
                    %                 plot(ycm,zcm,'-y','LineWidth',2);
                end
                axis equal
                axis tight
                drawnow;
                
                % grab and store the movie frame
                f2=getframe(gcf); % gets the gcf
                mov=addframe(mov,f2); % adds the frame into mov
            end
            
            %             % display in term
            %             display(sprintf('fit center=(%E,%E) m',ycm,zcm));
            %             display(sprintf('bdry 1 radius=%E m',rm(1)));
            %             display(sprintf('bdry 2 radius=%E m',rm(2)));
            %             display(sprintf('layer 1 [bdry1,bdry2] thickness=%E m',deltaw));
            
            
            
        end
        % update progress bar
        %          progressbar(((i1-1)*data.stXLen+i2)/(data.numSt*data.stXLen));
    end
end


% close the file handle
mov=close(mov); % closes the mov

% play the movie
if data.playMoviesON==1
    implay('./output/getLadRadSt.avi');
end

% compute and store the thickness of the layer
deltaw=abs(rad(:,:,1)-rad(:,:,2));

%% compute the mean radius as a function of time
for i1=1:1:data.numSt
    muRad1(i1)=nanmean(rad(i1,:,1));
    sigmaRad1(i1)=nanstd(rad(i1,:,1));
    muRad2(i1)=nanmean(rad(i1,:,2));
    sigmaRad2(i1)=nanstd(rad(i1,:,2));
    muDeltaw(i1)=nanmean(deltaw(i1,:));
    sigmaDeltaw(i1)=nanstd(deltaw(i1,:));
end

%% store the radius in meters in the data structure
data.rad=rad;
data.deltaw=deltaw;
data.center=center;
data.muRad1=muRad1;
data.sigmaRad1=sigmaRad1;
data.muRad2=muRad2;
data.sigmaRad2=sigmaRad2;
data.muDeltaw=muDeltaw;
data.sigmaDeltaw=sigmaDeltaw;


%% plot the average radii and thickness as functions of time

% create the avi file
mov=avifile('./output/getLadRatStSum.avi','compression','none','fps',4,'quality',100);

clf;
% plot over spatiialy average radii
subplot(2,3,1);
hold on
plot(data.ts,data.muRad1,'.r');
plot(data.ts,data.muRad2,'.b');
errorbar(data.ts,data.muRad1,data.sigmaRad1,'.r');
errorbar(data.ts,data.muRad2,data.sigmaRad2,'.b');
title('Radii');
xlabel('t [s]');
ylabel('r [m]');
legend('Mean Bottom Radius','Mean Top Radius');
axis square


% plot of spatially averaged thickness
subplot(2,3,2);
hold on
plot(data.ts,data.muDeltaw,'.k');
errorbar(data.ts,data.muDeltaw,data.sigmaDeltaw,'.k');
title('Thickness');
xlabel('t [s]');
ylabel('deltaw [m]');
legend('Thickness');
axis square

% plots of the radii and thickness as functions of space for each frame
for i1=1:1:data.numSt

    % create the vector of radius measurement along x
    xVec=data.mPxXSt.*(1:1:length(rad(i1,:,1)));
    
    % create vector to evaluate fitted curve at
%     fitN=10;
%     xiVec=fitN*data.mPxXSt.*(1:1:round(length(rad(i1,:,1))/fitN));
    
    % compute the spatial data fitted to nearest neighbors
%     fT=fittype('nearestinterp');
%      fT=fittype('exp1');
%     rad1F=fit(xVec',rad(i1,:,1)',fT);
%     rad2F=fit(xVec',rad(i1,:,2)',fT);
    
    % plot of radii along the x length
    subplot(2,3,3);
    cla;
    hold on

    % plot of the measured radii points along x
     plot(xVec,rad(i1,:,1),'.','Color',[1,0.75,0.75]);   % red
     plot(xVec,rad(i1,:,2),'.','Color',[0.75,0.75,1]);   % blue

     % plot of the fitted radius along x on top of data
%      plot(xiVec,rad1F(xiVec),'r','LineWidth',2);
%      plot(xiVec,rad2F(xiVec),'b','LineWidth',2);
     
    title('Radii');
    xlabel('x [m]');
    ylabel('radius [m]');
    legend('Bottom Radius','Top Radius');
    
    % plot of thickness along the length
    subplot(2,3,4);
    cla;
    hold on
    % create the vector of thickness measurement along x
    xVec=data.mPxXSt.*(1:1:length(deltaw(i1,:)));
    % plot of the radii along x
    plot(xVec,deltaw(i1,:),'.k');
    title('Cell Wall Thickness');
    xlabel('x [m]');
    ylabel('thickness [m]');
    legend('Cell Wall Thickness');
%     axis square

    % center subfig
    subplot(2,3,5);
    cla;
    hold on;
    % dereference the x,y,z coords
    xCent1=data.mPxXSt*(1:1:length(center(i1,:,1,1)));
    yCent1=center(i1,:,1,1);
    zCent1=center(i1,:,1,2);
    % layer 1 center
    plot3(xCent1, yCent1, zCent1,'.k');
    
    % loop over all radii and centers to plot the wall
    for i2=1:30:length(xCent1)
        % make a vector of parameter values for plotting the circle
        thetaVec=linspace(0,2*pi,50);
        xVec=xCent1(i2).*ones(length(thetaVec));
        yVec=rad(i1,i2,1).*cos(thetaVec)+yCent1(i2);
        zVec=rad(i1,i2,1).*sin(thetaVec)+zCent1(i2);
        % plot circle with radius around each center
        plot3(xVec,yVec,zVec,'Color',[0.75,1,0.75],'LineWidth',3);   % green
    end
    title('Center');
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    legend('Center Top','Center Bottom');
%     view(3)
    drawnow
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
    
    

end

% close the file handle
mov=close(mov); % closes the mov

% play the movie
if data.playMoviesON==1
    implay('./output/getLadRatStSum.avi');
end

%% Next button GUI
figure(1);
% pause or wait for continue
ui.b1=uicontrol('style', 'pushbutton', 'string', 'Next','units','normalized','position', [0.84 0.08 0.10 0.04],...
    'callback', @imNext);

% wait for the user to close the guiworkspaceAfterAllElasticity
uiwait(gcf);

end

% ---- implicit functions
function out=imNext(hObj,event,ax)
uiresume(gcbf);
end

function out=imWait(hObj,event,ax)
% do nothing
end