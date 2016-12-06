function roi__struct_picker_gui(fcn)
% This is a GUI for choosing Functional Regions of Interest in a timely manner.
%
% Implementation is pretty straightforward - This script accepts no arguments.
%
% This assumes a directory and naming convention output by younglab*SPM8
% scripts. 
%
% ======== Controls ======================
%
% Subjects: 
% Opens spm file selection tool to load subjects. choose the subject 
% folder titled SAX_* for each subject. These folders must contain a folder 
% titled 'roi', and some results folders containing spm.mat files.
% 
% ROI Chooser:
% When you select an ROI, two things happen.
% 1. This determines the output file name for the roi_log and coordinates files.
% 2. This automatically loads an roi search region file
% 
% if you choose 'other', you have two options
% 1. you may choose your own roi search file to load. this contains a list
% of coordinates for a previously-defined functional or anatomical roi - 
% basically a tal file. to make your own, see /younglab/roi_library
% 2. you may enter x y z coordinates as a starting point for the script. 
% it will find a local max near this location for each subject.
% 
% Threshold:
% p value threshold for viewing each subject, all uncorrected.
% 
% Cluster Size (k):
% minimum number of contiguous voxels in a blob for displaying
% 
% Radius Size:
% this is the first paramater that directly affects the output of this
% program! what is the radius of the sphere you want to build around 
% your final cursor location?
% 
% Localizer Contrast:
% this is a two-part section. the first time you click, you will be asked 
% for an example SPM.mat file. this is effectively to get you to click
% through your desired task_results folder, giving it task information
% it then loads up contrast names for that task, and allows you to click 
% your desired contrast for viewing.
% 
% Reset: closes and reopens the GUI
% Begin: loads all of the paramaters, and implements roi_picker.m
%
% Written by Alek Chakroff, November 2009

% First time it starts, run makeGUI, otherwise, the gui calls itself with
% new input strings in the 'fcn' variable.
addpath(genpath('/software/spm8'));

if nargin == 0;fcn = 'makeGUI';end

