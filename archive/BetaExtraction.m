spm_name = '/younglab/studies/DIS_MVPA/SAX_DIS_03/results/DIS_results_normed/SPM.mat';
roi_file = '/younglab/studies/DIS_MVPA/SAX_DIS_03/roi/ROI_RTPJ_fb_sad_results_normed_1_31-Jan-2012_xyz.mat';

% Make marsbar design object
D  = mardo(spm_name);
% Make marsbar ROI object
R  = maroi(roi_file);
% Fetch data into marsbar data object
Y  = get_marsy(R, D, 'mean');
% Get contrasts from original design
xCon = get_contrasts(D);
% Estimate design on ROI data
E = estimate(D, Y);
% Put contrasts from original design back into design object
E = set_contrasts(E, xCon);
% get design betas
b = betas(E);
% get stats and stuff for all contrasts into statistics structure
marsS = compute_contrasts(E, 1:length(xCon));