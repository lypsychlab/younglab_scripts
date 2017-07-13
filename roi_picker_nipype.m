function roi_picker_nipype(t,k,r,c,roi_name,roi_xyz,subjects,spm_dir,res_dir,workflow_dir,rootdir)
% Written by Alek Chakroff, November 2009
% Edited by Emily Wasserman, 2016/17
% Note: use with SPM8 & Matlab 2012 - Emily

% E.g.:
% t: .001
% k: 5
% r: 9
% c: 1
% roi_name: 'RTPJ'
% roi_xyz: '[0; 0; 0]'
% subjects: {'YOU_FIRSTTHIRD_01','YOU_FIRSTTHIRD_02'}
% spm_dir: 'contrast'
% res_dir = 'TOM_LOCALIZER'
% workflow_dir: 'tom_contrast'
% rootdir: '/home/younglw/lab/FIRSTTHIRD'
% 
% Assumes that SPM.mat/spmT* files are in {rootdir}/{workflow_dir}/_subject_id_{subjID}_task_name_{res_dir}/{spm_dir}/
% 
% Assumes that all anatomical files are in {rootdir}/anat/_subject_id_{subjID}_task_name_{*}/normalize/
% 
% Saves ROI files under: {rootdir}/roi/{subjID} folders

% start log
load(fullfile(spm_dir,'SPM.mat'));
notes = {['ROIs chosen for ' roi_name ' and ' SPM.xCon(c).name ' contrast at p=' num2str(t) ' unc and k=' num2str(k) ' with ' num2str(r) 'mm sphere'] '' '' '' '' '';...
    'Name' 'Peak X' 'Peak Y' 'Peak Z' 'N Voxels' 'T Value'};
spm fmri;
run_it(t,k,r,c,roi_name,roi_xyz,subjects,1,notes,res_dir);
end

if ~exist(fullfile(rootdir,'roi'),'dir');
    mkdir(fullfile(rootdir,'roi'));
end

function run_it(t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir)
if i>length(subjects) % just finished last subject
    spm quit;clc;fprintf('\n\n\n\t\t\t\t\t\tFIN\n\n\n')
else
    % Load up the subject with desired parameters, display glass brain
    % temp                                           = strread(subjects{i},'%s','delimiter','/');
    jobs{1}.stats{1}.results.spmmat                = cellstr(fullfile(rootdir,workflow_dir,['_subject_id_' subjects{i} '_task_name_' res_dir],spm_dir,'SPM.mat'));
    jobs{1}.stats{1}.results.conspec(1).titlestr   = ['Select the ' roi_name ' for ' subjects{i} ' [' num2str(i) ' of ' num2str(length(subjects)) ']'];
    jobs{1}.stats{1}.results.conspec(1).contrasts  = c;
    jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
    jobs{1}.stats{1}.results.conspec(1).thresh     = t;
    jobs{1}.stats{1}.results.conspec(1).extent     = k;
    spm_jobman('run',jobs);
    
    TOM_rois={'VMPFC' 'RTPJ' 'LTPJ' 'RSTS' 'LSTS' 'PC' 'MMPFC' 'RIFG' 'DMPFC'}
    if ismember(roi_name,TOM_rois) & ischar(roi_xyz)
        roifile=load(fullfile('/home/younglw/lab/roi_library/functional',[roi_name '_xyz.mat']));
        roicoords=roifile.roi_xyz(1,:);
        roi_xyz=sprintf('[%d; %d; %d]',roicoords(1),roicoords(2),roicoords(3));
        clear roifile;
    end

    % If ROI is 'other', with user-specified x y z
    if ischar(roi_xyz)

    try   
    eval(['spm_mip_ui(''SetCoords'',[' roi_xyz '],findobj(spm_figure(''FindWin'',''Graphics''),''Tag'',''hMIPax''));']);
    catch 
    cmd=['spm_mip_ui(''SetCoords'',' roi_xyz ',findobj(spm_figure(''FindWin'',''Graphics''),''Tag'',''hMIPax''));'];
    eval(cmd);
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
        anatdir = dir(fullfile(rootdir,'anat',['_subject_id_' subjects{i} '*']));
        imgdir = dir(fullfile(rootdir,'anat',anatdir(1).name,'normalize','ws*.nii'));
        if length(imgdir)==0
            imgdir = dir(fullfile(rootdir,'anat',anatdir(1).name,'normalize','ws*.img'));
        end
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

