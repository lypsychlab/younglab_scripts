subjs={};
for s=1:16
	subjs{end+1}=sprintf('YOU_STOR_%02d',s);
end
subjs{16}='YOU_STOR_TEST01';
% grab_roi_info('STOR',subjs,'*DMPFC*03-Apr-2017*','tom_localizer_results_normed',1,'new_DMPFC');
% grab_roi_info('STOR',subjs,'*VMPFC*04-Apr-2017*','tom_localizer_results_normed',1,'new_VMPFC');
% grab_roi_info('STOR',subjs,'*DMPFC*2013_xyz','tom_localizer_results_normed',1,'old_DMPFC');
grab_roi_info('STOR',subjs,'*PC*2013_xyz','tom_localizer_results_normed',1,'old_PC');
grab_roi_info('STOR',subjs,'*LTPJ*2013_xyz','tom_localizer_results_normed',1,'old_LTPJ');
grab_roi_info('STOR',subjs,'*RTPJ*2013_xyz','tom_localizer_results_normed',1,'old_RTPJ');
