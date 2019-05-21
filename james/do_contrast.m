function do_contrast(subnum)

% modified by emily
% subnum: int
% runs: numerical array


% if subnum==2
%     numruns=14;
% else
%     numruns=16;
% end

% subnum = 5;

addpath(genpath('/usr/public/spm/spm8'))

numruns=6;

rootdir = '/home/younglw/VERBS/';
subj = sprintf(['SAX_DIS_' '%02d'],subnum);
cd(fullfile(rootdir,subj,'results/model_alek_verbsCOR'));
load('SPM.mat')

cd(fullfile(rootdir,'behavioural'));
cond_list={'Knew' 'Realize' 'Saw'};

f=load([subj '.DIS_verbs.1.mat']);
all_design=f.design; % vector of recoded condition values
con_info=f.con_info; % contrast structure

clear f;
%     cd(prev_dir);
cd(fullfile(rootdir,subj,'results/model_alek_verbsCOR'));

for thiscontrast=1:length(con_info)
    %option A (not working)
    SPM.xCon{thiscontrast} = spm_FcUtil('Set', con_info(thiscontrast).name{1}, 'F', 'c', [con_info(thiscontrast).vals'; zeros(numruns,1)], SPM.xX.xKXs);
    %option B
%     SPM.xCon(thiscontrast) = spm_FcUtil('Set', con_info(thiscontrast).name, 'F', 'c', [con_info(thiscontrast).vals'; zeros(numruns,1)], SPM.xX.xKXs);
%     %option C
%     SPM.xCon(thiscontrast) = spm_FcUtil('Set', con_info(thiscontrast).name{1}, 'F', 'c', [con_info(thiscontrast).vals'], SPM.xX.xKXs);
end
cd(fullfile(rootdir,subj,'results/model_alek_verbs'));
save SPM SPM;
end