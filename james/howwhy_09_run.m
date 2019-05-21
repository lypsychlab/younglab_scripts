% MODELING
% first chunk (pre-scout)
% younglab_model_spm12_pleiades('HOWWHY','YOU_HOWWHY_09','HOWWHY',[5 7 9 11 13 15 17],'dont_smash');
% second chunk (post-scout)
% younglab_model_spm12_pleiades('HOWWHY','YOU_HOWWHY_09','HOWWHY',[25 27 29 31 33 35 37],'dont_smash');

% QUALITY CHECK
% cd('/Users/wass/Documents/projects/howwhy');
% for i = 1:77
%     numstring = sprintf('%04d',i);
%     first_image = ['HOWWHY_results_normed_2/beta_',numstring,'.nii'];
%     second_image = ['HOWWHY_results_normed_3/beta_',numstring,'.nii'];
%     im1 = spm_vol(first_image);
%     im2 = spm_vol(second_image);
%     fprintf('%s\n',im1.descrip);
%     [Y1,XYZ]=spm_read_vols(im1); clear XYZ;
%     [Y2,XYZ]=spm_read_vols(im2); clear XYZ;
%     av1 = nanmean(nanmean(nanmean(Y1)));
% %     disp(sprintf('First chunk average for beta %s: %f',numstring,av1));
%     av2 = nanmean(nanmean(nanmean(Y2)));
% %     disp(sprintf('Second chunk average for beta %s: %f',numstring,av2));
%     fprintf('Difference between first/second chunk averages for beta %s: %f\n',numstring,(av2-av1)/av1);
%     disp('%%%%%%%%%%%%%%%%%%%%%%%%%%');
% end

% it looks like the largest differences are between the constant values
% (betas 0071-0077)

% ITEMWISE BATCH

% first chunk
roi_batch_itemwise({'/home/younglw/lab/HOWWHY/YOU_HOWWHY_09'},'RTPJ','results/HOWWHY_results_normed_2', '/tom_localizer_results_normed', '1', 34, 6, 1, '6:24')
% second chunk
roi_batch_itemwise({'/home/younglw/lab/HOWWHY/YOU_HOWWHY_09'},'RTPJ','results/HOWWHY_results_normed_3', '/tom_localizer_results_normed', '1', 34, 6, 1, '6:24')