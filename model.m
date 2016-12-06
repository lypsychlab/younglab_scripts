function model(subnum)

if subnum==2
    numruns=14;
else
    numruns=16;
end

rootdir = '/ncf/mcl/03/alek/';
subj = dir([rootdir '*' num2str(subnum)]);subj = subj(1).name;
cd([rootdir '/' subj '/BOLD'])
subj_dir = dir('fun*');
SPM=[];scans=[];

global defaults;spm_defaults;

onsets = 3:6:147;% in scans
for i=1:numruns-1
onsets = [onsets (3:6:147)+(156*i)];
end

load new_regs
load randomness;item_list = unique(randomness); %100 items presented, sorted in order

for run=1:numruns
    scans = [scans; alek_get([rootdir subj '/BOLD/' subj_dir(run).name],'srf*.img')];
end
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
for cond = 1:length(item_list)

    SPM.Sess(1).U(cond).ons    = onsets(find(randomness(1:(25*numruns)) == item_list(cond) ));      % onsets in scans.
    SPM.Sess(1).U(cond).name   = {['Item_' num2str(item_list(cond))]};% item number
    SPM.Sess(1).U(cond).dur    = 2;                         % duration in scans
    SPM.Sess(1).U(cond).P.name = 'none';                    % 'none' | 'time' | 'other'
end

SPM.xX.BCH = 1;SPM.xX.dropscan = [];

SPM.Sess(1).C.name = {};
SPM.Sess(1).C.C = zeros(size(scans,1),numruns-1);
for i=1:numruns-1
    SPM.Sess(1).C.C((i*156)-(156-1):(i*156),i)=1;
    SPM.Sess(1).C.name = [{SPM.Sess(1).C.name{:}} {['Run_' num2str(i)]}];
end

SPM.Sess(1).C.C = [SPM.Sess(1).C.C new_regs(1:size(scans,1),:)];
SPM.Sess(1).C.name = [{SPM.Sess(1).C.name{:}} {'Readibility'} {'Affect'} {'Imagery'} {'Word_Count'} {'Moral'}];  

save SPM SPM
SPM = spm_fmri_spm_ui(SPM);
SPM = spm_spm(SPM);
SPM.xCon = spm_FcUtil('Set', 'all_vs_base', 'F', 'c', [ones(100,1); zeros(numruns,1); zeros(5,1)], SPM.xX.xKXs);
save SPM SPM
end