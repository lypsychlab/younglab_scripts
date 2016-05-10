function make_contrast(loc,study,subj_tag,subnum,numruns,cond_list,taskname,res_string)
% make_contrast(loc,study,subj_tag,subnum,numruns,cond_list,taskname,res_string): 
% - builds a contrast/set of contrasts into an existing SPM.mat structure.
% Originally designed for use with model_alek modeling script.
%
% Parameters: 
% - loc: either 'pleiades' or 'server', to set root path
% - study: study name
% - subnum: subject number
% - numruns: number of runs included
% - cond_list: cell string of contrast name/s
% - taskname: tag by which to find behavioral .mats
% - res_string: string to indicate results subfolder in which data will be saved

	if strcmp(loc,'pleiades')
        addpath(genpath('/usr/public/spm/spm8'));
        rootdir = '/home/younglw/';
    else
        rootdir = '/younglab/studies';
    end

% numruns=6;

rootdir = fullfile(rootdir,study);
subj = sprintf([subj_tag '_' '%02d'],subnum);
cd(fullfile(rootdir,subj,'results',res_string));
load('SPM.mat')

cd(fullfile(rootdir,'behavioural'));
% cond_list={'Knew_Acc' 'Knew_Int' 'Real_Acc' 'Real_Int' 'Saw__Acc' 'Saw__Int'};

f=load([subj '.' taskname '.1.mat']);
all_design=f.design; % vector of recoded condition values
con_info=f.con_info; % contrast structure

clear f;
%     cd(prev_dir);
cd(fullfile(rootdir,subj,'results',res_string));

for thiscontrast=1:length(con_info)
    %option A (not working)
    SPM.xCon{thiscontrast} = spm_FcUtil('Set', con_info(thiscontrast).name{1}, 'F', 'c', [con_info(thiscontrast).vals'; zeros(numruns,1)], SPM.xX.xKXs);
    %option B
%     SPM.xCon(thiscontrast) = spm_FcUtil('Set', con_info(thiscontrast).name, 'F', 'c', [con_info(thiscontrast).vals'; zeros(numruns,1)], SPM.xX.xKXs);
%     %option C
%     SPM.xCon(thiscontrast) = spm_FcUtil('Set', con_info(thiscontrast).name{1}, 'F', 'c', [con_info(thiscontrast).vals'], SPM.xX.xKXs);
end
cd(fullfile(rootdir,subj,'results',res_string));
save SPM SPM;
end