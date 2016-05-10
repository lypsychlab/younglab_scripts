function roi_batch_item_alek(subjects,roi_name,task_dir, loc_dir, contrast_num, win_secs, onsetdelay, highpass, meanwin)
temp       = strread(task_dir,'%s','delimiter','/');
task       = temp{end};
temp       = strread(loc_dir,'%s','delimiter','/');
loc        = temp{end};
temp       = strread(subjects{1},'%s','delimiter','/');
study_dir  = [temp{1} '/' temp{2} '/' temp{3} '/' temp{4}];
meanwin    = strread(meanwin,'%s','delimiter',';');
contrast_num = strread(contrast_num,'%s','delimiter',';');

row       = 3;
meanrow   = 2;
roi_xyz   = 0;
group_roi = 0;
s         = 1;




for s = 1:length(subjects)
    fprintf(['Now working on subject: ' subjects{s} '. . . ']);
    
    load(fullfile(subjects{s},task_dir,'SPM.mat'));
    
    f = spm_select(1,'mat','Choose a ROI xyz file','',fullfile(subjects{s},'roi'),'xyz.mat',1);
    load(f);temp = strread(f,'%s','delimiter','_');
    newfilt = ['*' temp{end-1} '_' temp{end}];
    temp = dir(fullfile(subjects{s},'roi',['ROI_' roi_name '_' loc '_' contrast_num{:} '_' newfilt]));
    load(fullfile(subjects{s},'roi',temp(1).name));
    
    
    [Cond, V, RT] = jc_get_design(SPM);
    window_length = round(win_secs / RT);
    V             = SPM.xY.VY;% Timepoints x 3D Images
    
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
    
    xx = dir('/younglab/studies/DIS_MVPA/SAX_DIS*');clear items
    items = load(['/younglab/studies/DIS_MVPA/behavioural/' xx(s).name '.DIS.1.mat'],'items');
    items=items.items;
    
    % new for item analyses
    onidx = [];
    for cc=1:10
        onidx = [onidx ; Cond(cc).onidx];
    end
    onidx = sort(onidx);
    
    
    
    %
    % Y_avg=zeros(10,22);
    %
    % % Create event-related responses for each condition
    % % Collapsing across trials
    % for c = 1:length(Cond)
    %     for t=1:window_length+2 % include -1 and 0 trs
    %         tmp_idx          = Cond(c).onidx + (t-3);
    %         tmp_idx          = tmp_idx(find(tmp_idx<=length(Y)));
    %         Y_avg(c,t) = mean(Y(tmp_idx));
    %     end
    % end
    
    
    
    
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
    for c=1:length(Cond)
        for t=Cond(c).onidx'
            onlist = [onlist t:t+Cond(c).num_scans+round(onsetdelay/RT)-1];
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
    %
    % % Convert from raw to PSC
    % PSC = zeros(length(Cond),window_length);
    % for c = 1:length(Cond)
    %     for t = 1:window_length+2
    %         PSC(c,t) = 100*(Y_avg(c,t) - baseline)/baseline;
    %     end
    % end
    
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

cd(fullfile(study_dir,'ROI'));

end