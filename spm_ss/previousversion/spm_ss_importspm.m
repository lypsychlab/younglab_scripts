function [data,SPM,nspm]=spm_ss_importspm(data,SPMfile)

if isempty(data)||isfield(data,'SPMfiles')
    if isempty(data),nspm=1;isnew=1;
    else
        nspm=strmatch(SPMfile,data.SPMfiles,'exact');
        if isempty(nspm),nspm=numel(data.SPMfiles)+1;isnew=1; else isnew=0; end
    end
    % loads SPM.mat
    if isnew,
        load(SPMfile,'SPM');
        SPM.swd=fileparts(SPMfile);
        % updates struct
        data.SPMfiles{nspm}=SPMfile;
        data.SPM{nspm}=spm_ss_importspm_reduce(SPM,SPMfile);
    else
        SPM=data.SPM{nspm};
    end
else
    SPM=spm_ss_importspm_reduce(data,SPMfile);
    data=[];
    nspm=[];
end
end


function SPM2=spm_ss_importspm_reduce(SPM,SPMfile)
SPM2.swd=SPM.swd;
SPM2.xCon=SPM.xCon;
SPM2.xX=SPM.xX;
if isfield(SPM,'Sess'),SPM2.Sess=SPM.Sess; else SPM2.Sess=[];end
if isfield(SPM,'xVol'),SPM2.xVol=SPM.xVol; else SPM2.xVol=[];end
SPM2.spm_ss_SPMfile=SPMfile;
end
