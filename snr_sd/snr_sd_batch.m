function snr_sd_batch(varargin)
%snr_batch.m
%Simple script to batch snr_sd.m in order to calculate snr on
%multiple subjects.
%DDW.2007.05.19

spm_defaults_lily;

directory = pwd;
cd('/home/younglw/lab/');

%Uses spm_get to grab subjects

if nargin==0
  study = spm_select(1,'dir','Select study');
  study = regexprep(study,'/\w+/\w+/\w+/',''); study = spm_str_manip(study,'h');
  subj_temp = spm_select(Inf, 'dir', 'Select subjects for SNR calculation');
  for i=1:size(subj_temp,1)
    subj(i,:) = regexprep(subj_temp(i,:),'/\w+/\w+/\w+/\w+/',''); 
  end
  subj = spm_str_manip(subj,'h');
  
elseif nargin==1
  subj=varargin{1};
  
else
  msg1='You''ve specified too many inputs. Simply enter the subject directory name please. e.g. snr_sd(''YOU_SHAPES_01'')';
  error(msg1);
end

cd(directory);

for i = 1:size(subj,1)
  % snr(subj(i,:),para_file)
   snr_sd(study, deblank(subj(i,:)))
end

close all;
