function plotWins(imWinPrev,imWinMin)

figure(2)

% plot the previous window
subplot(1,3,1)
cla;
imagesc(imWinPrev);
set(gca,'YDir','normal')
colorbar
colormap(jet);
title('Previous window');
axis equal;
axis tight;

% plot the winning window
subplot(1,3,2)
cla;
imagesc(imWinMin);
set(gca,'YDir','normal')
colorbar
colormap(jet);
title('Current window');
axis equal;
axis tight;

% compute the residuals
res=imWinMin-imWinPrev;

% plot the squared res
subplot(1,3,3)
cla;
imagesc(res.^2);
set(gca,'YDir','normal')
colorbar
colormap(jet);
title('Squared-Residuals of Previous and Current Window');
axis equal;
axis tight;