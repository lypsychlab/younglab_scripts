subjs = {};
% for i = [1:21 23:27 29:30]
%  subjs = [subjs, sprintf('YOU_TPS_%.02d', i)]
% end

for i = [12]
 subjs = [subjs, sprintf('YOU_TPS_%.02d', i)]
end

% add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 11, 'TPS_crn', 'tps')
add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 1, 'tom_localizer', 'tom')