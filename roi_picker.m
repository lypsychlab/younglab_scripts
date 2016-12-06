function roi_picker(t,k,r,c,roi_name,roi_xyz,subjects,res_dir)
% This is called on by roi_picker_gui.
%
% it could potentially be run without the gui (but what fun is that?), using the following implementation:
%
% roi_picker(threshold,cluster_size, radius, contrast_number, roi_name, start_xyz(in string), subjects(in cell), results_dir)
% e.g.:
% roi_picker(.001,5,9,1,'RTPJ','[0 0 0]',{'/mindhive/saxelab/CUES3/SAX_cues3_05'},'results/cues3_results_normed');
% 
% Written by Alek Chakroff, November 2009

% start log
load(fullfile(subjects{1},res_dir,'SPM.mat'));
notes = {['ROIs chosen for ' roi_name ' and ' SPM.xCon(c).name ' contrast at p=' num2str(t) ' unc and k=' num2str(k) ' with ' num2str(r) 'mm sphere'] '' '' '' '' '';...
    'Name' 'Peak X' 'Peak Y' 'Peak Z' 'N Voxels' 'T Value'};
spm fmri;
run_it(t,k,r,c,roi_name,roi_xyz,subjects,1,notes,res_dir);
end

function run_it(t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir)
if i>length(subjects) % just finished last subject
    spm quit;clc;fprintf('\n\n\n\t\t\t\t\t\tFIN\n\n\n')
