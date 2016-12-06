function younglab_genmask(study, subject, normalized)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% younglab_getmask(study, subject[, normalized])
%
% generates a mask using both anatomical and functional data. study and
% subject are both strings, normalized is an optional input to force the
% script to generate normalized (if 1) or unnormalized (if 0) masks. 
%
% Usage:
%
%   younglablab_getmask('TOM','SAX_TOM_01')
%   younglablab_getmask('TOM','SAX_TOM_01',0) (generates unnormalized mask)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function will generate a proper mask given a study & subject pair,
% and place it in the 3danat directory for that subject. This is to
% alleviate problems where the anatomical-generated mask includes regions
% that are cut out of the image in the functionals because of the smaller
% bounding box. This is done in several steps:
%       (1) a functional image is coregistered to the anatomical
%       (2) the functional image is then resliced to the anatomical
%       (3) the resliced anatomical is used to create a mask 
%       (4) the unnormalized anatomical is skull-stripped
%       (5) skull-stripped anatomical is binarized to form a second mask
%       (6) a third mask is generated from the conjunction of the first two
%       (7) the normalization warp is applied to the third mask, with NN
%           interpolation
%       (8) this results in a bounded anatomical mask, which is moved to
%           the 3danat directory. 
%   
% the script will also attempt to determine whether or not a normalized
% mask should be produced. if this isn't necessary, then step 7 is omitted.
%
%   npd 5/25/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
odir = pwd;
%% Find the study 
fprintf('Locating study & subject.\n');
root = adir(sprintf('/younglab/studies*/%s/%s',study,subject));
if ~iscell(root)
    terror('Could not locate study/subject pair.');
elseif length(root) > 1
    root = adir(sprintf('-t /younglab/studies*/%s/%s',study,subject));
    root = root{1};
    warning('Found more than one matching study/subject pair!')
    warning(sprintf('Will analyze most recent one: %s',root));
else
    root = root{1};
end
repo_dir = fullfile(root,'report');
mkdir(repo_dir);
%%
cd(root);
if exist('mask','dir')
    cd mask
    if exist('complete_without_errors','file')
        fprintf('Mask has already been created.\n If you wish to recreate it, delete the mask directory:\n\t%s\n',pwd);
        cd(odir)
        return
    else
        fprintf('Mask generation appears to have started, but did not complete...restarting.\n');
    end
end
cd(root);
fprintf('Removing old temporary masking directories...\n');
system('rm -rfv mask');
fprintf('Gathering files...\n');
mkdir('mask');
if ~exist('normalized','var')    
    normalized = 1;
    if ~iscell(adir('3danat/ws*.img'))
        normalized = 0;
        warning('It appears your data are unnormalized, generating unnormalized mask.');
    end
end

if normalized && ~iscell(adir('3danat/*seg*.mat'))
    terror('Cannot produce normalized mask because normalization warp does not exist.');
end

% obtain the functional image of reference.
bolds = adir('bold/*');bolds=bolds{1};
func = adir(fullfile(bolds,'f*.img'));func=func{1};
hdrs = adir(fullfile(bolds,'f*.hdr'));hdrs=hdrs{1};
copyfile(func,'mask');
copyfile(hdrs,'mask');
% copy anatomical images of reference
anat = adir('3danat/s0*.img');anat=anat{1};copyfile(anat,'mask');
hdrs = adir('3danat/s0*.hdr');hdrs=hdrs{1};copyfile(hdrs,'mask');
if normalized
    warp = adir('3danat/s*seg*mat');warp=warp{1};copyfile(warp,'mask');
end

cd mask;
defaults = spm_defaults_alek;

%%
func = spm_vol(char(adir('f*.img')));
%anat = spm_vol(char(adir('s0*.img')));
fprintf('Creating skull-stripped anatomical...\n');
system(sprintf('bet %s %s -R',char(adir('s0*.img')),fullfile(pwd,'anatomical_skull_stripped')));
system('gunzip *.nii.gz');
anat = spm_vol(fullfile(pwd,'anatomical_skull_stripped.nii'));
fprintf('Coregistering functional to anatomical.\n');
anon = @()spm_coreg(anat,func);
[a x] = evalc('anon()');
spm_print(fullfile(repo_dir,'coregistration_for_mask'));
anat = spm_vol(char(adir('s0*.img')));
M = inv(spm_matrix(x));
MM=spm_get_space(func.fname);
spm_get_space(func.fname,M*MM);
fprintf('Reslicing functional to anatomical.\n');
reslice_flags.which = 1;
reslice_flags.mean = 0;
spm_reslice({anat.fname;func.fname},reslice_flags)

%%
fprintf('Binarizing coregistered functional.\n');
x = spm_vol(char(adir('rf*.img')));
X = spm_read_vols(x);
X = X~=0;
x.fname = 'functional_binarized.img';
spm_write_vol(x,X);

%% 
fprintf('Validating labels...\n');
[tmp L] = bwlabeln(~X);
if L > 1
    warning('More than 1 zero-region present. You should check to mask to verify you do not have holes.');
end

