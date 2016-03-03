function model_alek(loc,study,subj_tag,subnum,runs,ips,smooth,res_string)
% modified by emily, 12/2015
% model_alek(loc,study,subnum,runs):
% - stripped-down modeling script that concatenates runs.
%
% Parameters:
% - loc: either 'pleiades' or 'server', to set root path
% - study: study name
% - subnum: subject number
% - runs: vector of run numbers
% - ips: self-explanatory
% - smooth: either 'smooth' or 'unsmooth', to look for appropriate functional files
% - res_string: string to indicate results subfolder in which data will be saved

    if strcmp(loc,'pleiades')
        addpath(genpath('/usr/public/spm/spm8'));
        rootdir = '/home/younglw/';
    else
        rootdir = '/younglab/studies'
    end

    numruns=length(runs);
    if strcmp(smooth,'smooth')
        smooth_flag='swraf';
    else
        smooth_flag='wraf';
    end

    rootdir = [rootdir '/' study];
    subj = sprintf([subj_tag '_' '%02d'],subnum);
    cd([rootdir '/' subj '/bold'])

    % subj_dir = dir('fun*');
    SPM=[];scans=[];

    global defaults;
    defaults=spm_get_defaults;

    % onsets = 3:6:147;% in scans
    % for i=1:numruns-1
    % onsets = [onsets (3:6:147)+(156*i)];
    % end

    % load new_regs
    % load randomness;item_list = unique(randomness); %100 items presented, sorted in order

    prev_dir=pwd;
    cd(fullfile(rootdir,'behavioural'));
    % all_onsets=[];all_durations=[];
    all_inputs=struct('ons',{[], [], [], [], [], []},'dur',{[], [], [], [], [], []});
    cond_list={'Knew_Acc' 'Knew_Int' 'Real_Acc' 'Real_Int' 'Saw__Acc' 'Saw__Int'};
    % user_regressors_list={'mvt_x' 'mvt_y' 'mvt_z' 'mvt_pitch' 'mvt_roll' 'mvt_yaw'};
    % user_regressors=struct('ons',{[], [], [], [], [], []});
    for R=1:numruns
    	f=load([subj '.' taskname '.' num2str(R) '.mat']);
    	if R==1
    		all_design=f.design; % vector of recoded condition values
            con_info=f.con_info; % contrast structure	
    	end
        
    	for thiscond=1:length(cond_list)
            ONSETS=[];
            DURATIONS=[];
            ONSETS=[ONSETS; (f.spm_inputs(thiscond).ons' + ips*(R-1))];
            DURATIONS=[DURATIONS; f.spm_inputs(thiscond).dur'];
    		% all_inputs(thiscond).ons=[all_inputs(thiscond).ons; (f.spm_inputs(thiscond).ons' + ips*(R-1))]; 
    		% all_inputs(thiscond).dur=[all_inputs(thiscond).dur; f.spm_inputs(thiscond).dur'];
            all_inputs(thiscond).ons=[all_inputs(thiscond).ons;ONSETS];
            all_inputs(thiscond).dur=[all_inputs(thiscond).dur;DURATIONS];
    	end

        % for this_mvt=1:length(f.user_regressors)
        %     UR=[];
        %     UR=[UR; f.user_regressors(this_mvt).ons(:,1:6)];
        %     user_regressors(this_mvt).ons = [user_regressors(this_mvt).ons; UR];
        % end
    	clear f;
    end
    cd(prev_dir);


    for R=1:numruns
    	run_string=sprintf('%03d',runs(R));
        scans = [scans; alek_get([rootdir subj '/bold/' run_string '/'],smooth_flag '*.img')];
    end

    cd([rootdir '/' subj '/results']);mkdir(res_string);cd(res_string);


    save([subj '_' taskname '_inputs.mat']);

    SPM.xY.P = scans;

    % User-defined parameters for this analysis
    SPM.nscan(1)       = size(scans,1);% number of scans for each of nsess sessions
    SPM.xY.RT          = 2;            % experiment TR in seconds
    SPM.xGX.iGXcalc    = {'Scaling'};  % global normalization: OPTIONS:'Scaling'|'None'
    SPM.xX.K.HParam    = 128;          % high-pass filter cutoff (secs) [Inf = no filtering]
    SPM.xVi.form       = 'none';       % intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'

    % basis functions and timing parameters
    SPM.xBF.name       = 'hrf';
    SPM.xBF.T          = 16;          % number of time bins per scan
    SPM.xBF.T0         = 1;           % reference time bin
    SPM.xBF.UNITS      = 'scans';     % OPTIONS: 'scans'|'secs' for onsets
    SPM.xBF.Volterra   = 1;           % OPTIONS: 1|2 = order of convolution; 1 = no Volterra

    %conditions
    for thiscond = 1:length(cond_list)

        % SPM.Sess(1).U(cond).ons    = onsets(find(randomness(1:(25*numruns)) == item_list(cond) ));      % onsets in scans.
        % SPM.Sess(1).U(cond).name   = {['Item_' num2str(item_list(cond))]};% item number
        % SPM.Sess(1).U(cond).dur    = 2;                         % duration in scans
        % SPM.Sess(1).U(cond).P.name = 'none';                    % 'none' | 'time' | 'other'
        SPM.Sess(1).U(thiscond).ons    = all_inputs(thiscond).ons;    % onsets in scans.
        SPM.Sess(1).U(thiscond).name   = {cond_list{thiscond}};
        SPM.Sess(1).U(thiscond).dur    = all_inputs(thiscond).dur;                         % duration in scans
        SPM.Sess(1).U(thiscond).P.name = 'none';                    % 'none' | 'time' | 'other'
    end

    SPM.xX.BCH = 1;SPM.xX.dropscan = [];

    SPM.Sess(1).C.name = {};
    SPM.Sess(1).C.C = zeros(size(scans,1),numruns-1);

    % for j=1:length(user_regressors_list)
    %     SPM.Sess(1).C.C((j*ips)-(ips-1):(j*ips),j)=user_regressors(j).ons(ips,1:6);
    %     SPM.Sess(1).C.name = [{SPM.Sess(1).C.name{:}} {user_regressors_list{j}}];
    % end

    for i=1:numruns-1
        SPM.Sess(1).C.C((i*ips)-(ips-1):(i*ips),i+6)=1;
        SPM.Sess(1).C.name = [{SPM.Sess(1).C.name{:}} {['Run_' num2str(i)]}];
    end

    

    % SPM.Sess(1).C.C = [SPM.Sess(1).C.C new_regs(1:size(scans,1),:)];
    % SPM.Sess(1).C.name = [{SPM.Sess(1).C.name{:}} {'Knew_Acc'} {'Knew_Int'} {'Real_Acc'} {'Real_Int'} {'Saw__Acc'} {'Saw__Int'}];  

    save SPM SPM
    SPM = spm_fmri_spm_ui(SPM);
    SPM = spm_spm(SPM);
    % for thiscontrast=1:length(con_info)
    %     SPM.xCon(thiscontrast) = spm_FcUtil('Set', con_info(thiscontrast).name{1}, 'F', 'c', [con_info(thiscontrast).vals'; zeros(numruns,1)], SPM.xX.xKXs);
    % end
    cd(fullfile(rootdir,subj,'results')); cd(res_string);
    save SPM SPM;
end