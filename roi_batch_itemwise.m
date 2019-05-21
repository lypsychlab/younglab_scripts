function roi_batch_itemwise(subjects,roi_name,task_dir, loc_dir, contrast_num, win_secs, onsetdelay, highpass, meanwin)

temp       = strread(task_dir,'%s','delimiter','/');
task       = temp{end};

temp       = strread(loc_dir,'%s','delimiter','/');
loc        = temp{end};

temp       = strread(subjects{1},'%s','delimiter','/');
study_dir  = [temp{1} '/' temp{2} '/' temp{3} '/' temp{4} '/' temp{5}];

meanwin    = strread(meanwin,'%s','delimiter',';');

contrast_num = strread(contrast_num,'%s','delimiter',';');

row=3;meanrow=2;
wb = waitbar(0,'Processing. . . ');
roi_xyz=0;

% New functionality lets one apply a single ROI to all subjects
if strcmp(roi_name,'GROUP')
    group_roi=1;
    f     = spm_select(1,'mat','Choose a Group ROI file','','/data/younglw/lab/roi_library','.*',1);
    load(f);if roi_xyz ==0;roi_xyz = xY.XYZmm';end % if VOI_*mat group ROI
    temp  = strread(f,'%s','delimiter','/');temp = temp{end};
    temp  = strread(temp,'%s','delimiter','.'); roi_name = temp{1};
    clear notes
else
    group_roi=0;
end