switch fcn
    case 'makeGUI'
        plotinfo.myname = mfilename;%  roi_picker_gui, probably.
        plotinfo.switch = 0; %         used for contrast listbox

        % Matlab colors for titlebars and menus. change if you dare.
        colormat   = [.8 .8 .8]; labelcolor = [0 .2 .9];

        %==Main Figure
        fig = figure('Units','normalized','Position',[.1 .1 .8 .8],...
            'NumberTitle','off','menubar', 'none','Color','black');

        %==Title
        uicontrol(fig,'Style','text', 'String','Saxelab ROI Picker','fontsize',20, ...
            'HorizontalAlignment','Center','Units','normalized','Position',[0 .95 1 .05],...
            'BackgroundColor',labelcolor);

        %==Subjects
        uicontrol(fig,'Style','text','String','Subjects','fontsize',16,...
            'Units','normalized','Position',[.02 .9 .3 .03],'BackgroundColor',labelcolor);
        plotinfo.subbox=uicontrol(fig,'Style','listbox', 'String','Specify Directories...',...
            'Units','normalized','Position',[.02 .05 .3 .85],...
            'BackgroundColor',colormat, 'CallBack',[plotinfo.myname,' specify'] );

        %==ROI Chooser
        plotinfo.roi='RTPJ';
        uicontrol(fig,'Style','text','String','Pick a Region','fontsize',16,...
            'Units','normalized','Position',[.34 .9 .3 .03],'BackgroundColor',labelcolor);
        plotinfo.choose=uicontrol(fig,'Style','listbox', ...
            'String','Right TPJ|Left TPJ|Right STS|Left STS|Precuneus|Medial PFC|Dorsomedial PFC|Right IFG|Other',...
            'Units','normalized','Position',[.34 .15 .3 .75],...
            'BackgroundColor',colormat,'CallBack',[plotinfo.myname,' choose'] );
        
        %==Save button
        uicontrol(fig,'Style','Pushbutton', 'String','Save','fontsize',18,...
            'Units','normalized','Position',[.34 .03 .08 .1],...
            'BackgroundColor',colormat, 'CallBack',[plotinfo.myname,' save'] );
        
        %==Load button
        uicontrol(fig,'Style','Pushbutton', 'String','Load','fontsize',18,...
            'Units','normalized','Position',[.45 .03 .08 .1],...
            'BackgroundColor',colormat, 'CallBack',[plotinfo.myname,' load'] );
        

        %==Viewing Parameters
        uicontrol(fig,'Style','text','String','Viewing Parameters','fontsize',16,...
            'Units','normalized','Position',[.66 .9 .3 .03],'BackgroundColor',labelcolor);

        %==Threshold
        plotinfo.t=1;
        uicontrol(fig,'Style','text', 'String','Threshold','fontsize',14,...
            'Units','normalized','Position',[.66 .85 .15 .03],'BackgroundColor',colormat);
        plotinfo.tbox = uicontrol(fig,'Style','edit','String',plotinfo.t,...
            'Units','normalized','Position',[.82 .85 .14 .03],...
            'BackgroundColor',colormat);

        %==Cluster Size
        plotinfo.k=10;
        uicontrol(fig,'Style','text','String','Min Cluster Size (k)','fontsize',14,...
            'Units','normalized','Position',[.66 .8 .15 .03],'BackgroundColor',colormat);
        plotinfo.kbox = uicontrol(fig,'Style','edit','String',plotinfo.k,...
            'Units','normalized','Position',[.82 .8 .14 .03],...
            'BackgroundColor',colormat);

        %==Radius Size
        plotinfo.r=9;
        uicontrol(fig,'Style','text','String','Sphere Radius','fontsize',14,...
            'Units','normalized','Position',[.66 .75 .15 .03],'BackgroundColor',colormat);
        plotinfo.rbox = uicontrol(fig,'Style','edit','String',plotinfo.r,...
            'Units','normalized','Position',[.82 .75 .14 .03],...
            'BackgroundColor',colormat);

        % Contrast
        uicontrol(fig,'Style','text','String','Localizer Contrast','fontsize',16,...
            'Units','normalized','Position',[.66 .7 .3 .03],'BackgroundColor',labelcolor);
        plotinfo.cbox=uicontrol(fig,'Style','listbox', 'String','click to grab contrast names...',...
            'Units','normalized','Position',[.66 .15 .3 .55],...
            'BackgroundColor',colormat, 'CallBack',[plotinfo.myname,' contrasts'] );

        %==Reset button
        uicontrol(fig,'Style','Pushbutton', 'String','Reset','fontsize',18,...
            'Units','normalized','Position',[.56 .03 .08 .1],...
            'BackgroundColor',[.9 0 0], 'CallBack',[plotinfo.myname,' reset'] );

        %==Begin button
        uicontrol(fig,'Style','Pushbutton', 'String','Begin!','fontsize',18,...
            'Units','normalized','Position',[.66 .03 .3 .1],...
            'BackgroundColor',[0 .9 0], 'CallBack',[plotinfo.myname,' begin'] );

        %put all the variables in a safe place
        set(fig,'UserData',plotinfo);
        roi_struct_picker_gui('choose');

    case 'choose'
        plotinfo=get(gcf,'UserData'); % data saved in the figure. only plotinfo persists
        plotinfo.roi=get(plotinfo.choose,'value');
        switch plotinfo.roi
            case 1;  plotinfo.roi='RTPJ';  plotinfo.roi_xyz = load('/younglab/roi_library/functional/RTPJ_xyz');
            case 2;  plotinfo.roi='LTPJ';  plotinfo.roi_xyz = load('/younglab/roi_library/functional/LTPJ_xyz');
            case 3;  plotinfo.roi='RSTS';  plotinfo.roi_xyz = load('/younglab/roi_library/functional/RSTS_xyz');
            case 4;  plotinfo.roi='LSTS';  plotinfo.roi_xyz = load('/younglab/roi_library/functional/LSTS_xyz');
            case 5;  plotinfo.roi='PC';    plotinfo.roi_xyz = load('/younglab/roi_library/functional/PC_xyz');
            case 6;  plotinfo.roi='MMPFC'; plotinfo.roi_xyz = load('/younglab/roi_library/functional/MMPFC_xyz');
            case 7;  plotinfo.roi='DMPFC'; plotinfo.roi_xyz = load('/younglab/roi_library/functional/DMPFC_xyz');
            case 8;  plotinfo.roi='RIFG';  plotinfo.roi_xyz = load('/younglab/roi_library/functional/RIFG_xyz');
            case 9;
                answer = questdlg('How Would you like to find an initial ROI peak?', 'ROI Specification','ROI Image','Coordinates','ROI Image');
                if strcmp(answer,'ROI Image')
                    t                = inputdlg('Enter an ROI Name'); 
                    plotinfo.roi     = t{1};
                    f                = spm_select(1,'mat',['Choose a coordinates file for ' t{1}],'','/younglab/roi_library','.*',1);
                    plotinfo.roi_xyz = load(f);% array
                else
                    t=inputdlg({'ROI Name','Coordinates'},'ROI Info',1,{'','0 0 0'});
                    plotinfo.roi             = t{1}; 
                    plotinfo.roi_xyz.roi_xyz = t{2}; % string
                end

                set(plotinfo.choose,'string',sprintf(...
                    'Right TPJ|Left TPJ|Right STS|Left STS|Precuneus|Medial PFC|Dorsomedial PFC|Right IFG|%s',...
                    plotinfo.roi));
        end
        set(gcf,'UserData',plotinfo);% save it for use by the next callback

    case 'specify'
        plotinfo=get(gcf,'UserData');
        plotinfo.subjects = spm_select(Inf,'dir','Choose subject directories for ROI Picking','','/younglab/studies','.*',1);
        
        % populate the listbox with subject names, for reassurance
        set(plotinfo.subbox,'string',plotinfo.subjects(:,size(plotinfo.subjects,2)-16:size(plotinfo.subjects,2)));
        set(gcf,'UserData',plotinfo);

    case 'contrasts'
        plotinfo=get(gcf,'UserData');
        if plotinfo.switch == 0 % if this is the first time choosing this option
            try
                spmcon = spm_select(1,'mat','Choose an example SPM.mat file to load contrast names','',plotinfo.subjects(1,:),'.*',1);
            catch
                warndlg('You must Choose Subjects First!');
            end
            
            % grab results path in a really complicated fashion
            temp1 = strread(spmcon,'%s','delimiter','/');temp2 = strread(plotinfo.subjects(1,:),'%s','delimiter','/');
            [temp3 j] = setdiff(temp1,temp2);plotinfo.res_dir = '/';
            [j x] = sort(j);temp3 = temp3(x);
            for i=1:length(temp3)-1 %count down from last to two
                plotinfo.res_dir = [plotinfo.res_dir temp3{i} '/'];
            end
            
            % now load up contrast names
            load(spmcon);
            for i=1:length(SPM.xCon); name{i} = SPM.xCon(i).name;
            end
            name = char(name); set(plotinfo.cbox,'string',name);
            plotinfo.switch = 1;plotinfo.c=1;
        else % just choose between contrast names
            plotinfo.c=get(plotinfo.cbox,'value');
        end
        set(gcf,'UserData',plotinfo);
        
    case 'save'
        plotinfo = get(gcf,'UserData');
        cmt  = inputdlg('Optional session name:');
        saveas(gcf,['/younglab/scripts/roi_picker_sessions/sessions-' cmt{1} '-' plotinfo.roi '-' date '.fig'],'fig');
        
    case 'load'
        cur_fig = spm_select(1,'any','Choose subject directories for ROI Picking','','/younglab/scripts/roi_picker_sessions','.*',1);
        close(gcf);open(cur_fig);
        
    case 'reset'
        close(gcf); eval([mfilename ' makeGUI']);

    case 'begin'
%          try
            plotinfo = get(gcf,'UserData');
            res_dir  = plotinfo.res_dir;
            t        = str2double(get(plotinfo.tbox,'string'));
            k        = str2double(get(plotinfo.kbox,'string'));
            r        = str2double(get(plotinfo.rbox,'string'));
            c        = plotinfo.c;
            roi      = plotinfo.roi;
            roi_xyz  = plotinfo.roi_xyz.roi_xyz;
            if size(roi_xyz,2) == length(roi_xyz);roi_xyz = roi_xyz';end
            subjects = plotinfo.subjects;
            roi_struct_picker(t,k,r,c,roi,roi_xyz,cellstr(subjects),res_dir);
%         catch
%             warndlg('There was an error loading the parameters into the script. Make sure all fields are filled in correctly!');
%         end
end