function younglab_RFX_spm12(study,task,subjs,confile,varargin)
%   ====================================================================
% function younglab_RFX_spm8(study,task,subjs,confile,varargin)
%
% This script provides a way to quickly produce a Random Effects analysis
% for a specified list of subjects and contrasts (saxelab style)
%   ====================================================================
% "study" is the root directory for the experiment
% "task" is a string that tells the script where to look for contrast files
%   -this string is also the default name for the new directory in
%   "RandomEffects" unless overridden with a final argument (see below)
% "subjs" is an array of subjIDs
%      -see "help makeIDs" for information on this shortcut
% "confile" is the number in the con_000*.nii file in the results directories.
%   -If these vary between subjects, an array of numbers may be provided
%   instead of a single value
% "contrast_name" is an optional last argument to specify a unique name for
% the new directory in "RandomEffects"
%   -Note: this feature allows you add an additional subdirectory in
%   which to preform the analysis.  For example, in CUES we take repeated
%   samples of our population with "subjs" and place each new analysis in a
%   directory 'sets_n', for the n population samples:
%   E.G.: younglab_RFX('CUES','cues_results_normed',makeIDs('CUES',set3),2,'Sets/set3'))
%
%
% E.G. younglab_RFX_spm8('MOR5','mor5_results',makeIDs('MOR5',[1:14]),2)

% Usage note:
% It's particularly gratifying to loop this.  The sets analysis for CUES was
% as easy as pasting the entire design of population samples in from excel
% (transposed) and running this in matlab:
%   for set=1:length(sets)
%   dir=sprintf('Sets/set%02.f',set);
%   younglab_RFX_spm8('CUES','cues_results_normed',makeIDs('CUES',sets(set,:)),2,dir);
%   end


%===============  Set-up the Directories ==========================
EXPERIMENT_ROOT_DIR = '/data/younglw/lab';

addpath(genpath('/usr/public/spm/spm12'));
% Convert confile to array if scalar was provided:
if ~(length(confile)-1)  %crude test for array vs float
    confile = confile*ones(1,length(subjs));
end

% Decide where users wants to put stuff:
if nargin > 4
    rfx_root = fullfile(EXPERIMENT_ROOT_DIR,study,'RandomEffects',varargin{1});
else
    rfx_root = fullfile(EXPERIMENT_ROOT_DIR,study,'RandomEffects',task);
end

mkdir(rfx_root);
cd(rfx_root);
fprintf('Relocating files for %d subjects\n',length(subjs));

for sub=1:length(subjs)
    try
        source_img = fullfile(EXPERIMENT_ROOT_DIR,study,subjs{sub},'results',task,sprintf('con_%04.f.nii',confile(sub)));
        P{sub}=source_img;
        target_img = sprintf('%s/Img%02.f_%s_con_%04.f.nii',rfx_root,sub,subjs{sub},confile(sub));
        cpcmd = sprintf('!cp %s %s',source_img,target_img);
        eval(cpcmd);
    catch
        source_hdr = fullfile(EXPERIMENT_ROOT_DIR,study,subjs{sub},'results',task,sprintf('con_%04.f.hdr',confile(sub)));
        target_hdr = sprintf('%s/Img%02.f_%s_con_%04.f.hdr',rfx_root,sub,subjs{sub},confile(sub));
        cpcmd = sprintf('!cp %s %s',source_hdr,target_hdr);
        eval(cpcmd);
    end
end

%===============  Perform the Analysis =============================
rfx_anal(P);

end %main function younglab_RFX_spm8

function rfx_anal(P)
% This may not be pretty, but you try going through spm_spm_ui in debug
% mode without documentation to pullout the structures you need for a batch
% file...

SPM.xY.P=P';
SPM.xY.VY = spm_vol(char(P));
iGMsca = 9; % no grand mean scaling
M_X = 0; % no masking
iGXcalc = 1; % omit global calculation
sGXcalc = 'omit';
sGMsca = '<no grand Mean scaling>';
sGloNorm = '<no global normalisation>';

% make sure defaults are in workspace:
spm_get_defaults;

% Select the test you wish to perform (there are 9 others, see spm_spm_ui
% if you wanna get fancy)
D = struct(...
    'DesName','One sample t-test',...
    'n',	[Inf 1 1 1],	'sF',{{'obs','','',''}},...
    'Hform',		'I(:,2),''-'',''mean''',...
    'Bform',		'[]',...
    'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
    'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
    'iGloNorm',9,'iGC',12,...
    'M_',struct('T',-Inf,'I',Inf,'X',Inf),...
    'b',struct('aTime',0));

% Set up xX
I = ones(length(P),4);
for i=1:length(P),I(i,1)=i;end  %yeah i know this is a crappy way to do it
H = ones(length(P),1);B=[];C=[];G=[];
X      = [H C B G];
Hnames = {'mean'};Bnames = {}; Cnames = {}; Gnames = {};
tmp    = cumsum([size(H,2), size(C,2), size(B,2), size(G,2)]);
SPM.xX     = struct(	'X',		X,...
    'iH',		[1:size(H,2)],...
    'iC',		[1:size(C,2)] + tmp(1),...
    'iB',		[1:size(B,2)] + tmp(2),...
    'iG',		[1:size(G,2)] + tmp(3),...
    'name',		{[Hnames; Cnames; Bnames; Gnames]},...
    'I',		I,...
    'sF',		{D.sF});

tmp = {	sprintf('%d condition, +%d covariate, +%d block, +%d nuisance',...
    size(H,2),size(C,2),size(B,2),size(G,2));...
    sprintf('%d total, having %d degrees of freedom',...
    size(X,2),rank(X));...
    sprintf('leaving %d degrees of freedom from %d images',...
    size(X,1)-rank(X),size(X,1))				};

% Specify user-parameters
SPM.xsDes = struct(	'Design',			{D.DesName},...
    'Global_calculation',		{sGXcalc},...
    'Grand_mean_scaling',		{sGMsca},...
    'Global_normalisation',		{sGloNorm},...
    'Parameters',			{tmp}			);


% scan number
SPM.nscan	= size(SPM.xX.X,1);

% save progress in cwd
save SPM SPM

% And now give it a shot:
fprintf('Estimating Design for %d subjects\n',length(P));
SPM = spm_spm(SPM);

% Finally, try and save some work on writing the little contrast
con_vals = [1];
con_name = SPM.xY.VY(1).descrip(12:end); % Pull it out of original guys. convenient, eh?
%try
fprintf('Creating Contrasts for %d subjects\n',length(P));
%save temp SPM con_vals con_name
if isempty(SPM.xCon)
    SPM.xCon = spm_FcUtil('Set', con_name, 'T', 'c', con_vals,SPM.xX.xKXs);
else
    SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals,SPM.xX.xKXs);
end
spm_contrasts(SPM);
%catch
%    fprintf('Oops I screwed up your contrasts\n');
%end


end %function rfx_anal