for s = 1:length(subjects)
    waitbar((s/length(subjects)),wb);
    fprintf(['Now working on subject: ' subjects{s} '. . . ']);
    try
        if (exist((fullfile(subjects{s},task_dir,'SPM.mat')))== 0)
            disp(fullfile(subjects{s},task_dir,'SPM.mat'))
            disp(['task dir: ' task_dir])
        else
            load(fullfile(subjects{s},task_dir,'SPM.mat'));
            clear temp
            if group_roi==0;
                temp = dir(fullfile(subjects{s},'roi',['ROI_' roi_name '_' loc '_' contrast_num{:} '_' '*xyz.mat']));
                %             temp = c;
                if length(temp)>1
                    disp(length(temp))
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
            %     tempfile = dir(fullfile(subjects{s},'roi',['ROI_' roi_name '_' loc '*xyz.mat']));
            %     if length(tempfile) == 0
            %         fprintf([ subjects{s} ' has no ROI!']);
            %     else
            %         fprintf([ subjects{s} ' has ROI!']);
            %         load(fullfile(subjects{s},task_dir,'SPM.mat'));
            %         clear temp
            %         if group_roi==0;
            %             temp = dir(fullfile(subjects{s},'roi',['ROI_' roi_name '_' loc '*xyz.mat']));
            %             if length(temp)>1
            %                 f = spm_select(1,'mat','Choose a ROI xyz file','',fullfile(subjects{s},'roi'),'xyz.mat',1);
            %                 load(f);temp = strread(f,'%s','delimiter','_');
            %                 newfilt = ['*' temp{end-1} '_' temp{end}];
            %                 temp = dir(fullfile(subjects{s},'roi',['ROI_' roi_name '_' loc newfilt]));
            %             end
            %             load(fullfile(subjects{s},'roi',temp(1).name));
            %
            %         else % if group ROI, still have to do this part
            %             vinv_data = inv(SPM.xY.VY(1).mat);
            %             ROI.XYZ   = vinv_data(1:3,:)*[roi_xyz'; ones(1,size(roi_xyz',2))];
            %             ROI.XYZ   = round(ROI.XYZ);
            %         end

            [Cond, V, RT] = jc_get_design(SPM); %So this gets you the onsets for each dondition in Cond,
            %and all the data in V, and the TR in RT.
            window_length = round(win_secs / RT);
            V             = SPM.xY.VY;% Timepoints x 3D Images



            % Extract values for timepoints x voxels
            for t = 1:length(V)
                ROI.Y(t,:) = spm_sample_vol(V(t), ROI.XYZ(1,:), ROI.XYZ(2,:), ROI.XYZ(3,:),1);
            end

            % This is a single timecourse for the ROI
            Y  = mean(ROI.Y,2); %so this should have 834 rows.

            %start the excel cell array
            if exist('notes','var')== 0
                %I've extended the length of the cell 'notes' to be as long as
                %the number of conditions multipled by the number of onsets of
                %the 1st condition (taken for reference). It is assumed that
                %all conditions are shown an equal number of times.
                notes        = cell(length(Cond)*length(Cond(1).onidx)*length(subjects)+2,window_length+6);
                if group_roi==1
                    if highpass==1 notes(1,1)   = {['PSC averages for ' num2str(length(subjects)) ' Subjects with an offset delay of ' num2str(onsetdelay) ', Highpass filtered']};
                    else           notes(1,1)   = {['PSC averages for ' num2str(length(subjects)) ' Subjects with an offset delay of ' num2str(onsetdelay)]};
                    end
                else
                    if highpass==1 notes(1,1)   = {['PSC averages for ' num2str(length(subjects)) ' Subjects localized by ' loc ' with an offset delay of ' num2str(onsetdelay) ', Highpass filtered']};
                    else           notes(1,1)   = {['PSC averages for ' num2str(length(subjects)) ' Subjects localized by ' loc ' with an offset delay of ' num2str(onsetdelay)]};
                    end
                end
                notes(2,1:4) = {'Subject' 'Condition' 'Onset' 'Flag'};
                for i=-1:window_length
                    notes(2,i+6) = {(i*RT)-RT}; %This sets up all the TR onsets.
                end

                meanamp = cell(length(subjects)+1,window_length+5);
                meanamp(1,1:3) = {'Subject' 'Window' 'Flag'};

                for i=1:length(Cond)
                    meanamp(1,i+3) = Cond(i).name;
                end
            end

            % High Pass Filtering to remove slow trends
            if highpass==1
                clear K;
                for  ss = 1:length(SPM.Sess)
                    K(ss) = struct('HParam', 128,'row', SPM.Sess(ss).row,'RT', RT);
                end;
                K = spm_filter(K); Y = spm_filter(K,Y);
            end

            % warning for over 5% signal change
            Y2 = Y/mean(Y)*100;Y2 = Y2-100;
            if max(abs(Y2))>5
                notes(row,4) = {'Z > 5!'};meanamp(meanrow,2) = {'Z > 5!'};
            end

            %%%%%%%%%%FROM HERE DOWN NEEDS CHANGING FOR ITEMWISE%%%%%%%%%%%%%
            % Create event-related responses for each condition
            % Collapsing across trials
            for c = 1:length(Cond) %for each condition...

                %For each TR it goes:
                %1) Find all onsets, move TR accordingly.
                %2) Find everything in the large Y file.
                %3) Average all of those to create the mean.

                for t=1:window_length+2 % include -1 and 0 trs %for each TR
                    tmp_idx          = Cond(c).onidx + (t-3); %So this finds the onset and eeks along after it by TR.
                    %This will then be located on the
                    %absolute timeline of Y.
                    if max(tmp_idx)>length(Y)
                        tmp_idx(find(tmp_idx>length(Y)), 1)=length(Y);
                    end
                    %This bit here just repeats the last BOLD taken for the
                    %last trial. As this will only matter if the window
                    %size is greater than it actually was in the experiment
                    %this should not be an issue.

                    tmp_idx          = tmp_idx(find(tmp_idx<=length(Y)));
                    %At this point tmp_idx is just the indexs in Y that
                    %correspond to that time point in all runs of that
                    %condition. I wonder if there is a way to just keep this ad
                    % and export it.
                    Cond(c).Y_items(:,t) = Y(tmp_idx);
                    %I've changed this so all items will go in rows within
                    %Y_items, and time points will be calculated across the
                    %columns. Might need to use a transpose down the line or
                    %here.
                end
            end

            % Grab baseline from rest periods
            onlist = 1;
            for c=1:length(Cond)
                for t=Cond(c).onidx'
                    onlist = [onlist t:t+Cond(c).num_scans+round(onsetdelay/RT)-1];
                    %So this takes 1 (the very first scan), then adds the
                    %onsets of all conditions. Onsets are taken from when they
                    %begin to the number of scans they are designated to take.
                    %The
                end
            end
            offlist  = setdiff(1:length(Y),onlist);
            %So this offset list is where each trial ends (at the end of
            %the rest period as well).

            % make new offset list, omitting the first two trs
            %So this gets the onset of each run.
            for f = 1:length(SPM.nscan)
                nscan2(f) = sum(SPM.nscan(1:f));
            end
            %This part takes out the first two trs and sets the new list to
            %offlist.
            croplist = sort([(nscan2-SPM.nscan(1)+1) (nscan2-SPM.nscan(1)+2)]);
            offlist  = setdiff(offlist,croplist);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %So the baseline is the mean across all runs, of the point just
            %before the next trial is set to begin.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            baseline = mean(Y(offlist));

            % Convert from raw to PSC
            PSC = zeros(length(Cond)*length(Cond(1).onidx),window_length);
            for c = 1:length(Cond)
                for o = 1:length(Cond(c).onidx)
                    for t = 1:window_length+2
                        PSC(c*length(Cond(c).onidx)-length(Cond(c).onidx)+o,t) = 100*(Cond(c).Y_items(o,t) - baseline)/baseline;
                        notes(row,t+4) = num2cell(PSC(c*length(Cond(c).onidx)-length(Cond(c).onidx)+o,t));  %This is where the PSC is entered and ultimately saved.
                    end
                    notes(row,1:3) = [subjects{s} Cond(c).name Cond(c).onidx(o)];
                    row=row+1;
                end
            end

            % calculate mean windows
            for i=1:length(meanwin)
                meanamp(meanrow,1) = {subjects{s}};
                meanamp(meanrow,2) = {['''' meanwin{i} ]};
                for c=1:length(Cond)
                    temp = eval(meanwin{i});
                    clear x;
                    clear y;
                    x=round((temp(1)/RT)+1);y=round((temp(end)/RT)+1);
                    meanamp(meanrow,c+3) = {mean(PSC(c,x+2:y+2))};
                end
                meanrow=meanrow+1;
            end
            save(fullfile(subjects{s},'roi', ['ROI_' roi_name '_' task '_' contrast_num{:} '_' date '_psc.mat']), 'Cond','Y', 'PSC','offlist','-mat');
            clear Cond Y PSC offlist baseline croplist tmp_idx nscan2 V RT ROI vinv_data
        end
    catch
        warndlg(['Error with subject ' subjects{s}])
        notes(row,1:3) = {subjects{s} '' 'Error with this subject'};row=row+1;
        meanamp(meanrow,1:3) = {subjects{s} '' 'Error with this subject'};meanrow=meanrow+1;
    end

    fprintf('Done \n');

end% subject loop

if exist('notes','var')
    mkdir(fullfile(study_dir,'ROI'));
    cell2csv(fullfile(study_dir,'ROI', ['PSC_' roi_name '_' task '_' contrast_num{:} '_' num2str(length(subjects)) '_subs.csv']),notes,',','2000');
    cell2csv(fullfile(study_dir,'ROI', ['means_' roi_name '_' task '_' contrast_num{:} '_' num2str(length(subjects)) '_subs.csv']),meanamp,',','2000');
end

cd(fullfile(study_dir,'ROI'));
waitbar(1,wb,'Finished!');

end
