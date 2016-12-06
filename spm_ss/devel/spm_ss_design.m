function ss=spm_ss_design(ss)
% SPM_SS_DESIGN gui defining a multi-subject analysis 
% ss=spm_ss_design;     Defines a new analysis entirely from the gui
% ss=spm_ss_design(ss); Defines a new analysis with the gui asking only those aspects of the design that have not been specified
%
% Fields of ss structure:
%
% ss.swd                Directory for output analysis files
% ss.type               Type of subject-specific analysis ('voxel': voxel-based; 'GcSS': ROI-based (automatically-defined); 'mROI': ROI-based (manually-defined)) 
% ss.n                  Number of subjects
% (when selecting by contrast names; default)
%    ss.files_spm                    cell array of SPM.mat files (one per subject; ss.files_spm{nsubject} is a string pointing to a 1st-level SPM.mat file); alternatively you can use the fields: ss.EffectOfInterest_spm and ss.Localizer_spm if the effect of interest and localizer contrasts have been defined in different SPM.mat files (for the same subjects). In addition, in the case of multiple localizer contrasts (conjunction) or multiple effect of interest contrasts resulting from different experiments ss.Localizer_spm{nconjunction,nsubject} and EffectOfInterest_spm{neffect,nsubject} can be used to point to each contrast-specific subject-specific SPM.mat file.
%    ss.EffectOfInterest_contrasts   cell array of Effects-of-interest contrast names (ss.EffectOfInterest_contrasts{neffect} is a char array containing one or several 1st-level contrast name(s); for manual cross-validation use ss.EffectOfInterest_contrasts{ncrossvalid,neffect} and the toobox will perform cross-validation across these partitions) 
%    ss.Localizer_contrasts          cell array of localizer contrast names (ss.Localizer_contrast{nconjunction} is a char array containing one or several 1st-level contrast names (multiple localizers will perform a conjunction of the individual localizer contrasts; use the prefix -not before a valid contrast name to use exclusive conjunction); for manual cross-validation use ss.Localizer_contrast{ncrossvalid,nconjunction} and the toobox will perform cross-validation across these partitions)
%      note: (automatic cross-validation) the toolbox will automatically check the orthogonality between the Localizer and effects of interest contrasts. If these are found not to be orthogonal the toolbox will create and estimate new (now orthogonal) contrasts by partitioning the selected contrasts across sessions
%    ss.Localizer_thr_p              vector of false positive thresholds for each first-level localizer mask (default .05) note:if ss.Localizer_thr_type='automatic' the optimal FDR-corrected threshold level (maximizing the expected results sensitivity) is used (and this field is disregarded)   
%    ss.Localizer_thr_type           cell array of multiple comparisons correction types for each first-level localizer mask ('FDR','FWE','none','automatic') (default 'FDR')
% (when selecting by contrast files; i.e. ss.files_selectmanually=1)
%    ss.EffectOfInterest   cell array of Effects-of-interest contrast names (ss.EffectOfInterest{nsubject}{neffect,ncrossvalid} is a char array containing a con*.img contrast file)  
%    ss.Localizer          cell array of mask files (ss.Localizer{nsubject}{ncrossvalid} is a char array pointing to a mask *.img file, NOTE: that the contrasts ss.Localizer{nsubject}{i} and ss.Localizer{nsubject}{j} should be mutually orthogonal for all i and j -forming a partition- and also ss.Localizer{nsubject}{i} should be orthogonal to ss.EffectOfInterest{nsubject}{i} for all i)
% ss.ExplicitMasking    explicit mask file name (only voxels where the mask takes values above 0 will be considered in any analysis; default [])
% ss.ManualROIs         (for ss.type=='mROI') manually-defined ROI file name (ROI image should contain integer numbers, from 1 to m, where m is the number of ROIs)
% ss.smooth             (for ss.type=='voxel' or ss.type=='GcSS') Smoothing kernel (FWHM mm) (note: for automatically-defined ROIs this amount of smoothing is applied to the overlap map before applying a watershed partitioning; for voxel-based analyses this amount of smoothing determines the smoothing-equivalent kernel h)
% ss.overlap_thr        (for ss.type=='GcSS') voxel-level minimal proportion of subjects overlap when constructing ROI parcellation (default .10) 
% ss.model              Between-subjects model type (1: one-sample t-test; 2: two-sample t-test; 3: multiple regression) (note: this field is disregarded if the design matrix ss.X below is directly defined) 
% ss.estimation         Between-subjects model estimation type ('ReML','OLS') (Restricted Maximum Likelihood estimation vs. Ordinary Least Squares estimation; default 'ReML')
% ss.X                  Between-subjects design matrix [nsubjects,nregressors]
% ss.Xname              Cell array of Between-subjects regressor names [nregressors]
% ss.C                  Array of structures containing contrast information
% ss.C(k).between       Between-subjects contrast(s) vector/matrix [m,nregressors]
% ss.C(k).within        Within-subjects contrast(s) vector/matrix [n,neffects]
% ss.C(k).name          Contrast name 
% ss.ask                gui interaction level: 'none' (any missing information is assumed to take default values), 'missing' (any missing information will be asked to the user), 'all' (it will ask for confirmation on each parameter)
% 

initestimation=0;
posstr=1;
if nargin<1, 
    ss=[]; 
    if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
    str='Specify a new model?';
    disp(str);
    newmodel=spm_input(str,posstr,'m','Specify a new model|Modify an existing model',[1,2], 1);posstr='+1';
    initestimation=1;
    if newmodel==2,
        str={'Warning!: Modifying a model removes any estimated model parameters on the new model',...
            'Select a different output folder if you do not want to loose any currently estimated model parameters',...
            'Are you sure you want to continue?'};
        if spm_input(str,posstr,'bd','stop|continue',[1,0],1),return;end;posstr='+1';
        str='Select spm_ss*.mat analysis file';
        disp(str);
        Pdefault='';objname=findobj('tag','spm_ss');if numel(objname)==1,objdata=get(objname,'userdata');if isfield(objdata,'files_spm_ss'),Pdefault=objdata.files_spm_ss;end;end;
        P=spm_select(1,'^SPM_ss.*\.mat$',str,{Pdefault});
        if numel(objname)==1&&~isempty(P),objdata.files_spm_ss=P;set(objname,'userdata',objdata);end;
        load(P);
        ss.swd=fileparts(P);
        ss.ask='all';
    end
