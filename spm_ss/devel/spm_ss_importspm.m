function [data,SPM,nspm]=spm_ss_importspm(data,SPMfile,forceload)

if nargin<3,forceload=0;end
if isempty(data),nspm=1;isnew=1;
else
    nspm=strmatch(SPMfile,data.SPMfiles,'exact');
    if isempty(nspm),nspm=numel(data.SPMfiles)+1;isnew=1; else isnew=0; end
end
% loads SPM.mat
if isnew||forceload, 
    load(SPMfile,'SPM');
    SPM.swd=fileparts(SPMfile);
    % updates struct
    data.SPMfiles{nspm}=SPMfile;
    data.SPM{nspm}.swd=SPM.swd;
    data.SPM{nspm}.xCon=SPM.xCon;
    data.SPM{nspm}.xX=SPM.xX;
    if isfield(SPM,'Sess'),data.SPM{nspm}.Sess=SPM.Sess; else data.SPM{nspm}.Sess=[];end
    if isfield(SPM,'xVol'),data.SPM{nspm}.xVol=SPM.xVol; else data.SPM{nspm}.xVol=[];end
    data.SPM{nspm}.spm_ss_SPMfile=SPMfile;
else
    SPM=data.SPM{nspm};
end

