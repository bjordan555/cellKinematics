%% Code for creating moire patterns between a helical surface and a grid
%% Ben Jordan, 2012. 

%% Todo

% * The existence of a diffraction grating can be given by overlaying a
% grid of known width and spacing. Add in pixel sampling by interpolating
% values at the center of each grid point, where its magnitude is
% determined by the normalized ratio of blue to black in the image of the
% orthogonal projection. 

% * Animate over a rotation of the helix angle. 

% * Automatically calculate the remaining parameters for the helix based on
% the two things that we want to measure, i.e. the fiber spacing and the
% fiber angle, as measured from horizontal. 


%% Init
clear all
close all

%% Params

% diffraction grid on/off
diffGrid=0;

% total cylinder radius
r=500E-6;

% total cylinder length
l=1000E-6;

% fiber thickness in points, as in dpi.  This is the resolution of the object
% that can be captured by the simulated CCD, or printed to a page. 
% Cellulose fiber thickness is 250 nm=9.84E-6 inches. Printed at 1200 dpi,
% each point is smaller thatn 1 dot. Image can be sampled at magnified
% resolution however, and is during CCD capture. 
deltac=1;

% center to center spacing between fibers within same plane normal to wall surface. 
deltas=250E-9;

% set the fiber angle as measured from radial axis at normal wall surface. 
alpha=12;

% calculate the number of turns required to satisfy length and radius
nTurns=15;

% pitch is 2*pi*b as measured ccw from the long axis in degrees at a surface
% in the XZ plane. Note this is scaled to length l
b=l/(nTurns*2*pi); 
display(sprintf('Pitch=%1.4f',b*2*pi));

% output the fiber angle as measured in the plane at the surface 
alpha=atan(2*pi*b/r);

display(sprintf('Fiber angle alpha=%1.4f',radtodeg(alpha)));

% How many discrete linear interpolations per turn?
nK=90;

% diffraction grid resolution (number of grid points per roi edge)
nGr=150;

% sampling grid resolution (number of pixels per roi edge)
sGr=2000;

% roi for simulated CCD
xL=100E-6;
yL=20E-6;
zL=20E-6;
roiX1=l/2-xL/2;
roiX2=l/2+xL/2;
roiY1=-yL/2;
roiY2=yL/2;
roiZ1=-zL/2;
roiZ2=zL/2;

% vector of phase shifts for plotting multiple helicies
theta=0:deltas:2*pi*b;

% phase shifts for plotting layers of helicies (currently packed
% equilateral triangles.

% shift on long axis
deltax=[0 deltas/2];

% shift in depth
deltay=[0 deltas/2];

% calculate the number of helicies to plot to fulfill spacing requirements
nH=length(theta);
% nH=2;

h=figure(1);
hold on;

%% generate helix parametrically
t = 0:2*pi/nK:2*pi*nTurns;

for i2=1:1:length(deltax)
    for i1=1:1:nH
        % plot the layers of white helicies
        plot3(b*t+theta(i1)+deltax(i2),r*sin(t)+deltay(i2),r*cos(t),'w','LineWidth',deltac);
    end
end
%% plot the black surface at the bottom of the z-stack depth
patch([0 0 l l],[0 0 0 0],[-r r r -r],'k');

%% plot the black diffraction grid plane
if diffGrid==1
    xg1=linspace(0,l,nGr);
    zg1=linspace(-r,r,nGr);
    [xx1,zz1]=meshgrid(xg1,zg1);
    xx2=xx1';
    zz2=zz1';
    yy1=r*ones(1,nGr);
    yy2=r*ones(nGr,1);
    plot3(xx1,yy1,zz1,'k','LineWidth',1);
    plot3(xx2,yy2,zz2,'k','LineWidth',1);
end

% rotate the figure to standard experimental direction.  
az=8;
el = 180;
view(az, el);

% decorate figure
xlabel('x=r*cos(t)');
ylabel('y=r*sin(t)');
zlabel('z=[0,l]');
grid on;
% axis square;
axis equal;
axis off;

% Set the axis to give the ROI acquired on the simulated CCD image
axis([roiX1 roiX2 roiY1 roiY2 roiZ1 roiZ2]);
drawnow;

%% plot sampled pixel values simulating the CCD/PMT sampling grid plane

% save a eps vector graphics file format of the figure contents
% hgsave(h,'ccdCapture.eps');
% print -r600 -dps ccdCapture;
% saveas(h,'ccdCapture.eps','eps');
display('Save this figure as ccdCapture.eps (automate)');
pause();

% convert the ps file to a color bitmap at full resolution
[status,result] = unix('pstoimg ccdCapture.eps -density 1200 -depth 8','-echo');

% open the ccd capture bitmap
im=imread('ccdCapture.png');

% plot the captured image and display resolution
figure(2);
imshow(im);
drawnow;
display(sprintf('Color CCD image acquired at %ix%i',size(im,2),size(im,1)));

xs1=linspace(0,size(im,2),sGr);
zs1=linspace(0,size(im,1),sGr);

% interpolate a smaller image onto the smapling grid using nearest neighbor interpolation
imInt=interp2(im,xs1',zs1);

% display the sampled image
figure(3)
imshow(imInt)



