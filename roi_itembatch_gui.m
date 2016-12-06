function roi_batch_gui(fcn)
addpath(genpath('/software/spm8'));
if nargin == 0;fcn = 'makeGUI';end

switch fcn
    case 'makeGUI'
        plotinfo.myname = mfilename;
        plotinfo.switch = 0; %used for contrast listbox

        colormat   = [.8 .8 .8]; labelcolor = [0 .2 .9];

        %==Main Figure
        fig = figure('Units','normalized','Position',[.1 .1 .8 .8],...
            'NumberTitle','off','menubar', 'none','Color','black');

        %==Title
        uicontrol(fig,'Style','text', 'String','Younglab ROI Batch','fontsize',20, ...
            'HorizontalAlignment','Center','Units','normalized','Position',[0 .95 1 .05],...
            'BackgroundColor',labelcolor);

        %==Subjects button
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
            'String','Right TPJ|Left TPJ|Right STS|Left STS|Precuneus|Medial PFC|Dorsomedial PFC|Right IFG|Group ROI|Other',...
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

        %====================================
        %==Other Parameters
        uicontrol(fig,'Style','text','String','ROI Extraction Parameters','fontsize',16,...
            'Units','normalized','Position',[.66 .9 .3 .03],'BackgroundColor',labelcolor);

        %==Window
        plotinfo.win=40;
        uicontrol(fig,'Style','text', 'String','Time Window (secs)','fontsize',12,...
            'Units','normalized','Position',[.66 .85 .15 .03],'BackgroundColor',colormat);
        plotinfo.winbox = uicontrol(fig,'Style','edit','String',plotinfo.win,...
            'Units','normalized','Position',[.82 .85 .14 .03],...
            'BackgroundColor',colormat);

        %==Offset Delay
        plotinfo.ons=6;
        uicontrol(fig,'Style','text','String','Offset Delay (secs)','fontsize',12,...
            'Units','normalized','Position',[.66 .8 .15 .03],'BackgroundColor',colormat);
        plotinfo.onsbox = uicontrol(fig,'Style','edit','String',plotinfo.ons,...
            'Units','normalized','Position',[.82 .8 .14 .03],...
            'BackgroundColor',colormat);

        %==Highpass
        uicontrol(fig,'Style','text','String','Highpass Filter','fontsize',12,...
            'Units','normalized','Position',[.66 .75 .15 .03],'BackgroundColor',colormat);
        plotinfo.hpbox = uicontrol(fig,'Style','Checkbox','Value',0,...
            'Units','normalized','Position',[.82 .75 .03 .04],...
            'BackgroundColor','k');

        %================================
        % Window Averages
        uicontrol(fig,'Style','text','String','Mean Responses','fontsize',16,...
            'Units','normalized','Position',[.66 .7 .3 .03],'BackgroundColor',labelcolor);

        uicontrol(fig,'Style','text','String','To generate mean responses for one or more time windows, input here in seconds. e.g. 6:10;15:21 . Don''t exceed Time Window!',...
            'Units','normalized','Position',[.66 .6 .3 .1],'BackgroundColor',colormat);

        plotinfo.ampbox = uicontrol(fig,'Style','edit','string','6:26',...
            'Units','normalized','Position',[.66 .5 .3 .1],...
            'BackgroundColor',colormat);

        %================================
        % Task file selector
        uicontrol(fig,'Style','text','String','Task file','fontsize',16,...
            'Units','normalized','Position',[.66 .45 .3 .03],'BackgroundColor',labelcolor);
        plotinfo.tbox=uicontrol(fig,'Style','listbox', 'String','click to grab example SPM.mat...',...
            'Units','normalized','Position',[.66 .37 .3 .08],...
            'BackgroundColor',colormat, 'CallBack',[plotinfo.myname,' task'] );

        % Localizer file selector
        uicontrol(fig,'Style','text','String','Localizer file','fontsize',16,...
            'Units','normalized','Position',[.66 .32 .3 .03],'BackgroundColor',labelcolor);
        plotinfo.lbox=uicontrol(fig,'Style','listbox', 'String','click to grab example SPM.mat...',...
            'Units','normalized','Position',[.66 .24 .3 .08],...
            'BackgroundColor',colormat, 'CallBack',[plotinfo.myname,' localizer'] );
        
        % Localizer file contrast selector
        uicontrol(fig,'Style','text','String','Enter the contrast number of the localizer task (e.g., 1)',...
            'Units','normalized','Position',[.66 .19 .3 .03],'BackgroundColor',colormat);
        plotinfo.conbox = uicontrol(fig,'Style','edit','string','1',...
            'Units','normalized','Position',[.66 .15 .3 .05],...
            'BackgroundColor',colormat);

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

    case 'choose'
        plotinfo=get(gcf,'UserData');
        plotinfo.roi=get(plotinfo.choose,'value');
        switch plotinfo.roi
            case 1;  plotinfo.roi='RTPJ';
            case 2;  plotinfo.roi='LTPJ';
            case 3;  plotinfo.roi='RSTS';
            case 4;  plotinfo.roi='LSTS';
            case 5;  plotinfo.roi='PC';
            case 6;  plotinfo.roi='MMPFC';
            case 7;  plotinfo.roi='DMPFC';
            case 8;  plotinfo.roi='RIFG';
            case 9;  plotinfo.roi='GROUP';plotinfo.loc_dir = 'none';
            case 10;
                t = inputdlg('Enter an ROI Name'); plotinfo.roi = t{1};
                set(plotinfo.choose,'string',sprintf(...
                    'Right TPJ|Left TPJ|Right STS|Left STS|Precuneus|Medial PFC|Dorsomedial PFC|Right IFG|Group ROI|%s',...
                    plotinfo.roi));
        end
        set(gcf,'UserData',plotinfo);

    case 'specify'
        plotinfo=get(gcf,'UserData');
        % Pop up to select subjects
        plotinfo.subjects = spm_select(Inf,'dir','Choose subject directories for ROI Analysis','','/home/younglw/studies','.*',1);
        % populate the listbox with subject names, for reassurance
        set(plotinfo.subbox,'string',plotinfo.subjects(:,size(plotinfo.subjects,2)-16:size(plotinfo.subjects,2)));
        set(gcf,'UserData',plotinfo);

    case 'task'
