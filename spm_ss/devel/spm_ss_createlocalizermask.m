function maskfilename=spm_ss_createlocalizermask(SPM,Ic,Ec,overwrite,thr_type,thr)
% SPM_SS_CREATELOCALIZERMASK
% thresholds 1st-level contrast and create binary masks that can be used as
% localizer images.
%

if nargin<1,SPM={};end
if nargin<2,Ic=[];end
if nargin<3,Ec=[];end
if nargin<4,overwrite=1;end
if nargin<5,thr_type={};end
if nargin<6,thr=[];end
if ~isempty(thr_type)&&ischar(thr_type)&&isempty(strmatch(thr_type,{'FDR','FWE','none'},'exact')),return;end
maskfilename={};
if ~iscell(thr_type),thr_type=cellstr(thr_type); end

posstr=1;
if isempty(SPM),
    str='Select first-level SPM.mat(s) (one per subject)';
    disp(str);
    Pdefault={''};objname=findobj('tag','spm_ss');if numel(objname)==1,objdata=get(objname,'userdata');if isfield(objdata,'files_spm'),Pdefault=objdata.files_spm;end;end;
    P=cellstr(spm_select(inf,'^SPM\.mat$',str,Pdefault));
    if numel(objname)==1&&~isempty(P),objdata.files_spm=P;set(objname,'userdata',objdata);end;
    
    for np=1:numel(P),
        load(P{np},'SPM');
        SPM.swd=fileparts(P{np});
        maskfilename{np}=spm_ss_createlocalizermask({SPM},Ic,[],overwrite,thr_type,thr);
    end
    return;
end

if ~isempty(Ic)&&(ischar(Ic)||iscell(Ic)),
    if ischar(Ic),ContrastNames=cellstr(Ic);
    else ContrastNames=Ic; end
else
    ContrastNames={};
end

if isempty(Ec), if ~isempty(ContrastNames), Ec=ones(size(ContrastNames)); else Ec=ones(size(Ic)); end; end

if ~isempty(ContrastNames),
    ic=[];ok=1;
    for n1=1:numel(ContrastNames),
        Cnames={SPM{Ec(n1)}.xCon(:).name};
        temp=strmatch(ContrastNames{n1},Cnames,'exact');if numel(temp)~=1,ok=0;break;else ic(n1)=temp;end;
    end
    if ~ok, error(['the target contrasts are not found inside ',SPM.swd]); end
    Ic=reshape(ic,size(ContrastNames));
end
if isempty(Ic),
    ic={};ec={};
    for np=1:numel(SPM),
        str=['Select LOCALIZER contrast(s) from ',SPM{np}.swd];
        disp(str);
        ic{np}=spm_conman(SPM{np},'T|F',inf,str,'',0);
        ic{np}=ic{np}(:)';
        ec{np}=np+zeros(1,numel(ic{np}));
    end
    Ic=cat(2,ic{:});
    Ec=cat(2,ec{:});
    if length(Ic)>1,
        if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
        str='Create a separate localizer volume per contrast|Create a single localizer volume from the conjunction of the selected contrasts';
        disp(str);
        conjunction=spm_input('how to handle multiple contrasts?',posstr,'m',str,[0,1],1);posstr='+1';
        if conjunction, 
            Ic=Ic(:)'; 
            Ec=Ec(:)';
            str='Inclusive (1) or exclusive (0) mask for each contrast?';
            disp(str);
            signIc=spm_input(str,posstr,'r',num2str(ones(1,numel(Ic))),[1,numel(Ic)],[0,1]);posstr='+1';
            Ic(signIc<.5)=-Ic(signIc<.5);
        else Ic=Ic(:); Ec=Ec(:); end
    end
end
%if isempty(ContrastNames),ContrastNames={SPM.xCon(abs(Ic)).name}; end
if isempty(thr_type),
    if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
    str='FDR|FWE|none';
    thr_type={};
    if numel(thr)>1
        for nic2=1:max(1,numel(thr)),
            thr_type{nic2}=spm_input(['contrast #',num2str(nic2),': p value adjustment to control'],posstr,'b',str,[],1);posstr='+1';
        end
    else
        thr_type={spm_input('p value adjustment to control',posstr,'b',str,[],1)};posstr='+1';
    end
