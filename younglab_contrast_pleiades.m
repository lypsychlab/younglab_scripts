			
function younglab_contrast_pleiades(EXPERIMENT_ROOT_DIR,study,subj_tag,sub_nums,resdir,tname)

addpath(genpath('/usr/public/spm/spm12'));

for thissub=1:length(sub_nums)
	% try
			disp(['Running contrasts for subject ' sprintf('%02d',sub_nums(thissub))]);
			load(fullfile(EXPERIMENT_ROOT_DIR,study,'behavioural',[subj_tag '_' sprintf('%02d',sub_nums(thissub)) '.' tname '.1.mat']),'con_info');
			cd(fullfile(EXPERIMENT_ROOT_DIR,study,[subj_tag '_' sprintf('%02d',sub_nums(thissub))],'results',resdir));

			load(fullfile(pwd,'SPM.mat'));
			SPM

            total_len=length(SPM.Vbeta);
            for thiscon=1:length(con_info)
                if length(con_info(thiscon).vals)<total_len
                    con_info(thiscon).vals = [con_info(thiscon).vals zeros(1,total_len-length(con_info(thiscon).vals))];
                end
                if isempty(SPM.xCon)
                	% SPM.xCon=spm_FcUtil('Set', con_info(thiscon).name{1}, 'T', 'c', con_info(thiscon).vals',SPM.xX.xKXs);
                    SPM.xCon=spm_FcUtil('Set', con_info(thiscon).name, 'T', 'c', con_info(thiscon).vals',SPM.xX.xKXs);

                else
                	% SPM.xCon(end+1)=spm_FcUtil('Set', con_info(thiscon).name{1}, 'T', 'c', con_info(thiscon).vals',SPM.xX.xKXs);
                    SPM.xCon(end+1)=spm_FcUtil('Set', con_info(thiscon).name, 'T', 'c', con_info(thiscon).vals',SPM.xX.xKXs);

                end
            end

            %---------------------------------------------------------------------------
            spm_contrasts_pleiades(SPM);
            disp('Done.')
    % catch
    % 	disp(['Error with subject ' sprintf('%02d',sub_nums(thissub))]);
    % 	continue
   	% end
end
end % end function