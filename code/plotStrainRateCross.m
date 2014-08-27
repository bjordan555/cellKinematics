function plotStrainRateCross(data)

%% Sub-pixel res: plot strain cross in triangulation for each path step in each time frame

% loop for each path step in each time frame
h=figure(1);
set(h,'units','normalized','outerposition',data.guiSize);

% create the avi file
mov=avifile('./output/strainRateCross.avi','compression','none','fps',1,'quality',100);

% display algorithm step entry
display('Plotting strain rate cross time series');


for i3=1:1:data.numSt-1
    clf;
    hold on
    
    % dereference the image
    im=reshape(data.imMIP(i3,:,:),data.MIPYLen,data.MIPXLen);
    
    % plot the images
    imagesc(data.xMMIPVec, data.yMMIPVec, im);
    %caxis([0 1]);
    colormap(gray)
    
    % plot the triangulation
    triplot(data.pathTriRepSpr{i3},'g','Color',[0.5,0.5,0.5]);
    
    % make strain rate cross for each triangle
    for i4=1:1:size(data.triX{i3},2)
        
        % scale strain crosses by a factor.  Multiplies strain rate
        % to give number of pixels of length of each cross axis.
        sF=0.000005;
        
        pAx1Spr=data.triSprCc{i3}(1,i4)+sF*((data.pSC(i3,i4)/2));
        pAy1Spr=data.triSprCc{i3}(2,i4);
        pAx2Spr=data.triSprCc{i3}(1,i4)-sF*((data.pSC(i3,i4)/2));
        pAy2Spr=data.triSprCc{i3}(2,i4);
        
        qAx1Spr=data.triSprCc{i3}(1,i4);
        qAy1Spr=data.triSprCc{i3}(2,i4)+sF*((data.qSC(i3,i4)/2));
        qAx2Spr=data.triSprCc{i3}(1,i4);
        qAy2Spr=data.triSprCc{i3}(2,i4)-sF*((data.qSC(i3,i4)/2));
        
        % compute the centers
        pXCent=mean([pAx1Spr, pAx2Spr]);
        pYCent=mean([pAy1Spr, pAy2Spr]);
        qXCent=mean([qAx1Spr, qAx2Spr]);
        qYCent=mean([qAy1Spr, qAy2Spr]);
        
        pVec1=[pAx1Spr-pXCent; pAy1Spr-pYCent];
        qVec1=[qAx1Spr-qXCent; qAy1Spr-qYCent];
        pVec2=[pAx2Spr-pXCent; pAy2Spr-pYCent];
        qVec2=[qAx2Spr-qXCent; qAy2Spr-qYCent];
        
        % rotate the strain cross to the angle
        %         Qm=[cos(data.beta(i3,i4)) -sin(data.beta(i3,i4)); sin(data.beta(i3,i4)) cos(data.beta(i3,i4))];
        Qm=[cos(data.beta(i3,i4)) -sin(data.beta(i3,i4)); sin(data.beta(i3,i4)) cos(data.beta(i3,i4))];
        pVecRot1=Qm*pVec1;
        qVecRot1=Qm*qVec1;
        pVecRot2=Qm*pVec2;
        qVecRot2=Qm*qVec2;
        
        % add back in the center to return to original position
        pXRot1=pVecRot1(1)+pXCent;
        pYRot1=pVecRot1(2)+pYCent;
        pXRot2=pVecRot2(1)+pXCent;
        pYRot2=pVecRot2(2)+pYCent;
        qXRot1=qVecRot1(1)+qXCent;
        qYRot1=qVecRot1(2)+qYCent;
        qXRot2=qVecRot2(1)+qXCent;
        qYRot2=qVecRot2(2)+qYCent;
        
        % plot the strain cross with color designating positive or negative normal strain rate.
        if data.pSC(i3,i4) < 1
            plot([pXRot1 pXRot2],[pYRot1 pYRot2],'-r','LineWidth',2);
        else
            plot([pXRot1 pXRot2],[pYRot1 pYRot2],'-b','LineWidth',2);
        end
        
        if data.qSC(i3,i4) < 1
            plot([qXRot1 qXRot2],[qYRot1 qYRot2],'-r','LineWidth',2);
        else
            plot([qXRot1 qXRot2],[qYRot1 qYRot2],'-b','LineWidth',2);
        end
        
        
        
        %         % label each strain rate cross with a number
        %         text(data.triCc{i3}(1,i4), data.triCc{i3}(2,i4),[num2str(i4)],'HorizontalAlignment','center','Color','yellow','FontSize',10);
    end
    
    title(sprintf('Strain rate crosses at frame=%i',i3));
    axis equal
    axis tight
    axis(data.pROIVec);
    xlabel('px');
    ylabel('px');
    hold off;
    drawnow;
    
    % grab and store the movie frame
    f2=getframe(gcf); % gets the gcf
    mov=addframe(mov,f2); % adds the frame into mov
    
end

% close the file handle
mov=close(mov); % closes the mov

% play the movie
if data.playMoviesON==1
    implay('./output/strainRateCross.avi');
end