end
if ~isfield(ss,'files_selectmanually')||isempty(ss.files_selectmanually), ss.files_selectmanually=0;end
if ~isfield(ss,'ask')||isempty(ss.ask), 
    ss.ask='missing'; ss.askn=1;
else
    types={'none','missing','all'};typesn=[0,1,2];
    if isnumeric(ss.ask), sstype=ss.ask;
    else sstype=strmatch(lower(ss.ask),lower(types),'exact'); end
    ss.ask=types{sstype};
    ss.askn=typesn(sstype);
end

if ss.askn>1||~isfield(ss,'type')||isempty(ss.type), 
    types={'voxel','GcSS','automaticROI','aROI','manualROI','mROI','fROI','ROI'};typesn=[1,2,2,2,3,3,2,2];
    if ~isfield(ss,'type')||isempty(ss.type), sstype=2; else sstype=typesn(strmatch(lower(ss.type),lower(types),'exact')); end
    if ss.askn,
        if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
        str='Type of subject-specific analysis?';
        disp(str);
        sstype=spm_input(str,posstr,'m','Voxel-based|ROI-based (automatically-defined)|ROI-based (manually-defined)',[1,2,3], sstype); posstr='+1';
    end
    ss.type=types{sstype};
    ss.typen=typesn(sstype);
else 
    types={'voxel','GcSS','automaticROI','aROI','manualROI','mROI','fROI','ROI'};typesn=[1,2,2,2,3,3,2,2];
    if isnumeric(ss.type), sstype=ss.type;
    else sstype=strmatch(lower(ss.type),lower(types),'exact'); end
    ss.type=types{sstype};
    ss.typen=typesn(sstype);
end

if ss.askn>1||~isfield(ss,'swd')||isempty(ss.swd), 
    if ~isfield(ss,'swd')||isempty(ss.swd), ss.swd=''; end
    if ss.askn,ss.swd=spm_select(1,'Dir','Select directory for output analysis files',{ss.swd}); end
%     dirnotempty=~isempty(dir(fullfile(ss.swd,'SPM_ss.mat')));
%     if dirnotempty,
%         str={'Current directory contains SPM_ss estimation files:',...
%             'pwd = ',ss.swd,...
%             'Existing files will be deleted!'};
%         if spm_input(str,posstr,'bd','stop|continue',[1,0],1),return;end;posstr='+1';
%         files={'^beta_.{2}\..{3}$','^con_.{2}\..{3}$','^spm\w{1}_.{2}\..{3}$','^dof_.{2}\..{3}$'};
%         for i=1:length(files)
%             j = spm_select('List',ss.swd,files{i});
%             for k=1:size(j,1),spm_unlink(deblank(j(k,:)));end
%         end
%     end
else
    if ~isdir(ss.swd),
        [swdp,swdn,swde]=fileparts(ss.swd);
        [ok,nill]=mkdir(swdp,[swdn,swde]);
    end
end


if ~ss.files_selectmanually,
    if isfield(ss,'files_spm')&&~isempty(ss.files_spm)&&(~isfield(ss,'EffectOfInterest_spm')||isempty(ss.EffectOfInterest_spm)||~isfield(ss,'Localizer_spm')||isempty(ss.Localizer_spm)),% batch files_spm use
        ss.EffectOfInterest_spm=ss.files_spm;
        ss.Localizer_spm=ss.files_spm;
    end
    if ss.askn>1||~isfield(ss,'EffectOfInterest_spm')||isempty(ss.EffectOfInterest_spm),
        if ~isfield(ss,'EffectOfInterest_spm')||isempty(ss.EffectOfInterest_spm), ss.EffectOfInterest_spm={}; end
        str='Select first-level SPM.mat(s) (one per subject, containing EFFECTS OF INTEREST contrasts) - or hit cancel if you prefer to select contrast files manually';
        disp(str);
        Pdefault={''};objname=findobj('tag','spm_ss');if numel(objname)==1,objdata=get(objname,'userdata');if isfield(objdata,'files_spm'),Pdefault=objdata.files_spm;end;end;
        if ~isempty(ss.EffectOfInterest_spm),Pdefault=ss.EffectOfInterest_spm;end
        if ss.askn,P=cellstr(spm_select(inf,'^SPM\.mat$',str,Pdefault))';else P=Pdefault; end
        if numel(objname)==1&&~isempty(P)&&~isempty(P{1}),objdata.files_spm=P;set(objname,'userdata',objdata);end;
        if isempty(P)||isempty(P{1}), ss.files_selectmanually=1; 
        else
            if numel(ss.EffectOfInterest_spm)~=numel(P), ss.Localizer={}; ss.EffectOfInterest={}; ss.n=numel(P); else for n1=1:numel(ss.EffectOfInterest_spm), if ~strcmp(ss.EffectOfInterest_spm{n1},P{n1}), ss.Localizer={}; ss.EffectOfInterest={}; ss.n=numel(P); end; end; end
            ss.EffectOfInterest_spm=P; 
            %ss.n=numel(P); 
            ss.files_selectmanually=0; 
            if ~isfield(ss,'Localizer_spm')||isempty(ss.Localizer_spm),
                ss.Localizer_spm=ss.EffectOfInterest_spm; % (exception; when using gui first time assume same Localizer/EffectOfInterest SPM.mat files)
            end
        end
    end
    if ss.askn>1||~isfield(ss,'Localizer_spm')||isempty(ss.Localizer_spm),
        if ~isfield(ss,'Localizer_spm')||isempty(ss.Localizer_spm), ss.Localizer_spm={}; end
        str='Select first-level SPM.mat(s) (one per subject, containing LOCALIZER contrasts) - or hit cancel if you prefer to select mask files manually';
        disp(str);
        Pdefault={''};objname=findobj('tag','spm_ss');if numel(objname)==1,objdata=get(objname,'userdata');if isfield(objdata,'files_spm'),Pdefault=objdata.files_spm;end;end;
        if ~isempty(ss.Localizer_spm),Pdefault=ss.Localizer_spm;end
        if ss.askn,P=cellstr(spm_select(inf,'^SPM\.mat$',str,Pdefault));else P=Pdefault; end
        if numel(objname)==1&&~isempty(P)&&~isempty(P{1}),objdata.files_spm=P;set(objname,'userdata',objdata);end;
        if isempty(P)||isempty(P{1}), ss.files_selectmanually=1; 
        else
            if numel(ss.Localizer_spm)~=numel(P), ss.Localizer={}; ss.EffectOfInterest={}; ss.n=numel(P); else for n1=1:numel(ss.Localizer_spm), if ~strcmp(ss.Localizer_spm{n1},P{n1}), ss.Localizer={}; ss.EffectOfInterest={}; ss.n=numel(P); end; end; end
            ss.Localizer_spm=P; 
            %ss.n=numel(P); 
            ss.files_selectmanually=0; 
        end
    end
