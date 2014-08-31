%% Use the PIV particle surface features to find the radius
function data=useFeatPIV(data)

% Centroid distance filtering for feature detection
% filter out pixels closer than the value below to each other
% data.cDistTh=sqrt(2*data.winSzPix^2);
data.cDistThMin=10;

% loop over all the time frames
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);
clf;

%% Dereference detected features
numFeats=data.numFeats;
cXMIP=data.cXMIP;
cYMIP=data.cYMIP;
cPrXMIP=data.cPrXMIP;
cPrYMIP=data.cPrYMIP;

% only detect in first frame 
i1=1;

%% Prune the centroids in the first frame to remove features that are too close
% Features that are too close result in poor estimation of the strains, due
% to the uncertainty of the measurement at small lengths.

% create the avi file
% mov=avifile('./output/meshRefine.avi','compression','none','fps',1,'quality',100);


% init filtering variable
cFilt=0;

while cFilt<=data.cDistThMin
    
    % init the filter index vector
    filtIdx=[];
    
    % count the number of filtered features per iteration
    cntFilt=0;
    
    numFeats(i1)=length(cXMIP{i1});
    
    % compute the Euclidian distances between all points in the plane
    cXMIPGrid=ones(numFeats(i1),numFeats(i1))*diag(cXMIP{i1});
    cYMIPGrid=ones(numFeats(i1),numFeats(i1))*diag(cYMIP{i1});
    cDist=sqrt((cXMIPGrid-cXMIPGrid').^2+(cYMIPGrid-cYMIPGrid').^2);

    % Find the distances smaller than the threshold. Exclude the diagonal distances to themselves
    filtMat=(cDist+diag(ones(numFeats(i1),1)).*max(max(cDist)))<cFilt;
    % find the rows with non-zero entries
    filtGtz=sum(filtMat);
    % create the vector of entries to filter
    for i2=1:1:length(filtGtz)
        if filtGtz(i2)~=0
            % count the # of filtrations
            cntFilt=cntFilt+1;
            % create filtering vector
            filtIdx(cntFilt)=i2;
        end
    end
    
    % use the unfiltered features
    cXMIPFilt{i1}=cXMIP{i1};
    cYMIPFilt{i1}=cYMIP{i1};
    cPrXMIPFilt{i1}=cPrXMIP{i1};
    cPrYMIPFilt{i1}=cPrYMIP{i1};
    
    % filter them out
    cXMIPFilt{i1}(filtIdx)=[];
    cYMIPFilt{i1}(filtIdx)=[];
    cPrXMIPFilt{i1}(filtIdx)=[];
    cPrYMIPFilt{i1}(filtIdx)=[];
    
    % plot of the distances as a surface
    %     figure(1);
    %     surf(cDist);
    %     colorbar;
    %     colormap(jet);
    %     view(2);
    %
    % plot of the (Gaussian distributed?) distances as a surface
    %     figure(1);
    %     hist(sum(cDist));
    
    numFiltPaths(i1)=length(cXMIPFilt{i1});
    
    % compute the Euclidian distances between all filtered points in the plane
    cXMIPFiltGrid=ones(numFiltPaths(i1),numFiltPaths(i1))*diag(cXMIPFilt{i1});
    cYMIPFiltGrid=ones(numFiltPaths(i1),numFiltPaths(i1))*diag(cYMIPFilt{i1});
    cDistFilt=sqrt((cXMIPFiltGrid-cXMIPFiltGrid').^2+(cYMIPFiltGrid-cYMIPFiltGrid').^2);
    
    % Triangulate the unfiltered and filtered features and plot their
    % meshes to compare the quality improvements
    cFiltTri=delaunay(cXMIPFilt{i1},cYMIPFilt{i1});
    
    % compute a vector of the minimum feature distance from each point as
    % use this to plot the mesh
    cZFilt=min(cDistFilt+diag(ones(numFiltPaths(i1),1)).*max(max(cDistFilt)));
    
    % update the user in the command window
    display(sprintf('centroids <%1.3f filtered=%i',cFilt,cntFilt));
    
    % plot the updated triangulation
    if cFilt==0
        subplot(3,1,1)
    else
        subplot(3,1,2)
    end
    trimesh(cFiltTri,cXMIPFilt{i1},cYMIPFilt{i1},cZFilt);
    colorbar
    colormap(jet);
    axis equal
        % plot the updated triangulation
    if cFilt==0
        title(sprintf('Unfiltered feature triangulations at frame=%i',i1));
    else
        title(sprintf('Filtered feature triangulations at frame=%i',i1));
    end
    view(2)
    
    %         pause(0.1)
    drawnow;
    
    % overwrite the existing feature vectors with the filtered vectors
    cXMIP{i1}=cXMIPFilt{i1};
    cYMIP{i1}=cYMIPFilt{i1};
    cPrXMIP{i1}=cPrXMIPFilt{i1};
    cPrYMIP{i1}=cPrYMIPFilt{i1};
    numFeats(i1)=numFiltPaths(i1);

    % increment filtration variable by some amount of pixels (possibly fractional)
    cFilt=cFilt+2;
    
    % % close the file handle
% mov=close(mov); % closes the mov

    % grab and store the movie frame
    %         f2=getframe(gcf); % gets the gcf
    %         mov=addframe(mov,f2); % adds the frame into mov
    
    
    
end

% % close the file handle
% mov=close(mov); % closes the mov

% % play the movie
% implay('./output/meshRefine.avi')

% save the figure as a tif
print('-depsc2','-painters','./output/meshRefine.eps');

%% plot centroids in the ROI on the entire image in 2D
subplot(3,1,3)
hold on
% use the gamma corrected MIP for finding beads
im=reshape(data.imMIPGamma(i1,:,:),data.MIPYLen,data.MIPXLen);

% the image object is a 2D image, in microns
imagesc(data.xPxMIPVec,data.yPxMIPVec ,im);

% the centroids
plot(cXMIP{i1},cYMIP{i1},'g.');

% the integer valued centroids
%     plot(cPrXMIP{i1},cPrYMIP{i1},'r.');

% plot the number labels on the centroids
for i2=1:1:numFeats(i1)
    
    % the number labels on the MIP centroids
    text(cPrXMIP{i1}(i2),cPrYMIP{i1}(i2),[num2str(i2)],'HorizontalAlignment','center','Color',[0.75 1 0.5],'FontSize',7);
end
set(gca,'YDir','normal')
colormap(gray);
colorbar
caxis([0 1]);
axis equal
axis tight
xlabel('px');
ylabel('px');
view(2);
drawnow;

% display the remaining paths
display(sprintf('%i remaining features with minimal distance %e',numFeats,data.cDistThMin*data.mPxXMIP));

%% store centroid information with the data structure
data.numFeats=numFeats;
data.cXMIP=cXMIP;
data.cYMIP=cYMIP;
data.cPrXMIP=cPrXMIP;
data.cPrYMIP=cPrYMIP;
