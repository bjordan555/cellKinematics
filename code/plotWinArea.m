function plotWinArea(data,pXPrev,pYPrev,pXAppr,pYAppr,xBMin, xBMax, yBMin, yBMax,im)

% plot individual windows for feature examiniation
figure(23423453)
set(gca,'YDir','normal')
clf;
hold on;

% plot the image
imagesc(im);

% make green box around search area
areaXBox=[xBMin xBMax xBMax xBMin xBMin];
areaYBox=[yBMin yBMin yBMax yBMax yBMin];
plot(areaXBox,areaYBox,'-g');

% plot the starting centroid for each path
plot(pXPrev,pYPrev,'.g');
plot(pXAppr,pYAppr,'.r');

% make green box around previous window 
wXBMinPrev=pXPrev+min(data.winVec);
wXBMaxPrev=pXPrev+max(data.winVec);
wYBMinPrev=pYPrev+min(data.winVec);
wYBMaxPrev=pYPrev+max(data.winVec);
winXBoxPrev=[wXBMinPrev wXBMaxPrev wXBMaxPrev wXBMinPrev wXBMinPrev];
winYBoxPrev=[wYBMinPrev wYBMinPrev wYBMaxPrev wYBMaxPrev wYBMinPrev];
plot(winXBoxPrev,winYBoxPrev,'-g');

% make red box around current window 
wXBMinAppr=pXAppr+min(data.winVec);
wXBMaxAppr=pXAppr+max(data.winVec);
wYBMinAppr=pYAppr+min(data.winVec);
wYBMaxAppr=pYAppr+max(data.winVec);
winXBoxAppr=[wXBMinAppr wXBMaxAppr wXBMaxAppr wXBMinAppr wXBMinAppr];
winYBoxAppr=[wYBMinAppr wYBMinAppr wYBMaxAppr wYBMaxAppr wYBMinAppr];
plot(winXBoxAppr,winYBoxAppr,'-r');

axis equal
axis tight
% axis([xBMin xBMax yBMin yBMax]);
title('Window matching search');
drawnow
hold off;