end
if ~ss.files_selectmanually&&isfield(ss,'n')&&~isempty(ss.n),
    if ~rem(numel(ss.Localizer_spm),ss.n),ss.Localizer_spm=reshape(ss.Localizer_spm,numel(ss.Localizer_spm)/ss.n,ss.n);end
    if ~rem(numel(ss.EffectOfInterest_spm),ss.n),ss.EffectOfInterest_spm=reshape(ss.EffectOfInterest_spm,numel(ss.EffectOfInterest_spm)/ss.n,ss.n);end
end
if ~ss.files_selectmanually,%&&(~isfield(ss,'n')||isempty(ss.n)),
    if size(ss.EffectOfInterest_spm,2)~=size(ss.Localizer_spm,2), error('Number of SPM.mat files must match in EffectOfInterest_spm and Localizer_spm (one pair of SPM.mat files per subject)'); end
    ss.n=size(ss.Localizer_spm,2); 
end

if ss.files_selectmanually,
    if ss.askn>1||~isfield(ss,'n')||isempty(ss.n), 
        if ~isfield(ss,'n')||isempty(ss.n), ss.n=[]; end
        if ss.askn, 
            if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
            str='Number of subjects?';
            disp(str);
            ss.n=spm_input(str,posstr,'n',ss.n,1);posstr='+1'; 
        end
    end
end

if ss.askn>1||~isfield(ss,'EffectOfInterest')||isempty(ss.EffectOfInterest),
    if ~isfield(ss,'EffectOfInterest')||isempty(ss.EffectOfInterest),ss.EffectOfInterest={};end
    if ss.files_selectmanually,
        for np=1:ss.n,
            if numel(ss.EffectOfInterest)<np,ss.EffectOfInterest{np}={''};end
            str=['Select EFFECT OF INTEREST contrast volumes for subject #',num2str(np),'(one or several contrast files)'];
            disp(str);
            ss.EffectOfInterest{np}=cellstr(spm_select(inf,'image',str,ss.EffectOfInterest{np}));
        end
    else
        if ~isfield(ss,'EffectOfInterest_contrasts')||isempty(ss.EffectOfInterest_contrasts),ss.EffectOfInterest_contrasts={};end
        nnc=size(ss.EffectOfInterest_spm,1);
        if nnc>1,
            %ss.EffectOfInterest_contrasts={};
            spm_data=[];Ec=[];
            for nc=1:nnc,
                current_spm=ss.EffectOfInterest_spm{min(size(ss.EffectOfInterest_spm,1),nc),1};
                [spm_data,SPM,Ec(nc)]=spm_ss_importspm(spm_data,current_spm);
%                 load(ss.EffectOfInterest_spm{nc,1},'SPM');
%                 SPM.swd=fileparts(ss.EffectOfInterest_spm{nc});
                Cnames={SPM.xCon(:).name};
                ic=[];ok=1;for n1=nc:min(nc,length(ss.EffectOfInterest_contrasts)),temp=strmatch(ss.EffectOfInterest_contrasts{n1},Cnames,'exact');if numel(temp)~=1,ok=0;break;else ic=temp;end;end
                if ss.askn>1||isempty(ic),
                    str=['Select EFFECT OF INTEREST contrast #',num2str(nc)];
                    disp(str);
                    Ic=listdlg('promptstring',str,'selectionmode','single','liststring',Cnames,'initialvalue',ic); %Ic=spm_conman(SPM,'T|F',inf,str,'',0);
                else
                    Ic=ic;
                end
                if numel(ic)~=numel(Ic) || any(ic(:)~=Ic(:)), ss.EffectOfInterest={}; end
                ss.EffectOfInterest_contrasts{nc}=Cnames{Ic}; % note: the gui does not allow to manually cross-validate when using this option (i.e. multiple contrasts are interpreted as multiple effects of interest contrasts, not as multiple 'sessions'), use batch scripts instead
            end
        else
            load(ss.EffectOfInterest_spm{1},'SPM');
            SPM.swd=fileparts(ss.EffectOfInterest_spm{1});
            Cnames={SPM.xCon(:).name};
            ic=[];ok=1;for n1=1:length(ss.EffectOfInterest_contrasts),temp=strmatch(ss.EffectOfInterest_contrasts{n1},Cnames,'exact');if numel(temp)~=1,ok=0;break;else ic(n1)=temp;end;end
            if ss.askn>1||isempty(ic),
                str='Select EFFECT OF INTEREST contrasts';
                disp(str);
                Ic=listdlg('promptstring',str,'selectionmode','multiple','liststring',Cnames,'initialvalue',ic); %Ic=spm_conman(SPM,'T|F',inf,str,'',0);
            else
                Ic=ic;
            end
            ss.EffectOfInterest_contrasts={Cnames{Ic}}; % note: the gui does not allow to manually cross-validate when using this option (i.e. multiple contrasts are interpreted as multiple effects of interest contrasts, not as multiple 'sessions'), use batch scripts instead
            if numel(ic)~=numel(Ic) || any(ic(:)~=Ic(:)), ss.EffectOfInterest={}; end
        end
    end
