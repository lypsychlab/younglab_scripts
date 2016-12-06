function roi_batch_item_alek(subjects,roi_name,task_dir, loc_dir, contrast_num, win_secs, onsetdelay, highpass, meanwin)

temp       = strread(task_dir,'%s','delimiter','/');
task       = temp{end};

temp       = strread(loc_dir,'%s','delimiter','/');
loc        = temp{end};

temp       = strread(subjects{1},'%s','delimiter','/');
study_dir  = [temp{1} '/' temp{2} '/' temp{3} '/' temp{4}];

subject_name = temp{5};

meanwin    = strread(meanwin,'%s','delimiter',';');

contrast_num = strread(contrast_num,'%s','delimiter',';');

row=3;meanrow=2;
wb = waitbar(0,'Processing. . . ');
roi_xyz=0;

% New functionality lets one apply a single ROI to all subjects
if strcmp(roi_name,'GROUP')
    group_roi=1;
    f     = spm_select(1,'mat','Choose a Group ROI file','','/younglab/roi_library','.*',1);
    load(f);if roi_xyz ==0;roi_xyz = xY.XYZmm';end % if VOI_*mat group ROI
    temp  = strread(f,'%s','delimiter','/');temp = temp{end};
    temp  = strread(temp,'%s','delimiter','.'); roi_name = temp{1};
else
    group_roi=0;
end
for s = 1:length(subjects)
    waitbar((s/length(subjects)),wb);
    fprintf(['Now working on subject: ' subjects{s} '. . . ']);
    %     try
    if (exist((fullfile(subjects{s},task_dir,'SPM.mat')))== 0)
        disp(fullfile(subjects{s},task_dir,'SPM.mat'))
        disp(['task dir: ' task_dir])
    else
        load(fullfile(subjects{s},task_dir,'SPM.mat'));
        clear temp
        if group_roi==0;
            temp = dir(fullfile(subjects{s},'roi',['ROI_' roi_name '_' loc '_' contrast_num{:} '_' '*xyz.mat']));
            if length(temp)>1
                f = spm_select(1,'mat','Choose a ROI xyz file','',fullfile(subjects{s},'roi'),'xyz.mat',1);
                load(f);temp = strread(f,'%s','delimiter','_');
                newfilt = ['*' temp{end-1} '_' temp{end}];
                temp = dir(fullfile(subjects{s},'roi',['ROI_' roi_name '_' loc '_' contrast_num{:} '_' newfilt]));
            end
            load(fullfile(subjects{s},'roi',temp(1).name));
        else % if group ROI, still have to do this part
            vinv_data = inv(SPM.xY.VY(1).mat);
            ROI.XYZ   = vinv_data(1:3,:)*[roi_xyz'; ones(1,size(roi_xyz',2))];
            ROI.XYZ   = round(ROI.XYZ);
        end
        
        
        [Cond, V, RT] = jc_get_design(SPM);
        window_length = round(win_secs / RT);
        V             = SPM.xY.VY;% Timepoints x 3D Images
        
        
        % new for item analyses
        onidx = [];
        for cc=1:10
            onidx = [onidx ; Cond(cc).onidx];
        end
        onidx = sort(onidx);
        
        clear items
        items = load(['/younglab/studies/DIS_MVPA/behavioural/' subject_name '.DIS.1.mat'],'items');
        items=items.items;
        
        
        % Extract values for timepoints x voxels
        for t = 1:length(V)
            ROI.Y(t,:) = spm_sample_vol(V(t), ROI.XYZ(1,:), ROI.XYZ(2,:), ROI.XYZ(3,:),1);
        end
        
        % This is a single timecourse for the ROI
        Y  = mean(ROI.Y,2);
        
        % High Pass Filtering to remove slow trends
        if highpass==1
            clear K;
            for  ss = 1:length(SPM.Sess)
                K(ss) = struct('HParam', 128,'row', SPM.Sess(ss).row,'RT', RT);
            end;
            K = spm_filter(K); Y = spm_filter(K,Y);
        end
        
        
        Y_avg2=zeros(60,22);
        
        % Create event-related responses for each condition
        % Collapsing across trials
        for c = 1:60
            for t=1:window_length+2 % include -1 and 0 trs
                tmp_idx          = onidx(items==c) + (t-3);
                tmp_idx          = tmp_idx(find(tmp_idx<=length(Y)));
                Y_avg2(c,t) = mean(Y(tmp_idx));
            end
        end
        
        % Grab baseline from rest periods
        onlist = 1;
        for c=1:60
            for t=onidx(items==c)'
                onlist = [onlist t:t+11+round(onsetdelay/RT)-1];
            end
        end
        offlist  = setdiff(1:length(Y),onlist);
        
        % make new offset list, omitting the first two trs
        for f = 1:length(SPM.nscan)
            nscan2(f) = sum(SPM.nscan(1:f));
        end
        croplist = sort([(nscan2-SPM.nscan(1)+1) (nscan2-SPM.nscan(1)+2)]);
        offlist  = setdiff(offlist,croplist);
        baseline = mean(Y(offlist));
        
        % Convert from raw to PSC
        PSC = zeros(60,window_length);
        for c = 1:60
            for t = 1:window_length+2
                PSC(c,t) = 100*(Y_avg2(c,t) - baseline)/baseline;
            end
        end
        
        save(fullfile(subjects{s},'roi', ['ROI_' roi_name '_' task '_' contrast_num{:} '_' date '_psc_item_alek.mat']), 'Cond','Y', 'PSC','offlist','-mat');
        clear Cond Y PSC offlist baseline croplist tmp_idx nscan2 V RT ROI vinv_data
    end
    fprintf('Done \n');
    
end% subject loop

cd(fullfile(study_dir,'ROI'));
waitbar(1,wb,'Finished!');

end