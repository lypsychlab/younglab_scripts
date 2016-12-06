
function estimate_snpm_pleiades(fname)
% fname must be a file which contains a structure called 'parameters', with the following basic fields:
% - rootdir (a string)
% - study (a string)
% - subjects (a numeric array)
% - prefix (e.g. 'SAX_DIS')
% - tagnames (e.g. {'con_001' 'con_002'})
% - imagetype ('img' or 'nii')
% - resdir (e.g. 'DIS_results_normed')
% - imageprefix (for RSA and other analyses where each image name has a static prefix; otherwise, put '')
% - numiterations (5000 is default in SnPM)
% - sign (1 for positive effects)
% - voxthresh (FWE-corrected voxelwise threshold)
% - cluthresh (FWE-corrected clusterwise threshold)
% - threshtype (1 for voxelwise FWE; 2 for cluster-based FWE)

addpath(genpath('/usr/public/spm/spm12'));

load(fname);
rootdir=parameters.rootdir;
study=parameters.study;
tagnames=parameters.tagnames;

subjs={};
for thiss=1:length(parameters.subjects)
  subjs{end+1} = [parameters.prefix '_' sprintf('%02d',parameters.subjects(thiss))];
end



cd(fullfile(rootdir,study));
for t=1:length(parameters.tagnames)

  %SPECIFY:
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.dir = {[rootdir '/' study '/results/' tagnames{t} '/']};
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.P=cell(length(subjs),1);

    for thiss=1:length(subjs)
      if strcmp(parameters.imagetype, 'img')
        matlabbatch{1}.spm.tools.snpm.des.OneSampT.P{thiss} = [rootdir '/' study '/' subjs{thiss} '/results/' parameters.resdir '/' parameters.imageprefix tagnames{t} '.img,1'];
      else 
        matlabbatch{1}.spm.tools.snpm.des.OneSampT.P{thiss} = [rootdir '/' study '/' subjs{thiss} '/results/' parameters.resdir '/' parameters.imageprefix tagnames{t} '.nii,1'];
      end
    end

    matlabbatch{1}.spm.tools.snpm.des.OneSampT.cov = struct('c', {}, 'cname', {});
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.nPerm = parameters.numiterations;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.vFWHM = [0 0 0];
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.bVolm = 0;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.im = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.em = {''};
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalc.g_omit = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.glonorm = 1;

    if parameters.threshtype==1
      matlabbatch{1}.spm.tools.snpm.des.OneSampT.ST.ST_none = 0;
    else
      matlabbatch{1}.spm.tools.snpm.des.OneSampT.bVolm = 1;
      matlabbatch{1}.spm.tools.snpm.des.OneSampT.ST.ST_U=2.03;
    end

    output_list=spm_jobman('run',matlabbatch);


  %COMPUTE:
    clear matlabbatch;
    cd([rootdir '/' study '/results/' tagnames{t} '/']);
    matlabbatch{1}.spm.tools.snpm.cp.snpmcfg = {[rootdir '/' study '/results/' tagnames{t} '/SnPMcfg.mat']};
    output_list=spm_jobman('run',matlabbatch);

  %INFER:
    clear matlabbatch;
    cd([rootdir '/' study '/results/' tagnames{t} '/']);
    matlabbatch{1}.spm.tools.snpm.inference.SnPMmat = {[rootdir '/' study '/results/' tagnames{t} '/SnPM.mat']};

    if parameters.threshtype==1
      matlabbatch{1}.spm.tools.snpm.inference.Thr.Vox.VoxSig.FWEth = parameters.voxthresh;
    else if parameters.threshtype==2
      matlabbatch{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = NaN;
      matlabbatch{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = parameters.cluthresh;
    else
      disp(['Unrecognized thresholding type!']);
      break
    end

    matlabbatch{1}.spm.tools.snpm.inference.Tsign = parameters.sign;
    matlabbatch{1}.spm.tools.snpm.inference.WriteFiltImg.WF_no = 0;
    matlabbatch{1}.spm.tools.snpm.inference.Report = 'MIPtable';
    output_list=spm_jobman('run',matlabbatch);
    clear matlabbatch;



end %end tags loop
end %end function