else
    % Load up the subject with desired parameters, display glass brain
    temp                                           = strread(subjects{i},'%s','delimiter','/');
    jobs{1}.stats{1}.results.spmmat                = cellstr(fullfile(subjects{i},res_dir,'SPM.mat'));
    jobs{1}.stats{1}.results.conspec(1).titlestr   = ['Select the ' roi_name ' for ' temp{end} ' [' num2str(i) ' of ' num2str(length(subjects)) ']'];
    jobs{1}.stats{1}.results.conspec(1).contrasts  = c;
    jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
    jobs{1}.stats{1}.results.conspec(1).thresh     = t;
    jobs{1}.stats{1}.results.conspec(1).extent     = k;
    spm_jobman('run',jobs);
    
    % If ROI is 'other', with user-specified x y z
    if ischar(roi_xyz)
        try   eval(['spm_mip_ui(''SetCoords'',[' roi_xyz' '],findobj(spm_figure(''FindWin'',''Graphics''),''Tag'',''hMIPax''));']);
        catch eval(['spm_mip_ui(''SetCoords'',' roi_xyz' ',findobj(spm_figure(''FindWin'',''Graphics''),''Tag'',''hMIPax''));']);
        end
        spm_mip_ui('Jump',findobj(spm_figure('FindWin','Graphics'),'Tag','hMIPax'),'nrmax');
    else
        % Set the cursor to the starting location for this ROI
        h  = findobj(spm_figure('FindWin','Graphics'),'Tag','hMIPax'); % Get Handle for the SPM figure
        MD = get(h,'UserData');% MD.Z is a single vector of z scores for all suprathreshold voxels
        [null, null, roi] = intersect(roi_xyz,MD.XYZ','rows'); % MD.XYZ is a 3-row matric of coordinates of MD.Z voxels
        if isempty(roi)
            warndlg(['No Suprathreshold voxels for ' roi_name '!']);
        else
            [null, idx] = max(MD.Z(roi));
            xyz         = MD.XYZ(:,roi(idx));
            spm_mip_ui('SetCoords',xyz,h,h);
        end
    end
    
    % Overlay on T1 image
    try
        imgdir = dir(fullfile(subjects{i},'3danat','ws*.img'));
        evalin('base',['spm_sections(xSPM,findobj(spm_figure(''FindWin'',''Interactive''),''Tag'',''hReg''),''' fullfile(subjects{i},'3danat',imgdir(1).name) ''');']);
    catch
        evalin('base','spm_sections(xSPM,findobj(spm_figure(''FindWin'',''Interactive''),''Tag'',''hReg''),''/software/spm8/canonical/single_subj_T1.nii'');');
    end 

    % quit button
    uicontrol('Style','pushbutton',        'Units','normalized',...
        'Position',[.9 .95 .1 .05],  'String','Quit',...
        'Interruptible','off',       'BusyAction','cancel',...
        'BackgroundColor',[.9 .5 .9],'Callback',@quit_it);
    % back button
    uicontrol('Style','pushbutton',       'Units','normalized',...
        'Position',[0 .95 .1 .05],'String','Back',...
        'BackgroundColor',[.9 .5 .9],'Callback',{@back_one,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir});
    % bad button
    uicontrol('Style','pushbutton',       'Units','normalized',...
        'Position',[.33 .59 .13 .1],'String','None found',...
        'BackgroundColor','red','Callback',{@bad_one,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir});
    % good button
    uicontrol('Style','pushbutton',       'Units','normalized',...
        'Position',[.47 .59 .13 .1],'String','Continue',...
        'BackgroundColor','green','Callback',{@good_one,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir});
end
end

function good_one(hObject,eventdata,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir)

% Extract Roi Information based on selected xyz location
evalin('base','xY.xyz     = spm_mip_ui(''Jump'',findobj(spm_figure(''FindWin'',''Graphics''),''Tag'',''hMIPax''),''nrmax'');');
evalin('base',['xY.name   = ''' roi_name ''';']);
evalin('base','xY.Ic      = 0;');
evalin('base','xY.Sess    = 1;');
evalin('base','xY.def     = ''sphere'';');
evalin('base',['xY.spec   = ' num2str(r) ';']);
% save('xSPM.mat','xSPM','hReg');
evalin('base','[Y,xY] = spm_regions(xSPM,SPM,hReg,xY);');
ROI.XYZmm = evalin('base','xY.XYZmm;');% ROI coordinates
vinv_data = evalin('base','inv(SPM.xY.VY(1).mat);');
ROI.XYZ   = vinv_data(1:3,:)*[ROI.XYZmm; ones(1,size(ROI.XYZmm,2))];
ROI.XYZ   = round(ROI.XYZ);
temp      = strread(res_dir,'%s','delimiter','/');
task      = temp{length(temp)};
xY        = evalin('base','xY');

% grab the z value for the chosen xyz coordinate
h     = findobj(spm_figure('FindWin','Graphics'),'Tag','hMIPax'); MD = get(h,'UserData');
z_idx = find(MD.XYZ(1,:) == xY.xyz(1) & MD.XYZ(2,:) == xY.xyz(2) & MD.XYZ(3,:) == xY.xyz(3));

if ~exist('roi','dir');
    mkdir('roi');
    if ~exist('roi','dir')
        uiwait(msgbox('Hmm...it looks like you don''t have an ../roi/ directory in your subject folder. I tried to make one, but it didn''t take...looks like there''s a permissions issue. Make the directory then hit ''okay'''));
    end
end
save(fullfile(subjects{i},'roi',['ROI_' roi_name '_' task '_' num2str(c) '_' date '_xyz.mat']), 'ROI','xY','-mat');
cd(fullfile(subjects{i},'roi'));
<<<<<<< HEAD
mat2img( fullfile(subjects{1},res_dir,'spmT_0001.nii'),fullfile(subjects{i},'roi',['ROI_' roi_name '_' task '_' num2str(c) '_' date '_xyz.mat']) );
=======

mat2img( fullfile(subjects{1},res_dir,'spmT_0001.img'),fullfile(subjects{i},'roi',['ROI_' roi_name '_' task '_' num2str(c) '_' date '_xyz.mat']) );
>>>>>>> 4ea36e0abf8da612bbc2f8f0c2b7dc72c0a45376

% update log
notes(i+2,:) = {subjects{i} xY.xyz(1) xY.xyz(2) xY.xyz(3) size(xY.XYZmm,2) MD.Z(z_idx)};
temp         = strread(subjects{i},'%s','delimiter','/');
study_dir    = [temp{1} '/' temp{2} '/' temp{3} '/' temp{4}];
cd(study_dir); mkdir 'ROI'; % added by LT, 11/11/11
cell2csv(fullfile(study_dir,'ROI', ['ROI_picker_log_' roi_name '_' task '_' num2str(c) '_' num2str(length(subjects)) '_subjects.csv']),notes,',','2000');

% go to next subject
run_it(t,k,r,c,roi_name,roi_xyz,subjects,i+1,notes,res_dir);
end

function bad_one(hObject,eventdata,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir)

% update log
temp         = strread(res_dir,'%s','delimiter','/');
task         = temp{length(temp)};
temp         = strread(subjects{i},'%s','delimiter','/');
study_dir    = [temp{1} '/' temp{2} '/' temp{3} '/' temp{4}];
notes(i+2,:) = {subjects{i} ': none found' '' '' '' ''};
cd(study_dir); mkdir 'ROI'; % added by LT, 11/11/11
cell2csv(fullfile(study_dir,'ROI', ['ROI_picker_log_' roi_name '_' task '_' num2str(c) '_' num2str(length(subjects)) '_subjects.csv']),notes,',','2000');

% go to next subject
run_it(t,k,r,c,roi_name,roi_xyz,subjects,i+1,notes,res_dir);
end

function back_one(hObject,eventdata,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir)
if i>1
    % update log
    temp         = strread(res_dir,'%s','delimiter','/');
    task         = temp{length(temp)};
    temp         = strread(subjects{i},'%s','delimiter','/');
    study_dir    = [temp{1} '/' temp{2} '/' temp{3} '/' temp{4}];
    cd(study_dir); mkdir 'ROI'; % added by LT, 11/11/11
    cell2csv(fullfile(study_dir,'ROI', ['ROI_picker_log_' roi_name '_' task '_' num2str(c) '_' num2str(length(subjects)) '_subjects.csv']),notes,',','2000');

    % go back one subject
    run_it(t,k,r,c,roi_name,roi_xyz,subjects,i-1,notes,res_dir);
else
    warndlg('You can''t go back from the first subject, silly!', 'Duh.');
end
end

function quit_it(hObject,eventdata)
quit_reply = questdlg('All previous subjects, but not the current subject, have been saved. Are you sure you want to quit?');
if strcmp(quit_reply,'Yes')
    spm quit;clc;fprintf('\n\n\n\t\t\t\t\t\tFIN\n\n\n');
end
end