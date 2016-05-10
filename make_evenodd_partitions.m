%make_evenodd_partitions:
% uses preexisting info in DIS_MVPA SPM.mat file to construct appropriate MVPA partitions in PSYCH-PHYS

load SPM_DIS;
con_struct=SPM.xCon([39:42 52:55]);
clear SPM;

% experiments=struct(...
%     'name','PSYCH-PHYS',... % study name
%     'pwd1','/mnt/englewood/data/PSYCH-PHYS/',...   % folder with participants
%     'pwd2','results/DIS_results_normed_smoothed/',...   % inside each participant, path to SPM.mat
%     'data',{{...
%     'SAX_DIS_03','SAX_DIS_04','SAX_DIS_05','SAX_DIS_06','SAX_DIS_07',...
%     'SAX_DIS_08','SAX_DIS_09','SAX_DIS_10','SAX_DIS_11','SAX_DIS_12',...
%     'SAX_DIS_13','SAX_DIS_14','SAX_DIS_27','SAX_DIS_28','SAX_DIS_32',...
%     'SAX_DIS_34','SAX_DIS_38','SAX_DIS_40','SAX_DIS_41','SAX_DIS_42','SAX_DIS_43',...
%     'SAX_DIS_45','SAX_DIS_46'}});
experiments=struct(...
    'name','PSYCH-PHYS',... % study name
    'pwd1','/mnt/englewood/data/PSYCH-PHYS/',...   % folder with participants
    'pwd2','results/DIS_results_normed/',...   % inside each participant, path to SPM.mat
    'data',{{'SAX_DIS_06'}});

mkdir(fullfile(experiments.pwd1,'logs'));
diary(fullfile(experiments.pwd1,'logs',['make_evenodd_partitions_' date '.txt']));
for thissub=1:length(experiments.data)
    thisname=experiments.data{thissub};
    cd(fullfile(experiments.pwd1,thisname,experiments.pwd2));
    try
    load SPM;
    catch
        disp(['No SPM.mat for ' thisname]);
    end
    for thiscon=1:length(con_struct)
        con_name=con_struct(thiscon).name;
        con_vals=con_struct(thiscon).c;
        try
        SPM.xCon(end+1) = spm_FcUtil('Set', con_name, 'T', 'c', con_vals,SPM.xX.xKXs);
        catch
            disp(['Error with subject ' thisname ' new contrast ' num2str(thiscon)]);
            continue;
        end
    end
    try
    spm_contrasts(SPM);
    catch
        disp(['Could not run spm_contrasts for ' thisname]);
    end
    save SPM SPM;
    clear SPM;
end
diary off;