end
if isempty(thr),
    if isnumeric(posstr)&&isempty(findobj(0,'tag','Interactive')), spm('CreateIntWin'); end;
    thr=[];
    if numel(thr_type)>1
        for nic2=1:numel(thr_type)
            if strcmpi(thr_type{nic2},'none'),defp=.001;else defp=.05;end
            if strcmpi(thr_type{nic2},'automatic'), thr(nic2)=nan;
            else thr(nic2)=spm_input(['contrast #',num2str(nic2),': p value (',thr_type{nic2},')'],posstr,'r',num2str(defp),1,[0,1]);posstr='+1'; end
        end
    else
        if strcmpi(thr_type{1},'none'),defp=.001;else defp=.05;end
        if strcmpi(thr_type{1},'automatic'), thr=nan;
        else thr=spm_input(['p value (',thr_type{1},')'],posstr,'r',num2str(defp),1,[0,1]);posstr='+1'; end
    end
end

if numel(thr)<size(Ic,2),thr=repmat(thr,[1,size(Ic,2)]);end
if numel(thr_type)<size(Ic,2), thr_type=repmat(thr_type,[1,size(Ic,2)]); end
if size(Ec,1)<size(Ic,1), Ec=Ec(min(size(Ec,1),1:size(Ic,1)),:); end

