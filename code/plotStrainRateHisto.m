function plotStrainRateHisto(data)


%% Sub-pixel res: plot strain cross in triangulation for each path step in each time frame

% loop for each path step in each time frame
h=figure(1);
set(h,'units','normalized','Position',data.guiSize);

% create the avi file
mov=avifile('./output/strainRateHisto','compression','none','fps',1,'quality',100);

% display algorithm step entry
display('Plotting strain rate histogram time series');


for i3=1:1:data.numSt-1
    
    clf;
    %% dX
    subplot(1,3,1);
    hold on
    % dX at each triangulation
    hist(data.dX(i3,:),100,'FaceColor','b','EdgeColor','w');
    % dX NN interpolated at triangulation
%     hist(data.dXSVDInterp(:,i3),100,'FaceColor','w','EdgeColor','w');
    % dX NN interpolated at grid
    hist(data.dXSVDInterp{i3},100,'FaceColor','w','EdgeColor','w');
    title(sprintf('dX histogram at frame=%i',i3));
    xlabel('#');
    ylabel('1/s');
    
    %% dY
    subplot(1,3,2);
    hold on
    % dY at each triangulation
    hist(data.dY(i3,:),100,'FaceColor','b','EdgeColor','w');
    % dY NN interpolated at triangulation
%     hist(data.dYSVDInterp(:,i3),100,'FaceColor','w','EdgeColor','w');
        % dX NN interpolated at grid
    hist(data.dYSVDInterp{i3},100,'FaceColor','w','EdgeColor','w');
    title(sprintf('dY histogram at frame=%i',i3));
    xlabel('#');
    ylabel('1/s');
    
    %% dXY
    subplot(1,3,3);
    hold on;
    % dXY at each triangulation
    hist(data.dXY(i3,:),100,'FaceColor','b','EdgeColor','w');
    % dXY NN interpolated at triangulation
%     hist(data.dXYSVDInterp(:,i3),100,'FaceColor','w','EdgeColor','w');
    % dX NN interpolated at grid
    hist(data.dXYSVDInterp{i3},100,'FaceColor','w','EdgeColor','w');
    title(sprintf('dXY histogram at frame=%i',i3));
    xlabel('#');
    ylabel('1/s');
    
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
    
end

% close the file handle
mov=close(mov); % closes the mov