evalin('base','[Y,xY] = spm_regions(xSPM,SPM,hReg,xY);');
ROI.XYZmm = evalin('base','xY.XYZmm;');% ROI coordinates
vinv_data = evalin('base','inv(SPM.xY.VY(1).mat);');
ROI.XYZ   = vinv_data(1:3,:)*[ROI.XYZmm; ones(1,size(ROI.XYZmm,2))];
ROI.XYZ   = round(ROI.XYZ);
temp      = res_dir
xY        = evalin('base','xY');

% grab the z value for the chosen xyz coordinate
h     = findobj(spm_figure('FindWin','Graphics'),'Tag','hMIPax'); MD = get(h,'UserData');
z_idx = find(MD.XYZ(1,:) == xY.xyz(1) & MD.XYZ(2,:) == xY.xyz(2) & MD.XYZ(3,:) == xY.xyz(3));

if ~exist(fullfile(rootdir,'roi',subjects{i}),'dir');
    mkdir(fullfile(rootdir,'roi',subjects{i}));
    % if ~exist('roi','dir')
    %     uiwait(msgbox('Hmm...it looks like you don''t have an ../roi/ directory in your subject folder. I tried to make one, but it didn''t take...looks like there''s a permissions issue. Make the directory then hit ''okay'''));
    % end
end
save(fullfile(rootdir,'roi',subjects{i},['ROI_' roi_name '_' task '_' num2str(c) '_' date '_xyz.mat']), 'ROI','xY','-mat');
cd(fullfile(rootdir,'roi',subjects{i}));
try
    mat2img( fullfile(rootdir,workflow_dir,['_subject_id_' subjects{i} '_task_name_' res_dir],spm_dir,'spmT_0001.nii'),fullfile(rootdir,'roi',subjects{i},['ROI_' roi_name '_' task '_' num2str(c) '_' date '_xyz.mat']) );
catch
    mat2img( fullfile(rootdir,workflow_dir,['_subject_id_' subjects{i} '_task_name_' res_dir],spm_dir,'spmT_0001.img'),fullfile(rootdir,'roi',subjects{i},['ROI_' roi_name '_' task '_' num2str(c) '_' date '_xyz.mat']) );
end
% update log
notes(i+2,:) = {subjects{i} xY.xyz(1) xY.xyz(2) xY.xyz(3) size(xY.XYZmm,2) MD.Z(z_idx)};
cell2csv(fullfile(rootdir,'roi', ['ROI_picker_log_' roi_name '_' res_dir '_' num2str(c) '_' num2str(length(subjects)) '_subjects.csv']),notes,',','2000');

% go to next subject
run_it(t,k,r,c,roi_name,roi_xyz,subjects,i+1,notes,res_dir);
end

function bad_one(hObject,eventdata,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir)

% update log
notes(i+2,:) = {subjects{i} xY.xyz(1) xY.xyz(2) xY.xyz(3) size(xY.XYZmm,2) MD.Z(z_idx)};
cell2csv(fullfile(rootdir,'roi', ['ROI_picker_log_' roi_name '_' res_dir '_' num2str(c) '_' num2str(length(subjects)) '_subjects.csv']),notes,',','2000');


% go to next subject
run_it(t,k,r,c,roi_name,roi_xyz,subjects,i+1,notes,res_dir);
end

function back_one(hObject,eventdata,t,k,r,c,roi_name,roi_xyz,subjects,i,notes,res_dir)
if i>1
    % update log
    notes(i+2,:) = {subjects{i} xY.xyz(1) xY.xyz(2) xY.xyz(3) size(xY.XYZmm,2) MD.Z(z_idx)};
    cell2csv(fullfile(rootdir,'roi', ['ROI_picker_log_' roi_name '_' res_dir '_' num2str(c) '_' num2str(length(subjects)) '_subjects.csv']),notes,',','2000');


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