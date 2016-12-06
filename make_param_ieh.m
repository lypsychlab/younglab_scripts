%make_param_ieh:
%loads DV values for parametric modulation from a previously constructed table into param variable for behavioral .mats


% param: ncond x 1 cell array, where param{cond}{1} = values for the parameter in that condition for a given run
clear all;
study = 'IEHFMRI';
rootdir='/younglab/studies';
conndir='conn/conn_IEHFMRI_ROI_benoitVMPFC-MTL_itemwise/results/firstlevel/ANALYSIS_01';
subjs={};subj_nums=[4:8 11:14 16:22 24 25];
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
end
mkdir(fullfile(rootdir,study,'logs'));
diary(fullfile(rootdir,study,'logs',['make_param_ieh_' date '.txt']));

cd(fullfile(rootdir,study,'duration60secs_behavioral'));
load T;

for thissub=1:length(subjs)
	counters = zeros(1,4);
	sub_counter=thissub-1;

	for runnum=1:8
		matname=load([subjs{thissub} '.ieh.' num2str(runnum) '.mat']);
        disp([subjs{thissub} '.ieh.' num2str(runnum) '.mat']);
		param=cell(4,1);

		for thiscond=1:4
            switch thiscond
                case 1
                    recode=1;%estimate
                case 2
                    recode=4;%imagine
                case 3
                    recode=2;%journal
                case 4
                    recode=3;%memory
            end
			start_ind=(sub_counter*40)+1+(recode-1)*10;%start of the block for that participant
			%if sub_counter = 1, start_ind for first condition = 1, for second condition = 11, etc.
			%if sub_counter = 2, start_ind for first condition = 41, for second condition = 51, etc.
			param_array=[];

			for thistrial=1:length(matname.spm_inputs(thiscond).ons)
				this_ind=start_ind+counters(recode);
% 				param_array=[param_array T.WilltingesstoHelp(this_ind)];
				param_array=[param_array T.SceneConstruct(this_ind)];
                counters(recode)=counters(recode)+1;
			end

			param{thiscond}{1}=param_array;
% 			param{thiscond}{2}=param_array;


		end

		save([subjs{thissub} '.ieh.' num2str(runnum) '.mat'],'param','-append');
	end
end
diary off;