end
if ss.files_selectmanually&&(ss.askn>1||~isfield(ss,'EffectOfInterest_contrasts')||isempty(ss.EffectOfInterest_contrasts)),
    for nc=1:numel(ss.EffectOfInterest{1}),
        if numel(ss.EffectOfInterest_contrasts)<nc,ss.EffectOfInterest_contrasts{nc}=['Effect #',num2str(nc)];end
        if ss.askn,
            if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
            str=['Effect #',num2str(nc),'name?'];
            disp(str);
            ss.EffectOfInterest_contrasts{nc}=spm_input(str,posstr,'s',ss.EffectOfInterest_contrasts{nc});posstr='+1';
        end
    end
end

if ss.askn>1||~isfield(ss,'Localizer')||isempty(ss.Localizer),
    if ~isfield(ss,'Localizer')||isempty(ss.Localizer),ss.Localizer={};end
    if ss.files_selectmanually,
        for np=1:ss.n,
            if numel(ss.Localizer)<np,ss.Localizer{np}={''};end
            str=['Select LOCALIZER mask volumes for subject #',num2str(np),'(one mask file, or multiple mask files if using crossvalidation)'];
            disp(str);
            ss.Localizer{np}=cellstr(spm_select(numel(ss.EffectOfInterest{np}),'image',str,ss.Localizer{np}));
        end
    else
        if ~isfield(ss,'Localizer_contrasts')||isempty(ss.Localizer_contrasts),ss.Localizer_contrasts={};end
        nnc=size(ss.Localizer_spm,1);
        if nnc>1,
            %ss.Localizer_contrasts={};
            spm_data=[];Ec=[];
            for nc=1:nnc,
                current_spm=ss.Localizer_spm{min(size(ss.Localizer_spm,1),nc),1};
                [spm_data,SPM,Ec(nc)]=spm_ss_importspm(spm_data,current_spm);
