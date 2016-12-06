function model_alek_verbs(subnum,runs)

    % modified by emily
    % subnum: int
    % runs: numerical array


    % if subnum==2
    %     numruns=14;
    % else
    %     numruns=16;
    % end
    addpath(genpath('/usr/public/spm/spm8'))

    numruns=length(runs);

    rootdir = '/home/younglw/VERBS/';
    subj = sprintf(['SAX_DIS_' '%02d'],subnum);
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
    all_inputs=struct('ons',{[], [], []},'dur',{[], [], []});
    cond_list={'Knew' 'Realize' 'Saw'};
    for R=1:numruns
    	f=load([subj '.DIS_verbs.' num2str(R) '.mat']);
    	if R==1
    		all_design=f.design; % vector of recoded condition values
            con_info=f.con_info; % contrast structure	
    	end
        
    	for thiscond=1:length(cond_list)
            ONSETS=[];
            DURATIONS=[];
            ONSETS=[ONSETS; (f.spm_inputs(thiscond).ons + 166*(R-1))];
            DURATIONS=[DURATIONS; f.spm_inputs(thiscond).dur];
    		% all_inputs(thiscond).ons=[all_inputs(thiscond).ons; (f.spm_inputs(thiscond).ons' + 166*(R-1))]; 
    		% all_inputs(thiscond).dur=[all_inputs(thiscond).dur; f.spm_inputs(thiscond).dur'];
            all_inputs(thiscond).ons=[all_inputs(thiscond).ons;ONSETS];
            all_inputs(thiscond).dur=[all_inputs(thiscond).dur;DURATIONS];
    	end

    	clear f;
    end
    cd(prev_dir);


    for R=1:numruns
    	run_string=sprintf('%03d',runs(R));
        scans = [scans; alek_get([rootdir subj '/bold/' run_string '/'],'wraf*.img')];
    end
    
    cd(fullfile(rootdir,subj,'results'));
    mkdir('model_alek_verbsCOR'); cd('model_alek_verbsCOR');
    
    save([subj '_verbsCOR_inputs.mat']);

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
    for i=1:numruns-1
        SPM.Sess(1).C.C((i*166)-(166-1):(i*166),i)=1;
        SPM.Sess(1).C.name = [{SPM.Sess(1).C.name{:}} {['Run_' num2str(i)]}];
    end

    % SPM.Sess(1).C.C = [SPM.Sess(1).C.C new_regs(1:size(scans,1),:)];
    % SPM.Sess(1).C.name = [{SPM.Sess(1).C.name{:}} {'Knew_Acc'} {'Knew_Int'} {'Real_Acc'} {'Real_Int'} {'Saw__Acc'} {'Saw__Int'}];  

    save SPM SPM
%     try
        SPM = spm_fmri_spm_ui(SPM);
        SPM = spm_spm(SPM);
    %     for thiscontrast=1:length(con_info)
    %         SPM.xCon(thiscontrast) = spm_FcUtil('Set', con_info(thiscontrast).name{1}, 'F', 'c', [con_info(thiscontrast).vals'; zeros(numruns,1)], SPM.xX.xKXs);
    %     end
%     catch
%         disp(['Error for subject ' subj ': could not model.']);
%     end
    save SPM SPM;
end