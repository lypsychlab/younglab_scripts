function  Output = art_centroid(Y);
% FORMAT  Output = art_centroid
%       A command line function, GUI asks for an image.
%
% FUNCTION
%   For a scan volume, compute the mean intensity and 
%      centroid positions in each coordinate direction.
%
% INPUT:  A 3D matrix
%   If there is no argument, it asks the user for a .img file.

% OUTPUT:  Output is 1x4 vector.
%  Output(1) = mean intensity of the 3D image
%  Output(2:4) = mean position of data, in X,Y, and Z directions.
%          Dimensions are in voxels.

if ( nargin == 0 )
    F  = spm_get(Inf,'.img','select one image');
    % if it's an array, might want to select one image.
    f = deblank(F(54,:));  % was F(1,:)
    V = spm_vol(f);
    Y = spm_read_vols(V);   % Y is double, size 2MB; 
end

[ NX, NY, NZ ] = size(Y);

%  Find the global properties
Ymean = mean(mean(mean(Y)));   % Average intensity
planex = zeros(NX,1);
planey = zeros(NY,1);
planez = zeros(NZ,1);
%  Moment arrays in x,y, and z directions.
momx = 0; sumx = 0;
for i = 1:NX
    planex(i) = mean(mean(Y(i,:,:)));
    momx = momx + i*planex(i);
    sumx = sumx + planex(i);
end
momy = 0; sumy = 0;
for i = 1:NY
    planey(i) = mean(mean(Y(:,i,:)));
    momy = momy + i*planey(i);
    sumy = sumy + planey(i);
end
momz = 0; sumz = 0;
for i = 1:NZ
    planez(i) = mean(mean(Y(:,:,i)));
    momz = momz + i*planez(i);
    sumz = sumz + planez(i);
end

% Set return values
Output(1) = Ymean;
Output(2) = momx/sumx;  % centroid in voxels
Output(3) = momy/sumy;
Output(4) = momz/sumz;


