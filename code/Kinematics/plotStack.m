%% function to plot the slices as a 3D stack

function []=plotStack(im)

%% Global toolbar object
% changes made from any function to tb are shared
global tb

% get preview figure
% BEN - Add this to global plotting routine
figure(34343);
clf;

% BEN - Move params to global struct
% internal parameter for plotting stack.  Plot every sRes-th pixel in
% (x,y), every zPlRes-th slice, every xPlRes-th x-plane, and every yPlRes-th y plane.  

hold all;

%% make a low-res stacks for visualization
% show every pixRes-th pixel
pixRes=10;
% how many slices ...
xSl=5;
ySl=5;
zSl=5;

% how many x,y,z planes, given the above params
xRes=ceil(size(im,2)/xSl);
yRes=ceil(size(im,1)/ySl);
zRes=5;

% remember images are indexed by (row=y, col=x). 
imX=im(1:pixRes:size(im,1),1:xRes:size(im,2),:);
imY=im(1:yRes:size(im,1),1:pixRes:size(im,2),:);
imZ=im(1:pixRes:size(im,1),1:pixRes:size(im,2),1:zRes:size(im,3));

%% plot the x-planes
for i2=1:1:size(imX,2);
    p1i=(1:1:size(imX,3));
    p2i=(1:1:size(imX,1));
    [P1i P2i]=meshgrid(p1i,p2i);
    Si=(i2-1).*(xRes./pixRes).*ones(length(p2i),length(p1i));
    % plot the slices with transparency mapped to gradient of image
    Ci=reshape(imX(:,i2,:),[size(imX(:,i2,:),1),size(imX(:,i2,:),3)]);
    surface(Si,P2i,P1i,Ci,...
        'FaceColor','interp',...
        'FaceAlpha','interp',...
        'AlphaDataMapping','scaled',...
        'EdgeColor','none',...
            'AlphaData',gradient(Ci));
    %        'CDataMapping','direct',...
    colormap(jet)
    view(-35,45)
end

%% plot the y-planes
for i2=1:1:size(imY,1);
    p1i=(1:1:size(imY,3));
    p2i=(1:1:size(imY,2));
    [P1i P2i]=meshgrid(p1i,p2i);
    Si=(i2-1).*(yRes./pixRes).*ones(length(p2i),length(p1i));
    % plot the slices with transparency mapped to gradient of image
    Ci=reshape(imY(i2,:,:),[size(imY(i2,:,:),2),size(imY(i2,:,:),3)]);
    surface(P2i,Si,P1i,Ci,...
        'FaceColor','interp',...
        'FaceAlpha','interp',...
        'AlphaDataMapping','scaled',...
        'EdgeColor','none',...
            'AlphaData',gradient(Ci));
    %        'CDataMapping','direct',...
    colormap(jet)
    view(-35,45)
end

%% plot the z-planes
for i2=1:1:size(imZ,3);
    p1i=(1:1:size(imZ,2));
    p2i=(1:1:size(imZ,1));
    [P1i P2i]=meshgrid(p1i,p2i);
    Si=tb.stepZFl.*(i2-1).*ones(length(p2i),length(p1i));
    % plot the slices with transparency mapped to gradient of image
    Ci=reshape(imZ(:,:,i2),[size(imZ(:,:,i2),1),size(imZ(:,:,i2),2)]);
    surface(P1i,P2i,Si,Ci,...
        'FaceColor','interp',...
        'FaceAlpha','interp',...
        'AlphaDataMapping','scaled',...
        'EdgeColor','none',...
            'AlphaData',gradient(Ci));
    %        'CDataMapping','direct',...
    colormap(jet)
    view(-35,45)
end
