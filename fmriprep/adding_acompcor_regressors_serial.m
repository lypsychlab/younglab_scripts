addpath(genpath('/data/younglw/lab/scripts'))  % for alek_get

subjs = {};
% for i = [1:21 23:27 29:30]
%  subjs = [subjs, sprintf('YOU_TPS_%.02d', i)]
% end

subjs = makeIDs('TPS', [1:30]);

% add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 11, 'TPS_crn', 'tps')
% add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 1, 'tom_localizer', 'tom')
add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 10, 'TPS_crn', 'tps', '/data/younglw/lab/TPS_FMRIPREP/full_infile_TPS.csv')
add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 2, 'tom_localizer', 'tom', '/data/younglw/lab/TPS_FMRIPREP/full_infile_TPS.csv')