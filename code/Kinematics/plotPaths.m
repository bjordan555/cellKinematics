function plotPaths(data)


% display algorithm step entry
display('Plotting paths');

%% plot of pixel resolution paths by centroid
h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);
clf;
subplot(2,1,1);
hold on;

% sum the image series to show the tracers of each centroid
for i3=1:1:data.numSt
    
    % dereference the image
    im=reshape(data.imMIP(i3,:,:),data.MIPYLen,data.MIPXLen);
    
    if i3==1
        imSum=im;
    else
        %             imSum=imSum+data.flMIPNorm{i3};
        imSum=imSum+im;
    end
end
% normalize the summed image for display
imSumNorm=(imSum-min(min(imSum)))./(max(max(imSum))-min(min(imSum)));

% plot the summed image series
imagesc(imSumNorm);
% caxis([0 1]);
set(gca,'YDir','normal')
% colorbar;
colormap(gray);
axis([min(data.xMMIPVec) max(data.xMMIPVec) min(data.yMMIPVec) max(data.yMMIPVec)]);
axis equal
axis tight
xlabel('pX');
ylabel('pY');
title('Pixel resolution paths');
view(2);
drawnow;

% plot the individual paths
for i2=1:1:data.numPaths
    % plot the starting centroid for each path
    plot(data.pX(i2,1), data.pY(i2,1),'.g');
    % the offset number labels on the paths
    text(data.pX(i2,1), data.pY(i2,1),[num2str(i2)],'HorizontalAlignment','center','Color','red','FontSize',8);

    % for each frame pair, show the path step.  In the case of the fixed reference
    % frame, all path steps start at same point. 
    for i3=1:1:data.numSt-1
        % create line vectors for plotting each path step
        xPlVec=[data.pX(i2,i3) data.pX(i2,i3)+data.stepX(i2,i3+1)];
        yPlVec=[data.pY(i2,i3) data.pY(i2,i3)+data.stepY(i2,i3+1)];
        
        % Pixel res paths
        plot(xPlVec,yPlVec,'.g');
        plot(xPlVec,yPlVec,'-b');
    end
end


%% Plot of the minimizing R^2 for window matching by time frame and bead number
% Note that centroid finding algorithm numbers paths from lower left to
% upper right of screen.
subplot(2,1,2);
imagesc(data.minRsq);
xlabel('Time Frame');
ylabel('Path #');
title('Minimizing R^2 value for each path step');
set(gca,'YDir','normal')
view(2)
colorbar;
% colormap(jet);
drawnow;

% %% Plot of the minimizing SSD for window matching by time frame and bead number
% % Note that centroid finding algorithm numbers paths from lower left to
% % upper right of screen.
% subplot(2,2,3);
% imagesc(data.minSSD);
% set(gca,'YDir','normal')
% xlabel('Time Frame');
% ylabel('Path #');
% title('Minimizing SSD value for each path step');
% view(2)
% colorbar;
% colormap(jet);
% drawnow;


% %% Plots of the SSD surface for each path number
% subplot(2,2,4);
% for i4=1:1:data.numPaths
%     for i5=1:1:data.numSt
%         cla;
%         hold on
%         pcolor(data.stepXVec,data.stepYVec, data.SSD{i4,i5}');
%         plot(data.stepXVec(data.minX(i4,i5)),data.stepYVec(data.minY(i4,i5)),'.y');
%         shading interp
%         xlabel('x=cols=j'); ylabel('y=rows=i');
%         title(sprintf('SSD surface for path %i, frame %i',i4,i5));
%         axis tight
%         axis equal
% %         axis([0 data.winStepSzXPix 0 data.winStepSzYPix 0 max(max(data.SSD{i4,i5}))+1]);
% %         caxis([0 max(max(data.SSD{i4,i5}))+1]);
%         colorbar
%         colormap(jet);
%         drawnow;
% %         pause;
%     end
% end