%%
%fprintf('Creating skull-stripped anatomical...\n');
%system(sprintf('bet %s %s -R -m -f %0.01f',char(adir('s*.img')),fullfile(pwd,'anatomical_skull_stripped'),0.4));
%system('gunzip *.nii.gz');
fprintf('Binarizing skull-stripped anatomical...\n');
V = spm_vol(fullfile(pwd,'anatomical_skull_stripped.nii'));
Vo = struct('fname',fullfile(pwd,'anatomical_skull_stripped.img'),'dim',[V(1).dim(1:3)],'dt',[spm_type('float32'), 1],'mat',V(1).mat,'descrip','spm - algebra','mask',1);
Vo = spm_imcalc(V,Vo,'i1>0');

%%
fprintf('Creating conjunction...\n');
Y = spm_read_vols(Vo);
new_mask = X&Y;
if normalized
    Vo.fname = 'anatomical_functional_conjunction.img';
    spm_write_vol(Vo,new_mask);
else
    Vo.fname = 'skull_strip_mask.img';
    Vo.descrip = 'Mask generated with younglab_genmask';
    cd ../3danat
    spm_write_vol(Vo,new_mask);
    cd(odir);
    return
end
% normalize the anatomical (which we've already done...)
% ...
%% 
fprintf('Applying warp to conjunction...\n');
p = load(char(adir('s*seg*mat')));
t = defaults.normalise.write;
t.prefix = 'normalized_';
t.interp = 0;
spm_write_sn('anatomical_functional_conjunction.img',p,t);
fprintf('Applying additional warps for QC...\n');
spm_write_sn('anatomical_skull_stripped.img',p,t);
spm_write_sn('functional_binarized.img',p,t);
spm_write_sn(char(adir('rf*.img')),p,t);
spm_write_sn(anat.fname,p,t);
%%
% let's also generate a mask produced out of the POST normalized
% conjunction!
fprintf('Creating skull-stripped (normalized) anatomical...\n');
system(sprintf('bet %s %s -R -m',char(adir('normalized_s*.img')),fullfile(pwd,'anatomical_normalized_skull_stripped')));
system('gunzip *.nii.gz');
fprintf('Binarizing skull-stripped normalized anatomical...\n');
V = spm_vol(fullfile(pwd,'anatomical_normalized_skull_stripped.nii'));
Vo = struct('fname',fullfile(pwd,'anatomical_normalized_skull_stripped.img'),'dim',[V(1).dim(1:3)],'dt',[spm_type('float32'), 1],'mat',V(1).mat,'descrip','spm - algebra','mask',1);
Vo = spm_imcalc(V,Vo,'i1>0');
%%
fprintf('Creating post-normalization conjunction...\n');
ANA = spm_read_vols(Vo);
FUN = spm_read_vols(spm_vol('normalized_functional_binarized.img'));
post_norm_conj = ANA&FUN;
Vo.fname = 'post_normalization_conjunction.img';
spm_write_vol(Vo,post_norm_conj);

%%
fprintf('Relocating mask.\n');
x = spm_vol('post_normalization_conjunction.img');
X = spm_read_vols(x);
x.descrip = 'Mask generated with younglab_genmask';
x.fname = 'skull_strip_mask.img';
cd ../3danat
spm_write_vol(x,X);
white_matter = adir(fullfile(root,'3danat','c2s*.img'));
grey_matter = adir(fullfile(root,'3danat','c1s*.img'));
fprintf('Applying warps to segmentation (grey matter)\n');
gmx = spm_write_sn(char(grey_matter),p,t);
fprintf('Binarizing grey matter into a mask...\n')
gmX = spm_read_Vols(gmx);
prob_thresh = 0.8;                      % probability requirement for inclusion in the masks
gmX = gmX >= prob_thresh; 
delete(gmx.fname);
gmx.fname = 'grey_matter_mask.img';
spm_write_vol(gmx,gmX);
fprintf('Applying warps to segmentation (white matter)\n');
gmx = spm_write_sn(char(white_matter),p,t);
fprintf('Binarizing white matter into a mask...\n')
gmX = spm_read_Vols(gmx);
gmX = gmX >= prob_thresh; 
delete(gmx.fname);
gmx.fname = 'white_matter_mask.img';
spm_write_vol(gmx,gmX);
fprintf('Finishing up...\n');
cd ../mask
fopen('complete_without_errors','w');
fclose all;
cd(root);
%system('rm -rfv mask');
cd(odir);
end

function [result, char_results] = adir(search_str,full_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is an adaptation of MATLAB's 'dir' function ('advanced dir')
% that wraps the ls command and parses its output.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% search_str is the search string, i.e., a the pattern to match.
% full_file is a boolean, either 1 or 0 (or omitted); if 1, the
% function will return the full file + location.
%
%		e.g.,
%
%				results = adir('*/*YOU*')
%				results = adir('*YOU*',1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% results is a cell array of file/directory names. char_results is that
% same set of names but expressed as a char array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
command = ['ls -dm ' search_str];
[status,result] = system(command);
% exclude any letters that are *not* in the proper range, i.e., return
% characters, etc
if status~=0
    result = -1;
    char_results = -1;
    return
end
rnge = [double(' ')-1 double('~')+1];
result = result(double(result) > rnge(1) & double(result) < rnge(2));
% split by comma-spaces
result = regexp(result,', *','split');
if exist('full_file','var') && full_file
    % add in the full working directory
    result = cellfun(@(x) {fullfile(pwd,x)},result);
end
char_results = char(result);
end

function terror(text)
error(sprintf('\n==========================================\n%s\n==========================================\n',text));
end