%         try
            plotinfo=get(gcf,'UserData');
            spmcon = spm_select(1,'mat','Choose a Task SPM.mat file...','',plotinfo.subjects(1,:),'.*',1);

            % grab results path in a really complicated fashion
            temp1 = strread(spmcon,'%s','delimiter','/');temp2 = strread(plotinfo.subjects(1,:),'%s','delimiter','/');
            [temp3 j] = setdiff(temp1,temp2);plotinfo.task_dir = '/';
            [j x] = sort(j);temp3 = temp3(x);
            for i=1:length(temp3)-1
                plotinfo.task_dir = [plotinfo.task_dir temp3{i} '/'];
            end
            set(plotinfo.tbox,'string',spmcon);set(gcf,'UserData',plotinfo);

%         catch
%             warndlg('You must Choose Subjects First!');
%         end
    case 'localizer'
        try
            plotinfo=get(gcf,'UserData');
            spmcon = spm_select(1,'mat','Choose a Localizer SPM.mat file...','',plotinfo.subjects(1,:),'.*',1);

            % grab results path in a really complicated fashion
            temp1 = strread(spmcon,'%s','delimiter','/');temp2 = strread(plotinfo.subjects(1,:),'%s','delimiter','/');
            [temp3 j] = setdiff(temp1,temp2);plotinfo.loc_dir = '/';
            [j x] = sort(j);temp3 = temp3(x);
            for i=1:length(temp3)-1
                plotinfo.loc_dir = [plotinfo.loc_dir temp3{i} '/'];
            end
            set(plotinfo.lbox,'string',spmcon);set(gcf,'UserData',plotinfo);

        catch
            warndlg('You must Choose Subjects First!');
        end
        
     case 'save'
        plotinfo = get(gcf,'UserData');
        cmt  = inputdlg('Optional session name:');
        saveas(gcf,['/home/younglw/scripts/roi_batch_sessions/sessions-' cmt{1} '-' plotinfo.roi '-' date '.fig'],'fig');
        
    case 'load'
        cur_fig = spm_select(1,'any','Choose subject directories for ROI Picking','','/home/younglws/studies/scripts/roi_batch_sessions','.*',1);
        close(gcf);open(cur_fig);
        
    case 'reset'

        close(gcf)
        eval([mfilename ' makeGUI']);

    case 'begin'
        plotinfo = get(gcf,'UserData');
        subjects = plotinfo.subjects;
        task_dir = plotinfo.task_dir;
        loc_dir  = plotinfo.loc_dir;
        win      = str2double(get(plotinfo.winbox,'string'));
        ons      = str2double(get(plotinfo.onsbox,'string'));
        amp      = get(plotinfo.ampbox,'string');
        con      = get(plotinfo.conbox,'string');
        if (get(plotinfo.hpbox,'Value') == get(plotinfo.hpbox,'Max')); hp=1;
        else hp=0;
        end
        roi      = plotinfo.roi;
        sprintf('roi_batch({''%s''}',subjects)
        call = sprintf('roi_batch({''%s''},''%s'', ''%s'', ''%s'', %s, %s, %s, ''%s'');',subjects,roi,task_dir,loc_dir,get(plotinfo.winbox,'string'),get(plotinfo.onsbox,'string'),num2str(hp),get(plotinfo.ampbox,'string'));
        disp('Your function call is:')

        
        roi_batch_itemwise(cellstr(subjects),roi, task_dir, loc_dir, con, win, ons, hp, amp);
end