symbols={'','not'};signIc=1+(sign(Ic)<0);
for nic1=1:size(Ic,1), % computes one separate thresholded volume per row of Ic (multiple columns are treated as a conjunction)
    filename='locT_';
    for nic2=1:size(Ic,2),
        if Ec(nic1,nic2)~=Ec(nic1,1), temp=SPM{Ec(nic1,nic2)}.swd; temp(temp==filesep)='_';filename=[filename,temp]; end
        filename=[filename,symbols{signIc(nic1,nic2)},num2str(abs(Ic(nic1,nic2)),'%04d'),'_',thr_type{nic2},num2str(thr(nic2))]; 
        if nic2<size(Ic,2),filename=[filename,'_']; end; 
    end; 
    filename=[filename,'.img'];
    maskfilename{nic1}=fullfile(SPM{Ec(nic1,1)}.swd,filename);
    if overwrite||isempty(dir(maskfilename{nic1})),
        Z=1;
        U={};
        for nic2=1:size(Ic,2),
            if ~isempty(strmatch(thr_type{nic2},{'FDR','FWE','none'},'exact')),
                %         try,
                a=spm_vol(fullfile(SPM{Ec(nic1,nic2)}.swd,SPM{Ec(nic1,nic2)}.xCon(abs(Ic(nic1,nic2))).Vspm.fname));
                b=spm_read_vols(a);
                idx=find(~isnan(b)&b~=0);
                dof=[SPM{Ec(nic1,nic2)}.xCon(abs(Ic(nic1,nic2))).eidf,SPM{Ec(nic1,nic2)}.xX.erdf];
                STAT=SPM{Ec(nic1,nic2)}.xCon(abs(Ic(nic1,nic2))).STAT;
                R=SPM{Ec(nic1,nic2)}.xVol.R;
                S=SPM{Ec(nic1,nic2)}.xVol.S;
                n=1;
                switch(thr_type{nic2}),
                    case 'FWE',
                        u=spm_uc(thr(nic2),dof,STAT,R,n,S);
                        Y=double(b>u);
                    case 'FDR',
                        Y=nan+zeros(size(b));
                        switch(STAT),
                            case 'Z',Y(idx)=1-spm_Ncdf(b(idx));
                            case 'T',Y(idx)=1-spm_Tcdf(b(idx),dof(2));
                            case 'X',Y(idx)=1-spm_Xcdf(b(idx),dof(2));
                            case 'F',Y(idx)=1-spm_Fcdf(b(idx),dof);
                            otherwise, error('null');
                        end
                        Y(:)=spm_ss_fdr(Y(:));
                        Y=double(Y<thr(nic2));
                    case 'none'
                        u=spm_u(thr(nic2),dof,STAT);
                        Y=double(b>u);
                end
                U{nic2}=sprintf('p=%f(%s),u=%f,STAT=%s,dof=[%f,%f],R=[%f,%f,%f,%f],S=%f,n=%d,I=%d;',thr(nic2),thr_type{nic2},mean([max(b(~Y)),min(b(Y>0))]),STAT,dof(1),dof(2),R(1),R(2),R(3),R(4),S,n,sign(Ic(nic1,nic2))>0); %p=spm_P_RF(1,0,u,dof,STAT,R,n);
                %         catch,
                %             xSPM=struct('swd',SPM.swd,...
                %                 'title','',...
                %                 'Ic',ic,...
                %                 'Im',[],...
                %                 'thresDesc',thr_type,... % height thresholding type
                %                 'u',thr,... % height threshold level
                %                 'k',0); % extent threshold
                %             SPM.xCon(ic).Vcon=spm_vol(fullfile(SPM.swd,SPM.xCon(ic).Vcon.fname));
                %             SPM.xCon(ic).Vspm=spm_vol(fullfile(SPM.swd,SPM.xCon(ic).Vspm.fname));
                %             [SPM,xSPM] = spm_getSPM(xSPM);
                %             cd(SPM.swd);
                %             Vo=struct(...
                %                 'fname',    filename,...
                %                 'dim',      xSPM.DIM',...
                %                 'dt',       [spm_type('uint8') spm_platform('bigend')],...
                %                 'mat',      xSPM.M,...
                %                 'descrip',  sprintf('SPM{%c}-filtered: u = %5.3f, k = %d',xSPM.STAT,xSPM.u,xSPM.k));
                %             Y      = zeros(xSPM.DIM(1:3)');
                %             OFF    = xSPM.XYZ(1,:) + xSPM.DIM(1)*(xSPM.XYZ(2,:)-1 + xSPM.DIM(2)*(xSPM.XYZ(3,:)-1));
                %             Y(OFF) = xSPM.Z.*(xSPM.Z > 0);
                %         end
                
                if sign(Ic(nic1,nic2))<0, Y=~Y; U=-U; end % exclusion mask
                if ~any(Y(:)>0), disp(['Warning! Output localizer volume #',num2str(nic1), ', contrast name ',symbols{signIc(nic1,nic2)},SPM{Ec(nic1,nic2)}.xCon(abs(Ic(nic1,nic2))).name,',  in contrast file ',fullfile(SPM{Ec(nic1,nic2)}.swd,filename),', contains no supra-threshold voxels']);
                else disp([num2str(sum(Y(:)>0)),' voxels in output localizer volume #',num2str(nic1), ', contrast name ',symbols{signIc(nic1,nic2)},SPM{Ec(nic1,nic2)}.xCon(abs(Ic(nic1,nic2))).name,',  in contrast file ',fullfile(SPM{Ec(nic1,nic2)}.swd,filename)]); end
                % computes conjunction across rows of Ic
                Z=Z&Y;
            else
                error(['Incorrect threshold type option',thr_type{nic2}]);
            end
        end
        if numel(Z)>1
            if size(Ic,2)>1,
                if ~any(Z(:)>0), disp(['Warning! Output localizer volume #',num2str(nic1), ',  in contrast file ',maskfilename{nic1},', contains no supra-threshold voxels']);
                else disp([num2str(sum(Z(:)>0)),' voxels in output localizer volume #',num2str(nic1), ',  in contrast file ',maskfilename{nic1}]); end
            end
            cwd0=pwd;
            cd(fileparts(maskfilename{nic1}));
            Vo=struct(...
                'fname',    filename,...
                'dim',      a.dim,...
                'dt',       [spm_type('uint8') spm_platform('bigend')],...
                'mat',      a.mat,...
                'descrip',  sprintf('SPM_SS LOCALIZER{%s}',cat(2,U{:})));
            Vo=spm_write_vol(Vo,Z);
            cd(cwd0);
        end
    end
end