%                 load(ss.Localizer_spm{nc},'SPM');
%                 SPM.swd=fileparts(ss.Localizer_spm{nc});
                Cnames={SPM.xCon(:).name};
                ic=[];for n1=nc:min(nc,length(ss.Localizer_contrasts)),temp=strmatch(ss.Localizer_contrasts{n1},Cnames,'exact');if numel(temp)~=1&&~isempty(strmatch('-not',ss.Localizer_contrasts{n1})),temp=-strmatch(ss.Localizer_contrasts{n1}(5:end),Cnames,'exact');end;if numel(temp)~=1,break;else ic=temp;end;end
                if ss.askn>1||isempty(ic),
                    str=['Select LOCALIZER contrast #',num2str(nc)];
                    disp(str);
                    Ic=listdlg('promptstring',str,'selectionmode','single','liststring',Cnames,'initialvalue',ic); %Ic=spm_conman(SPM,'T|F',inf,str,'',0);
                    str='Conjunction: Inclusive (1) or exclusive (0) for this contrast?';
                    disp(str);
                    disp(char({Cnames{Ic}}));
                    signIc=spm_input(str,posstr,'r',num2str(sign(ic(:)')>0),[1,numel(Ic)],[0,1]);posstr='+1';
                    Ic(signIc<.5)=-Ic(signIc<.5);
                else
                    Ic=ic;
                end
                if numel(ic)~=numel(Ic) || any(ic(:)~=Ic(:)), ss.Localizer={}; end
                ss.Localizer_contrasts{nc}=Cnames{abs(Ic)}; % note: the gui does not allow to manually cross-validate when using this option (i.e. multiple contrasts are interpreted as multiple effects of interest contrasts, not as multiple 'sessions'), use batch scripts instead
            end
        else
            load(ss.Localizer_spm{1},'SPM');
            SPM.swd=fileparts(ss.Localizer_spm{1});
            Cnames={SPM.xCon(:).name};
            ic=[];for n1=1:length(ss.Localizer_contrasts),temp=strmatch(ss.Localizer_contrasts{n1},Cnames,'exact');if numel(temp)~=1&&~isempty(strmatch('-not',ss.Localizer_contrasts{n1})),temp=-strmatch(ss.Localizer_contrasts{n1}(5:end),Cnames,'exact');end;if numel(temp)~=1,break;else ic(n1)=temp;end;end
            if ss.askn>1||isempty(ic),
                str='Select LOCALIZER contrast(s)';
                disp(str);
                Ic=listdlg('promptstring',str,'selectionmode','multiple','liststring',Cnames,'initialvalue',abs(ic)); %Ic=spm_conman(SPM,'T|F',inf,str,'',0);
                if numel(Ic)>1,
                    str='Conjunction: Inclusive (1) or exclusive (0) mask for each contrast?';
                    disp(str);
                    disp(char({Cnames{Ic}}));
                    signIc=spm_input(str,posstr,'r',num2str(sign(ic(:)')>0),[1,numel(Ic)],[0,1]);posstr='+1';
                    Ic(signIc<.5)=-Ic(signIc<.5);
                end
            else Ic=ic; end
            ss.Localizer_contrasts={Cnames{abs(Ic)}}; % note: the gui does not allow to manually cross-validate when using this option (i.e. multiple contrasts are interpreted as a conjunction of the selected localizer contrasts, not as multiple 'sessions'), use batch scripts instead
            for n1=1:numel(Ic),if sign(Ic(n1))<0, ss.Localizer_contrasts{n1}=['-not',ss.Localizer_contrasts{n1}];end;end %adds -not prefix to exclusive contrasts
            if numel(ic)~=numel(Ic) || any(ic(:)~=Ic(:)), ss.Localizer={}; end
        end
    end
end

if isfield(ss,'Localizer_thr_type')&&ischar(ss.Localizer_thr_type),ss.Localizer_thr_type=cellstr(ss.Localizer_thr_type);end
if ~ss.files_selectmanually&&(ss.askn>1||~isfield(ss,'Localizer_thr_type')||numel(ss.Localizer_thr_type)<size(ss.Localizer_contrasts,2)||~isfield(ss,'Localizer_thr_p')||numel(ss.Localizer_thr_p)<size(ss.Localizer_contrasts,2)),
    if ~isfield(ss,'Localizer_thr_type')||isempty(ss.Localizer_thr_type), ss.Localizer_thr_type=repmat({'FDR'},[1,size(ss.Localizer_contrasts,2)]); end
    if numel(ss.Localizer_thr_type)~=size(ss.Localizer_contrasts,2), ss.Localizer_thr_type={ss.Localizer_thr_type{min(numel(ss.Localizer_thr_type),1:size(ss.Localizer_contrasts,2))}}; end
    if ~isfield(ss,'Localizer_thr_p')||isempty(ss.Localizer_thr_p),
        ss.Localizer_thr_p=[];for n1=1:numel(ss.Localizer_thr_type), if strcmpi(ss.Localizer_thr_type{n1},'none'),ss.Localizer_thr_p(n1)=.001;elseif strcmpi(ss.Localizer_thr_type{n1},'automatic'), ss.Localizer_thr_p(n1)=nan; else ss.Localizer_thr_p(n1)=.05;end; end
    end
    if numel(ss.Localizer_thr_p)~=size(ss.Localizer_contrasts,2), ss.Localizer_thr_p=ss.Localizer_thr_p(min(numel(ss.Localizer_thr_p),1:size(ss.Localizer_contrasts,2))); end
    if ss.askn,
        if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
        sstype1={};sstype2=[];
        for n1=1:size(ss.Localizer_contrasts,2)
            types={'FDR','FWE','none','automatic'};
            sstype=strmatch(lower(ss.Localizer_thr_type{n1}),lower(types),'exact');
            str=['Contrast #',num2str(n1),' localizer p value adjustment to control? (',ss.Localizer_contrasts{n1},')'];
            disp(str);
            sstype1{n1}=types{spm_input(str,posstr,'m','FDR|FWE|none|automatic',[],sstype)};posstr='+1';
            if strcmpi(sstype1{n1},'automatic'), sstype2(n1)=nan;
            else
                str=['Contrast #',num2str(n1),' localizer p value threshold? (',ss.Localizer_contrasts{n1},')'];
                disp(str);
                sstype2(n1)=spm_input(str,posstr,'r',ss.Localizer_thr_p(n1)); posstr='+1';
            end
        end
        if numel(ss.Localizer_thr_type)~=numel(sstype1), ss.Localizer={}; else for n1=1:numel(ss.Localizer_thr_type),if ~strcmpi(ss.Localizer_thr_type{n1},sstype1{n1}), ss.Localizer={}; end; end; end
        if any(ss.Localizer_thr_p~=sstype2), ss.Localizer={}; end
        ss.Localizer_thr_type=sstype1;
        ss.Localizer_thr_p=sstype2;
    end
end

if (ss.typen==2) && (ss.askn>1||~isfield(ss,'overlap_thr')||isempty(ss.overlap_thr)), 
    if ~isfield(ss,'overlap_thr')||isempty(ss.overlap_thr), ss.overlap_thr=.10; end
    if ss.askn,
        if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
        str='Minimal overlap (% subjects) for automatic parcellation?';
        disp(str);
        ss.overlap_thr=spm_input(str,posstr,'r',ss.overlap_thr,1); posstr='+1';
    end
end

if ss.askn>1||~isfield(ss,'ExplicitMasking'),
    if ~isfield(ss,'ExplicitMasking')||isempty(ss.ExplicitMasking), ss.ExplicitMasking=''; end
    str='Explicit masking?';
    disp(str);
    sstype=spm_input(str,posstr,'b','none|select',[1,2],1+~isempty(ss.ExplicitMasking));posstr='+1';
    if sstype==1,ss.ExplicitMasking='';
    else
        str='Select mask file';
        disp(str);
        ss.ExplicitMasking=spm_select([0,1],'image',str,{ss.ExplicitMasking});
    end
end

if ss.typen==3 && (ss.askn>1||~isfield(ss,'ManualROIs')||isempty(ss.ManualROIs)),
    if ~isfield(ss,'ManualROIs')||isempty(ss.ManualROIs), ss.ManualROIs=''; end
    str='Select ROI file (ROIs are labeled as integer numbers within this volume)';
    disp(str);
    ss.ManualROIs=spm_select(1,'image',str,{ss.ManualROIs});
end

if (ss.typen==1  || ss.typen==2 ) && (ss.askn>1||~isfield(ss,'smooth')||isempty(ss.smooth)), 
    if ~isfield(ss,'smooth')||isempty(ss.smooth), ss.smooth=8; end
    if ss.askn,
        if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
        str='Smoothing factor (mm FWHM)?';
        disp(str);
        ss.smooth=spm_input(str,posstr,'r',ss.smooth,1); posstr='+1';
    end
end

if ss.askn>1||~isfield(ss,'model')||isempty(ss.model), 
    if ~isfield(ss,'model')||isempty(ss.model), ss.model=1; end
    if ss.askn,
        if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
        str='Select model';
        disp(str);
        ss.model=spm_input(str,posstr,'m','one-sample t-test|two-sample t-test|multiple regression',[],ss.model);posstr='+1';
    end
end

if ss.askn>1||~isfield(ss,'estimation')||isempty(ss.estimation), 
    if ~isfield(ss,'estimation')||isempty(ss.estimation), ss.estimation='ReML'; end
    if ss.askn,
        if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
        opt={'ReML','OLS'};
        str='Select model estimation type';
        disp(str);
        ss.estimation=spm_input(str,posstr,'m','Restricted Maximum Likelihood|Ordinary Least squares',opt,strmatch(ss.estimation,opt,'exact'));posstr='+1';
    end
end

if ss.askn>1||~isfield(ss,'X')||isempty(ss.X),
    switch(ss.model),
        case 1,
            ss.X=ones(ss.n,1);
            default_xname={'Group'};
            default_cLcontrast={1};default_cname={'Group'};
        case 2,
           if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
           if ~isfield(ss,'X')||isempty(ss.X), ss.X=[]; end
            done=0;
            idx1=find(ss.X(:,1));
            while ~done,
                str='Subjects in group 1?';disp(str);
                idx1=spm_input(str,posstr,'n',mat2str(idx1(:)'),[1,inf],ss.n);posstr='+1';
                str='Subjects in group 2?';disp(str);
                idx2=spm_input(str,posstr,'n',mat2str(setdiff(1:ss.n,idx1(:)')),[1,inf],ss.n);posstr='+1';
                if numel(idx1)+numel(idx2)==ss.n&&isempty(intersect(idx1,idx2)),done=1;end
            end
            ss.X=zeros(ss.n,2);ss.X(idx1,1)=1;ss.X(idx2,2)=1;
            default_xname={'Group 1','Group 2'};
            default_cLcontrast={};
        case 3,
            if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
            if ~isfield(ss,'X')||isempty(ss.X), ss.X=[]; end
            str='Regressor matrix?';
            disp(str);
            ss.X=spm_input(str,posstr,'r',mat2str(ss.X),[ss.n,inf]);posstr='+1';
            default_xname=cellstr([repmat('Regressor #',[size(ss.X,2),1]),num2str((1:size(ss.X,2))')]);
            default_cLcontrast={};
        otherwise,
            default_xname={};
            default_cLcontrast={};
    end
    if ~isfield(ss,'Xname')||numel(ss.Xname)~=size(ss.X,2), ss.Xname=default_xname; end
else
    default_xname=repmat({'regressor-name'},[size(ss.X,2),1]);
    default_cLcontrast={};
end

if ss.askn>1||~isfield(ss,'Xname')||numel(ss.Xname)~=size(ss.X,2), 
    if ~isfield(ss,'Xname')||numel(ss.Xname)~=size(ss.X,2), ss.Xname=default_xname; end
    for nc=1:size(ss.X,2),
        if numel(ss.Xname)<nc,ss.Xname{nc}=['Regressor #',num2str(nc)];end
        if ss.askn,
            if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
            str=['Regressor #',num2str(nc),' name?'];disp(str);
            ss.Xname{nc}=spm_input(str,posstr,'s',ss.Xname{nc});posstr='+1';
        end
    end
end

if ~isfield(ss,'C'), ss.C=repmat(struct('between',[],'within',[],'name',''),[1,0]); end 
if ~isempty(default_cLcontrast),
    nnc=1;
    neffects=size(ss.EffectOfInterest_contrasts,2);
    I=eye(neffects);
    for nc=1:numel(default_cLcontrast),
        for ne=1:neffects,
            ss.C(nnc)=struct('between',default_cLcontrast{nc},'within',I(ne,:),'name',[default_cname{nc},' (',ss.EffectOfInterest_contrasts{1,ne},')']);
            nnc=nnc+1;
        end
        ss.C(nnc)=struct('between',default_cLcontrast{nc},'within',I,'name',[default_cname{nc},' (',strcat(ss.EffectOfInterest_contrasts{1,:}),')']);
        nnc=nnc+1;
    end
end

% imports contrast files / orthogonalize if necessary
if ~ss.files_selectmanually&&(~isfield(ss,'Localizer')||isempty(ss.Localizer)||~isfield(ss,'EffectOfInterest')||isempty(ss.EffectOfInterest)),
    initestimation=1;
    okorth=1;
    ss.EffectOfInterest={};
    ss.Localizer={};
    disp('Importing contrast information from SPM.mat files. Please wait...');
    spm_ss_threshold('begin',ss.Localizer_thr_type,ss.Localizer_thr_p);
    for np=1:size(ss.EffectOfInterest_spm,2),%subjects
        spm_data=[];
        Ic1=[];Ec1=[];ok=1;
        for ncontrast=1:size(ss.EffectOfInterest_contrasts,2),%contrasts
            current_spm=ss.EffectOfInterest_spm{min(size(ss.EffectOfInterest_spm,1),ncontrast),np};
            [spm_data,SPM,Ec1(ncontrast)]=spm_ss_importspm(spm_data,current_spm);
            Cnames={SPM.xCon(:).name};
            for ncrossvalid=1:size(ss.EffectOfInterest_contrasts,1),%crossvalidation partitions
                temp=strmatch(ss.EffectOfInterest_contrasts{ncrossvalid,ncontrast},Cnames,'exact');if numel(temp)~=1,ok=0;break;else Ic1(ncrossvalid,ncontrast)=temp;end;
                if ~ok, error(['the target contrasts are not found inside ',current_spm]); end
            end
        end
        Ic2=[];Ec2=[];ok=1;
        for ncontrast=1:size(ss.Localizer_contrasts,2),%contrasts
            current_spm=ss.Localizer_spm{min(size(ss.Localizer_spm,1),ncontrast),np};
            [spm_data,SPM,Ec2(ncontrast)]=spm_ss_importspm(spm_data,current_spm);
            Cnames={SPM.xCon(:).name};
            for ncrossvalid=1:size(ss.Localizer_contrasts,1),%crossvalidation partitions
                temp=strmatch(ss.Localizer_contrasts{ncrossvalid,ncontrast},Cnames,'exact');if numel(temp)~=1,ok=0;break;else Ic2(ncrossvalid,ncontrast)=temp;end;
                if ~ok, error(['the target contrasts are not found inside ',current_spm]); end
            end
        end
                
%     nnc=[size(ss.EffectOfInterest_spm,1),size(ss.Localizer_spm,1)];
%         if nnc(1)==1,
%             load(ss.EffectOfInterest_spm{np},'SPM');
%             SPM.swd=fileparts(ss.EffectOfInterest_spm{np});
%             ss.EffectOfInterest_spm_data{1,np}=spm_ss_importspm(SPM);
%             Cnames={SPM.xCon(:).name};
%             % gets contrast indexes: Ic1 [ncross,neffects] & Ic2 [ncross,nconjunction]
%             Ic1=[];ok=1;for n1=1:numel(ss.EffectOfInterest_contrasts),temp=strmatch(ss.EffectOfInterest_contrasts{n1},Cnames,'exact');if numel(temp)~=1,ok=0;break;else Ic1(n1)=temp;end;end
%             if ~ok, error(['the target contrasts are not found inside ',ss.EffectOfInterest_spm{np}]); end
%             if ~strcmp(ss.Localizer_spm{np},ss.EffectOfInterest_spm{np}),
%                 load(ss.Localizer_spm{np},'SPM');
%                 SPM.swd=fileparts(ss.Localizer_spm{np});
%                 Cnames={SPM.xCon(:).name};
%             end
%             ss.Localizer_spm_data{1,np}=spm_ss_importspm(SPM);
%             Ic2=[];ok=1;for n1=1:size(ss.Localizer_contrasts,1),for n2=1:size(ss.Localizer_contrasts,2),temp=strmatch(ss.Localizer_contrasts{n1,n2},Cnames,'exact');if numel(temp)~=1&&~isempty(strmatch('-not',ss.Localizer_contrasts{n1,n2})),temp=-strmatch(ss.Localizer_contrasts{n1,n2}(5:end),Cnames,'exact');end;if numel(temp)~=1,ok=0;break;else Ic2(n1,n2)=temp;end;end;end
%             if ~ok, error(['the target contrasts are not found inside ',ss.Localizer_spm{np}]); end
%         else
%             Ic1=[];ok1=1;Ic2=[];ok2=1;
%             for nc=1:nnc(1),
%                 load(ss.EffectOfInterest_spm{nc,np},'SPM');
%                 SPM.swd=fileparts(ss.EffectOfInterest_spm{nc,np});
%                 ss.EffectOfInterest_spm_data{nc,np}=spm_ss_importspm(SPM);
%                 Cnames={SPM.xCon(:).name};
%                 % gets contrast indexes: Ic1 [ncross,neffects] & Ic2 [ncross,nconjunction]
%                 for n1=nc:min(nc,numel(ss.EffectOfInterest_contrasts)),temp=strmatch(ss.EffectOfInterest_contrasts{n1},Cnames,'exact');if numel(temp)~=1,ok1=0;break;else Ic1(n1)=temp;end;end
%                 if ~ok1, error(['the target contrasts are not found inside ',ss.EffectOfInterest_spm{np}]); end
%                 if ~strcmp(ss.Localizer_spm{nc,np},ss.EffectOfInterest_spm{nc,np}),
%                     load(ss.Localizer_spm{nc,np},'SPM');
%                     SPM.swd=fileparts(ss.Localizer_spm{np});
%                     Cnames={SPM.xCon(:).name};
%                 end
%                 ss.Localizer_spm_data{nc,np}=spm_ss_importspm(SPM);
%                 for n1=1:size(ss.Localizer_contrasts,1),for n2=1:size(ss.Localizer_contrasts,2),temp=strmatch(ss.Localizer_contrasts{n1,n2},Cnames,'exact');if numel(temp)~=1&&~isempty(strmatch('-not',ss.Localizer_contrasts{n1,n2})),temp=-strmatch(ss.Localizer_contrasts{n1,n2}(5:end),Cnames,'exact');end;if numel(temp)~=1,ok2=0;break;else Ic2(n1,n2)=temp;end;end;end
%                 if ~ok2, error(['the target contrasts are not found inside ',ss.Localizer_spm{np}]); end
%             end
%         end
%         Ic2=[];ok=1;for n1=1:size(ss.Localizer_contrasts,1),for n2=1:size(ss.Localizer_contrasts,2),temp=strmatch(ss.Localizer_contrasts{n1,n2},Cnames,'exact');if numel(temp)~=1&&~isempty(strmatch('-not',ss.Localizer_contrasts{n1,n2})),temp=-strmatch(ss.Localizer_contrasts{n1,n2}(5:end),Cnames,'exact');end;if numel(temp)~=1,ok=0;break;else Ic2(n1,n2)=temp;end;end;end
%         if ~ok, error(['the target contrasts are not found inside ',ss.Localizer_spm{np}]); end
        
        ncross=size(Ic2,1);
        nconjunction=size(Ic2,2);
%         if rem(numel(Ic1),ncross),
%             disp(['Subject #',num2str(np),'  : # localizer volumes ',num2str(numel(Ic2)), '  # effectofinterest volumes ',num2str(numel(Ic1))]);
%             error('The number of EFFECT OF INTEREST contrasts must be a multiple of the number of LOCALIZER contrasts for each subject');
%         end
%         neffects=numel(Ic1)/ncross;
%         Ic1=reshape(Ic1,[ncross,neffects]);
        neffects=size(Ic1,2);
        if size(Ic1,1)~=ncross, error('Mismatched number of partitions between LOCALIZER and EFFECT OF INTEREST contrasts'); end

        Inewc1={};Inewc2={};automaticcrossvalidation=0;
        % checks orthogonality & create contrasts/masks if necessary, separately for each experiment (SPM.mat file) involved
        for nexp=1:numel(spm_data.SPMfiles),
            iIc1=find(Ec1==nexp);iIc2=find(Ec2==nexp);
            Inewc1{nexp}=Ic1(:,iIc1);Inewc2{nexp}=Ic2(:,iIc2);
            if ~isempty(iIc1)&&~isempty(iIc2),        
                o=spm_SpUtil('ConO',spm_data.SPM{nexp}.xX.X,[spm_data.SPM{nexp}.xCon([Ic1(:,iIc1),abs(Ic2(:,iIc2))]).c]);
                o=permute(reshape(o(1:numel(iIc1),numel(iIc1)+1:end),[ncross,numel(iIc1),ncross,numel(iIc2)]),[2,4,1,3]);
                oo=o(:,:,1:ncross+1:ncross*ncross);
                if ~all(oo(:))&&okorth&&ncross>1,
                    str={'WARNING! You are choosing manual cross-validation, yet not all of the LOCALIZER and EFFECT OF INTEREST contrast pairs selected are orthogonal',...
                        ['pwd = ',ss.swd],...
                        'Are you sure you want to continue? (the results will likely be invalid)'};
                    fidx=find(~oo);[fneffects,fnconjunction,fncross]=ind2sub(size(oo),fidx);for n1=1:numel(fneffects),disp(['EFFECT OF INTEREST ',ss.EffectOfInterest_contrasts{(fneffects(n1)-1)*ncross+fncross(n1)},' not orthogonal to LOCALIZER ',ss.Localizer_contrasts{(fnconjunction(n1)-1)*ncross+fncross(n1)}]); end
                    disp(char(str));
                    if ss.askn,if spm_input(str,posstr,'bd','stop|continue',[1,0],0),return;end;posstr='+1';end
                    disp('...continuing anyway');
                    okorth=0;
                elseif ~all(oo(:)),
                    if okorth,
                        str={'LOCALIZER and EFFECT OF INTEREST contrast pairs are not orthogonal',...
                            ['pwd = ',ss.swd],...
                            'New contrasts (broken down by sessions) will be created now if they do not already exist'};
                        disp(char(str));
                        if ss.askn,if spm_input(str,posstr,'bd','stop|continue',[1,0],0),return;end;posstr='+1';end
                    end
                    [SPM,IcCV1,sess1]=spm_ss_crossvalidate_sessions(spm_data.SPM{nexp},Ic1(:,iIc1),0,'skip');
                    [SPM,IcCV2,sess2]=spm_ss_crossvalidate_sessions(SPM,abs(Ic2(:,iIc2)),0,'skip');
                    [nill,idxvalid1,idxvalid2]=intersect(sess1,sess2);
                    if isempty(nill), error(['Subject #',num2str(np),' (',spm_data.SPMfiles{nexp},') not possible to cross-validate.']);
                    else disp(['Subject ',num2str(np),' cross-validation across sessions ',num2str(nill(:)'),' in file ',spm_data.SPMfiles{nexp}]); end
                    Inewc1{nexp}=IcCV1(:,idxvalid1,1)';%Ic1=Ic1(:);
                    Inewc2{nexp}=(diag(sign(Ic2(:,iIc2)))*IcCV2(:,idxvalid2,2))';%Ic2=Ic2(:);
                    okorth=0;
                    automaticcrossvalidation=1;
%                     ncross=size(Ic2,1);
%                     nconjunction=size(Ic2,2);
%                     neffects=size(Ic1,2);
                end
            end
        end
        if automaticcrossvalidation,
            % combines new cross-validated contrasts (possibly across multiple experiments)
            ic1=Ic1;ic2=Ic2;
            nexps=numel(spm_data.SPMfiles);
            nexpcross=zeros(1,nexps);for nexp=1:nexps,nexpcross(nexp)=size(Inewc1{nexp},1);end
            Ic1=zeros([size(ic1,2),nexpcross]);
            Ic2=zeros([size(ic2,2),nexpcross]);
            for nexp=1:nexps,
                iIc1=find(Ec1==nexp);iIc2=find(Ec2==nexp);
                if ~isempty(iIc1), Ic1(iIc1,:,:)=repmat(Inewc1{nexp}',[1,1,size(Ic1(:,:,:),3)]); end
                if ~isempty(iIc2), Ic2(iIc2,:,:)=repmat(Inewc2{nexp}',[1,1,size(Ic2(:,:,:),3)]); end
                Ic1=permute(Ic1,[1,3:nexps+1,2]);
                Ic2=permute(Ic2,[1,3:nexps+1,2]);
            end
            Ic1=Ic1(:,:)';
            Ic2=Ic2(:,:)';
        end
        ncross=size(Ic2,1);
        nconjunction=size(Ic2,2);
        neffects=size(Ic1,2);
        spm_ss_threshold('subject',spm_data,Ic2,Ec2);
%       spm_ss_threshold('subject',SPM,Ic2);
%         if strcmpi(ss.Localizer_thr_type,'automatic'),
%             spm_ss_automaticthreshold('subject',SPM,Ic2);
%         else %if ~createlocalizerdone,
%             ss.Localizer{np}=spm_ss_createlocalizermask(SPM,Ic2,0,ss.Localizer_thr_type,ss.Localizer_thr_p);
%         end
        for nc=1:ncross,
            for ne=1:neffects,
                ss.EffectOfInterest{np}{ne,nc}=fullfile(fileparts(ss.EffectOfInterest_spm{min(size(ss.EffectOfInterest_spm,1),ne),np}),['con_',num2str(Ic1((ne-1)*ncross+nc),'%04d'),'.img']);
            end
        end
        fprintf('.');
    end
    fprintf('\n');
    [ss.Localizer_thr_p,ss.Localizer_thr_type,ss.Localizer]=spm_ss_threshold('end');
%     ss.Localizer{np}=spm_ss_createlocalizermask(SPM,Ic2,0,ss.Localizer_thr_type,ss.Localizer_thr_p);
% 	MaskFilenames{np}=spm_ss_createlocalizermask(SPM,ContrastIndexes{np},0,Threshold_type,Threshold_p);
%     if strcmpi(ss.Localizer_thr_type,'automatic'),
%         [ss.Localizer_thr_p,ss.Localizer]=spm_ss_automaticthreshold('end');
%         disp(['Optimal FDR-corrected threshold(s): FDR-p < ',num2str(ss.Localizer_thr_p(:)')]);
%     end
end

for np=1:ss.n,
    if numel(ss.Localizer{np})~=size(ss.EffectOfInterest{np},2),
        ncross=numel(ss.Localizer{np});
        neffects=numel(ss.EffectOfInterest{np})/ncross;
        if neffects~=size(ss.EffectOfInterest_contrasts,2),
            disp(['Subject #',num2str(np),'  # effect contrasts ',num2str(neffects), ' ; Expected # effect contrasts ',num2str(size(ss.EffectOfInterest_contrasts,2))]);
            error('The number of EFFECT OF INTEREST contrasts does not match the expected number of contrasts');
        end
        if rem(neffects,1),
            disp(['Subject #',num2str(np),' : # localizer volumes ',num2str(numel(ss.Localizer{np})), '  # effectofinterest volumes ',num2str(numel(ss.EffectOfInterest{np}))]);
            error('The number of cross-validation volumes for the EFFECT OF INTEREST contrasts must be a multiple of the number of volumes for the LOCALIZER contrast for each subject');
        else
            ss.EffectOfInterest{np}=reshape(ss.EffectOfInterest{np},[neffects,ncross]);
        end
    end
end

if initestimation, ss.estimate={}; ss.evaluate={}; end
ss.ask=[];ss.askn=[];

objname=findobj('tag','spm_ss');if numel(objname)==1,objdata.files_spm_ss=fullfile(ss.swd,['SPM_ss_',ss.type,'.mat']);set(objname,'userdata',objdata);end;
save(fullfile(ss.swd,['SPM_ss_',ss.type,'.mat']),'ss');
disp(['Analysis file saved: ',fullfile(ss.swd,['SPM_ss_',ss.type,'.mat'])]);

end
    
    
