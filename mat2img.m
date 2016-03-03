function mat2img(varargin)
%Given a list of .tal files - or, if no argument is given, the user
% selects a list - mm2img creates an ROI in analyze format.

if nargin==2
    ROI        = varargin{1};
    roi_fulloc = varargin{2};
else
    ROI        = spm_select(1,'img','Choose a Template image','',pwd,'.*',1);
    roi_fulloc = spm_select(inf,'mat','Choose a ROI .mat file(s)','',pwd,'.*',1);
end

v          = spm_vol(ROI);
[Y,XYZ]    = spm_read_vols(v);
vinv       = inv(v.mat); % matrix converting mm->voxels
wfu        = 0;

for i=1:size(roi_fulloc,1)
[ROI_path,ROI_name] = fileparts(roi_fulloc(i,:));
temp                = load(fullfile(ROI_path,[ROI_name '.mat']));

try
    ROI_tal = temp.xY.XYZmm;ROI_tal = ROI_tal';
catch
    ROI_tal = temp.roi_xyz; wfu = 1;
end

Y_roital = zeros(size(Y));
Y_size   = [size(Y,1) size(Y,2) size(Y,3)];
Y_vector = reshape(Y_roital,1,[]);

for j = 1:size(ROI_tal,1)
    point = find(XYZ(1,:) == ROI_tal(j,1) & XYZ(2,:) == ROI_tal(j,2) & XYZ(3,:) == ROI_tal(j,3));
    Y_vector(point) = 1;
end

Y_roital = reshape(Y_vector,Y_size(1),Y_size(2),Y_size(3));

% if wfu==0
% Y_roital = Y_roital(end:-1:1,:,:);
% end

out = fullfile(ROI_path, [ROI_name '.img']); v.fname = out;
spm_write_vol(v,Y_roital);
fprintf(['Wrote: ' fullfile(ROI_path, [ROI_name '.img']) '\n']);

end