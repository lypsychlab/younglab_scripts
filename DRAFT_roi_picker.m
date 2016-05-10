


roi_picker(.001,5,9,1,'LIFG','[-46 4 26]',{'/mindhive/saxelab/CUES3/SAX_cues3_05'},'results/cues3_results_normed');
save(fullfile(subjects{i},'roi',['ROI_' roi_name '_' task '_' num2str(c) '_' date '_xyz.mat']), 'ROI','xY','-mat');

roi_xyz=[-46;4;26];
roi_name='LIFG';
r=9;
res_dir='/results/DIS_results_normed_smoothed';

xY.xyz     = roi_xyz;
xY.name   = roi_name;
xY.Ic      = 0;
xY.Sess    = 1;
xY.def     = 'sphere';
xY.spec   = r; 

% EDIT THIS
[Y,xY] = spm_regions(xSPM,SPM,hReg,xY);


ROI.XYZmm = xY.XYZmm;% ROI coordinates
vinv_data = inv(SPM.xY.VY(1).mat);
ROI.XYZ   = vinv_data(1:3,:)*[ROI.XYZmm; ones(1,size(ROI.XYZmm,2))];
ROI.XYZ   = round(ROI.XYZ);
temp      = strread(res_dir,'%s','delimiter','/');
task      = temp{length(temp)};
