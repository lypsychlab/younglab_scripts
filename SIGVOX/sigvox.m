function varargout = sigvox(varargin)
%sigvox_figure.m
%A gui for exploring image files and plotting single voxel signal intensity
%over time. While sigvox_figure will open any image file, it is designed primarily
%to work with the SNR_SD scripts for calculating standard deviation and SnR
%maps on a run by run basis. Furthermore, it is designed with the file and
%directory conventions of the DBIC for finding the swrabold files which are
%used to extract signal intensity for each volume of a run.
%
%At present (March.2008) sigvox_figure will only display the mean of the signal
%intensity over the course of a run. Future iterations will, hopefully,
%also show signal intensity in terms of z-scores away from the mean for
%that voxel wich should aid in finding transient artifacts.
%
%DDW.2008.03.14
%--------------------------------------------------------------------------
%Change log
%-
%
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sigvox_OpeningFcn, ...
                   'gui_OutputFcn',  @sigvox_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before sigvox_figure is made visible.
function sigvox_OpeningFcn(hObject, eventdata, handles, varargin)

    %Turn on spm defaults
        spm_defaults_lily;

    %Turn off warnings
        warning off MATLAB:divideByZero;
        %warning off

    if length(varargin)==0     
    %VARIABLES - Init starting vars
        handles.root_dir = '/home/younglw';
        handles.current_dir = pwd;
        handles.study = [];
        handles.functional_dir = 'bold';
        handles.subj = [];
        handles.run = [];
    
        handles.data_dir = [handles.root_dir,handles.study,'/',handles.subj,'/',handles.functional_dir,'/'];
        handles.boldfile = [];

        handles.xsize= [];
        handles.ysize= [];
        handles.zsize= [];
    
        handles.cmap = load('x_hot.txt');
        handles.voxel = [27;40;25]; %starting voxels, corresponds to the origin of most normalized data

        %RADIO BUTTONS -- set radio buttons to their default state
        set(handles.SigPlotSig,'Value',1);
        set(handles.SigPlotZ,'Value',0);
        set(handles.MovePlotP,'Value',1);
        set(handles.MovePlotDiff,'Value',0);
        
        %LISTBOX
        handles.start_dir = '/home/younglw'; %change this if you want your start dir to be a specific folder (ie: the matlab work folder)
        handles.current_dir = handles.start_dir;
        %INFOBOXES -- Not used yet
        
        %Plot graphs
        init_jpegs(handles);
        load_listbox(handles.start_dir, handles);
        graph_hider('hide', handles);
        %image_viewer(handles);
        %signal_graph(handles);
        %mvmt_graph(handles);      
            
        %Update handles structure
        guidata(hObject, handles); 
        
    elseif length(varargin)~=0
        if strcmp(varargin{1},'movecrossCoronal')
            movecross(handles, 'coronal');
        elseif strcmp(varargin{1},'movecrossSagital')
            movecross(handles, 'sagital');
        elseif strcmp(varargin{1},'movecrossAxial')
            movecross(handles, 'axial');
        end
    end    
return

%--- Hide/Unhide Graphic Axes
function graph_hider(hidestate, handles)
    switch(hidestate)
        case 'hide'
            set(handles.Coronal, 'Visible', 'off');
            set(handles.Sagital, 'Visible', 'off');
            set(handles.Axial, 'Visible', 'off');
            set(handles.Signal, 'Visible', 'off');
            set(handles.Movement, 'Visible', 'off');
        case 'unhide'
            set(handles.Coronal, 'Visible', 'on');
            set(handles.Sagital, 'Visible', 'on');
            set(handles.Axial, 'Visible', 'on');
            set(handles.Signal, 'Visible', 'on');
            set(handles.Movement, 'Visible', 'on');
    end
return        

%--- Adds the jpegs to the axes.
function init_jpegs(handles)
    titleimg = imread('title_unix.jpg');
    upiconimg = imread('upicon.jpg');
    axes(handles.title);
    image(titleimg);
    set(handles.title, 'Visible', 'off', 'Units', 'pixels', 'Position', [2 540 1075 50]);
    set(handles.upicon,'CData',upiconimg);
return

% --- Outputs from this function are returned to the command line.
function varargout = sigvox_OutputFcn(hObject, eventdata, handles)
      %FILE BROWSER - populates the file browser
%     %load_listbox(handles.start_dir, handles); %calls the custom load_listbox function which is defined elsewhere
return

function load_listbox(dir_path,handles) 
    % --- Listbox function to load files into listbox. 
    % --- The listbox will display only folders if there are no img files
    % --- in current folder.
    %Big epic kludge to make it load only snr files under the average, sd
    %and snr folders. Try to make this not so daft in future.
    if strfind(dir_path, 'BOLD') >= 1
        img_only = dir([dir_path,'/','*.img']);
    else
        img_only = '';
    end
    if isempty(img_only)
        dir_only = dir(dir_path);
        dir_only([dir_only.isdir] == 0)=[];  %eliminates files from the dir_only array
        dir_only(1:2.0)=[]; %eliminates the . and .. from the dir_only array
        [sorted_dirnames, sorted_dirindex] = sortrows({dir_only.name}'); %sorts the folders by name 
        handles.dir_names = sorted_dirnames;
        handles.dirindex = sorted_dirindex;
        handles.dirindexsize = length(sorted_dirindex); %gets the size of the dir to later pass onto the listbox callback for determining if selection is file or dir
        handles.sorted_index = [sorted_dirindex]; %the listbox index is set to that of the folder.
        handles.file_names = sorted_dirnames; %the listbox displays only the folder names
    else
        [sorted_filenames, sorted_fileindex] = sortrows({img_only.name}');
        handles.file_names = sorted_filenames;
        handles.fileindex = sorted_fileindex;
    end       
    set(handles.listbox_filebrowser,'String',handles.file_names,'Value',1);
    set(handles.currentpath,'String',handles.current_dir);
    guidata(handles.Sigvox_Figure,handles);
return
    
% --- Executes on selection change in listbox_filebrowser.    
function varargout = listbox_filebrowser_Callback(h, eventdata, handles, varargin)   
    %filebrowser listbox -- 
    if strcmp(get(handles.Sigvox_Figure,'SelectionType'),'open') % If double click
        index_selected = get(handles.listbox_filebrowser,'Value');
        file_list = get(handles.listbox_filebrowser,'String');
        filename = file_list{index_selected}; % Item selected in list box  
        if isdir([handles.current_dir,'/',filename])  
            handles.current_dir = [handles.current_dir,'/',filename];
            load_listbox(handles.current_dir,handles) % Load list box with new directory
        else
            %figuring out filenames (some kludges because of inconsistant
            %naming)
            
            handles.snr_dir = handles.current_dir;
            handles.run = filename((strfind(filename,'run'))+3:(strfind(filename,'run'))+5);             
            handles.snrfile = filename;
            
            if strfind(handles.snr_dir,'_AVERAGE') >= 1
                superkludge = '_average';
            elseif strfind(handles.snr_dir,'_SD') >= 1
                superkludge = '_sd';
            elseif strfind(handles.snr_dir,'_SNR') >=1
                superkludge = '_snr';
            else
                msg2='EPIC FAIL! It appears that jazz is dead!';
                error(msg2)
            end

            handles.subj = filename(1:(strfind(filename,superkludge)-1));
            underscores = strfind(handles.subj,'_');
            handles.study = handles.subj(underscores(1)+1:underscores(2)-1);
            handles.data_dir = [handles.root_dir,'/',handles.study,'/',handles.subj,'/',handles.functional_dir,'/',handles.run,'/'];
            handles.boldfile = 'swraf.+.img';

            %load graphs
            image_viewer(handles);
            signal_graph(handles);
            mvmt_graph(handles);
            guidata(handles.Sigvox_Figure,handles);
        end
    end
return
    
% --- Executes on button press in upicon.
function upicon_Callback(hObject, eventdata, handles)
    goback=findstr(handles.current_dir,'/');
    goback=max(goback);
    handles.current_dir=handles.current_dir(1:goback-1);
    load_listbox(handles.current_dir,handles) % Load list box with new directory
return  
    
% --- Plots graph during gui creation. Maybe attach a button later to
% replot as z-scores or some other metric.
function signal_graph(handles)
    cd(handles.data_dir);
    V = spm_select('list',handles.data_dir,handles.boldfile);
    if isempty(V) == 1  
        msg1=['EPIC FAIL! It appears the subject ', handles.subj, ' has not yet been preprocessed with spm8.' ...
            'SIGVOX does not yet work on raw images'];
        error(msg1)
    end
    disp('Extracting signal at specified voxel:')
    for i = 1:length(V)        
        voxdata(i) = spm_get_data(V(i,:),handles.voxel);
        if i/100 == round(i/60)
             fprintf ('\n')
        end
        fprintf ('.')
    end
    fprintf('done')
    disp(' ')
    axes(handles.Signal);
    cla;
    
    %Plot voxdata or plot z-scores?
    if get(handles.SigPlotSig,'Value') == 1
        plot(voxdata);
        l=ylabel('\fontsize{9} signal');
        set(l,'VerticalAlignment','Bottom');
    else
        plot(zscore(voxdata));
        l=ylabel('\fontsize{9} zscore');
        set(l,'VerticalAlignment','Bottom');
        set(gca,'YLim',[-4,4]);
    end  
    h = gca;
    set(h,'Ygrid','on');
    axes_lim = get(gca, 'YLim');
    %set(gca,'YLim',[-abs(max(axes_lim)),abs(max(axes_lim))]);
    axes_height = axes_lim;
    set(gca,'FontSize',8);    
    
    %Fill out info box
    set(handles.InfoVoxel,'String',num2str([handles.voxel(1),handles.voxel(2),handles.voxel(3)]));
    set(handles.InfoMean,'String',mean(voxdata));
    set(handles.InfoTR,'String',length(voxdata));
    set(handles.InfoSD,'String',std(voxdata));
    set(handles.InfoSNR,'String',(mean(voxdata)/(std(voxdata))));
    set(handles.InfoMin,'String',[num2str(round(min(voxdata))),' / ',num2str(round(max(voxdata)))]);
    
    return    
    
% --- Plots graph during gui creation. Maybe attach a button later to
% replot as difference rather than absolute movement.
function mvmt_graph(handles) 
    cd(handles.data_dir);
    mvmt_file = spm_select('list',handles.data_dir,'rp_a.+-01.txt');
    if isempty(mvmt_file) == 1  
        mvmt_file = spm_select('list',handles.data_dir,'rp_.+-01.txt');
    end
    mvmt_params =load(mvmt_file);
    axes(handles.Movement);
    cla;
   
    %Plot params or difference?
    if get(handles.MovePlotP,'Value') == 1
        plot(mvmt_params(:,1:3));
        l=ylabel('\fontsize{9} movement (mm)');
        set(l,'VerticalAlignment','Bottom');
        l=legend('x', 'y', 'z');
        h = gca;
        set(h,'Ygrid','on');
        axes_lim = get(gca, 'YLim');
        set(gca,'YLim',[-abs(max(axes_lim)),abs(max(axes_lim))]);
        axes_height = axes_lim;
        set(gca,'FontSize',8);
    else
        tmp = mvmt_params;
        tmp(2:end,1:3) = abs(mvmt_params(2:end,1:3) - mvmt_params(1:end-1,1:3));
        plot(tmp);
        l=ylabel('\fontsize{9} movement diff (mm)');
        set(l,'VerticalAlignment','Bottom');
         l=legend('x', 'y', 'z');
        h = gca;
        set(h,'Ygrid','on');
        axes_lim = get(gca, 'YLim');
        set(gca,'YLim',[0,1]);
        %set(gca,'YLim',[0,abs(max(axes_lim))]);
        axes_height = axes_lim;
        set(gca,'FontSize',8);
    end  
    
   
return
    
% --- Load up the image files and display in orthogonal views.
function image_viewer(handles)
   cd(handles.snr_dir);
   handles.data_snr = spm_read_vols(spm_vol(spm_select('list',handles.snr_dir,handles.snrfile)));
   plot_brain(handles.voxel(1),handles.voxel(2),handles.voxel(3),handles)
   handles.xsize=size(handles.data_snr,1);
   handles.ysize=size(handles.data_snr,2);
   handles.zsize=size(handles.data_snr,3);
   initcrosses(handles.xsize,handles.ysize,handles.zsize);
   guidata(handles.Sigvox_Figure,handles);

function plot_brain(x,y,z,handles)
    coronal=squeeze(handles.data_snr(:,y,:));
    axial=squeeze(handles.data_snr(:,:,z));
    sagital=squeeze(handles.data_snr(x,:,:));
    axes(handles.Coronal);
   % subplot(1,3,1);
    imagesc(fliplr(rot90(coronal)));
    xz=tidyaxis(1,'coronal_graph',handles);
    axes(handles.Sagital);
    %subplot(1,3,2);
    imagesc(fliplr(flipud(sagital')));
    yz=tidyaxis(2,'sagital_graph',handles);
   axes(handles.Axial);
    %subplot(1,3,3);
    imagesc(fliplr(rot90(axial)));
    xy=tidyaxis(3,'axial_graph',handles);
    guidata(handles.Sigvox_Figure,handles);

function ax=tidyaxis(type,tagstr,handles)
  global cmap
  
  %get the current axis
  ax=gca;
  %change colormap to col_map
  colormap(handles.cmap);
  %axis cosmetics!
  axis equal
  axis off

  set(ax,'tag',tagstr);
  
  switch(type)
      case 1
          set(get(ax,'children'),'ButtonDownFcn','sigvox(''movecrossCoronal'')');
      case 2
          set(get(ax,'children'),'ButtonDownFcn','sigvox(''movecrossSagital'')');
      case 3
          set(get(ax,'children'),'ButtonDownFcn','sigvox(''movecrossAxial'')');
  end
  
return;

function initcrosses(xsi,ysi,zsi);

  x=round(xsi/2);
  y=round(ysi/2);
  z=round(zsi/2);

  % draw axial cross
  ca=findobj('Tag','coronal_graph');
  set(gcf,'CurrentAxes',ca);
  setcross(x,z,'xzcross');

   % redraw yz cross
  ca=findobj('Tag','sagital_graph');
  set(gcf,'CurrentAxes',ca);
  setcross(y,z,'yzcross');

  % redraw yz cross
  ca=findobj('Tag','axial_graph');
  set(gcf,'CurrentAxes',ca);
  setcross(x,y,'xycross');

function movecross(handles,orientation);
    
    switch(orientation)
        case('coronal')
            currentfig = 'handles.Coronal';
        case('sagital')
            currentfig = 'handles.Sagital';
        case('axial')
            currentfig = 'handles.Axial';
    end
 ax=get(eval(currentfig));
%  pos=gcp(ax)
 pos=get(eval(currentfig),'currentpoint')  ;
 pos=pos(1,1:2);

  tag=get(eval(currentfig),'tag');
  
  x=get(findobj('Tag','xycrossy'),'xdata');x=x(1);
  y=get(findobj('Tag','yzcrossx'),'ydata');y=y(1);
  z=get(findobj('Tag','xzcrossx'),'ydata');z=z(1);
  x=round(x);
  y=round(y);
  z=round(z);

%   ymax=get(findobj('Tag','coronal_graph'),'ylim');
%   ymax=max(round(ymax));

  switch(tag)
   case 'coronal_graph',
    x=pos(1);
    z=pos(2);
   case 'sagital_graph',
    y=pos(1);
    z=pos(2);
   case 'axial_graph',
    x=pos(1);
    y=pos(2);
  end

  x=round(x);
  y=round(y);
  z=round(z);
  
  %replot brain
  handles.voxel=[abs(x-54);abs(y-66);abs(z-55)];
  image_viewer(handles);
  
  %replot signal graph
  signal_graph(handles);
  
  %plot_brain(abs(x-54),abs(y-66),abs(z-55),handles);
  
  % redraw xy cross
  ca=findobj('Tag','coronal_graph');
  set(gcf,'CurrentAxes',ca);
  setcross(x,z,'xzcross');

  % redraw yz cross
  ca=findobj('Tag','sagital_graph');
  set(gcf,'CurrentAxes',ca);
  setcross(y,z,'yzcross');

  % redraw xz cross
  ca=findobj('Tag','axial_graph');
  set(gcf,'CurrentAxes',ca);
  setcross(x,y,'xycross');

  % rewrite button
  %set(findobj('tag','currentposition'),'string', ...
  %           sprintf('%d %d %d',abs(x-54),abs(y-66),abs(z-55)));
  
  
% function pos=gcp(ax,handle)
%   pos=get(gca,'currentpoint');
%   pos=pos(1,1:2)
%   
function setcross(pos1,pos2,tagline);
  x_size = 3;
  delete(findobj('tag',[tagline 'x']))
  delete(findobj('tag',[tagline 'y']))
  line([pos1-x_size pos1+x_size],[pos2 pos2],'color',[0.6 1 0.6], 'linewidth',1,'tag',[tagline 'x']);
  line([pos1 pos1],[pos2-x_size pos2+x_size],'color',[0.6 1 0.6], 'linewidth',1,'tag',[tagline 'y']);
 
 
 %     snr_file = spm_get('files','C:\[MATLAB]\work\SIGVOX\SNR\SWUABOLD_SD\','09jan08lh_sd_run1.img');
%     if isempty(snr_file) == 1  
%         msg2=['EPIC FAIL! It appears the subject ', handles.subj, ' is hAXored. Please dont tease.'];
%         error(msg2)
%     end
%     data_snr = spm_read_vols(spm_vol(snr_file));
%     %Slices
%     axial=squeeze(data_snr(:,:,20));
%     sagital=squeeze(data_snr(26,:,:));
%     coronal=squeeze(data_snr(:,32,:));
%     %colormap
%     colormap(load('x_hot.txt'));
%     %friendlier scaling (autoscale looses too much of the low values)
%     axial_scale = [min(min(axial)),(max(max(axial))-(max(max(axial))/100*30))];
%     sagital_scale = [min(min(sagital)),(max(max(sagital))-(max(max(sagital))/100*30))];
%     coronal_scale = [min(min(coronal)),(max(max(coronal))-(max(max(coronal))/100*30))];
%     %Set buttondown function
%     set(handles.Axial,'ButtonDownFcn','sigvox(''movecross'')');
%     %Setup axes
%     axes(handles.Axial);
%     imagesc(flipud(axial'),axial_scale)
%     hold on
%     axis equal
%     axis off
%     axes(handles.Sagital);
%     imagesc(flipud(sagital'),axial_scale)
%     hold on
%     axis equal
%     axis off
%     axes(handles.Coronal);
%     imagesc(flipud(coronal'),axial_scale)
%     hold on
%     axis equal
%     axis off 
    

% --- Load up the image files and display in orthogonal views.
% function image_viewer_Callback(hObject, eventdata, handles)
%     snr_file = spm_get('files','C:\[MATLAB]\work\SIGVOX\SNR\SWUABOLD_SD\','09jan08lh_sd_run1.img');
%     if isempty(snr_file) == 1  
%         msg2=['EPIC FAIL! It appears the subject ', handles.subj, ' is hAXored. Please dont tease.'];
%         error(msg2)
%     end
%     data_snr = spm_read_vols(spm_vol(snr_file));
%     %Slices
%     axial=squeeze(data_snr(:,:,20));
%     sagital=squeeze(data_snr(26,:,:));
%     coronal=squeeze(data_snr(:,32,:));
%     %colormap
%     colormap(load('x_hot.txt'));
%     %friendlier scaling (autoscale looses too much of the low values)
%     axial_scale = [min(min(axial)),(max(max(axial))-(max(max(axial))/100*30))];
%     sagital_scale = [min(min(sagital)),(max(max(sagital))-(max(max(sagital))/100*30))];
%     coronal_scale = [min(min(coronal)),(max(max(coronal))-(max(max(coronal))/100*30))];
%     %Set buttondown function
%     set(handles.Axial,'ButtonDownFcn','sigvox(''movecross'')');
%     %Setup axes
%     axes(handles.Axial);
%     imagesc(flipud(axial'),axial_scale)
%     hold on
%     axis equal
%     axis off
%     axes(handles.Sagital);
%     imagesc(flipud(sagital'),axial_scale)
%     hold on
%     axis equal
%     axis off
%     axes(handles.Coronal);
%     imagesc(flipud(coronal'),axial_scale)
%     hold on
%     axis equal
%     axis off
















        
% --- Executes during object creation, after setting all properties.
function listbox_filebrowser_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on button press in SigPlotSig.
function SigPlotSig_Callback(hObject, eventdata, handles)
% hObject    handle to SigPlotSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SigPlotSig
if get(handles.SigPlotZ,'Value') == 1
    set(handles.SigPlotSig,'Value',1);
    set(handles.SigPlotZ,'Value',0);
    signal_graph(handles);
end
 
% --- Executes on button press in SigPlotZ.
function SigPlotZ_Callback(hObject, eventdata, handles)
% hObject    handle to SigPlotZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SigPlotZ
if get(handles.SigPlotSig,'Value') == 1
    set(handles.SigPlotSig,'Value',0);
    set(handles.SigPlotZ,'Value',1);
    signal_graph(handles);
end
 


% --- Executes on button press in MovePlotDiff.
function MovePlotDiff_Callback(hObject, eventdata, handles)
% hObject    handle to MovePlotDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MovePlotDiff
if get(handles.MovePlotP,'Value') == 1
    set(handles.MovePlotDiff,'Value',1);
    set(handles.MovePlotP,'Value',0);
    mvmt_graph(handles);
end

% --- Executes during object creation, after setting all properties.
function InfoVoxel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoVoxel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function InfoVoxel_Callback(hObject, eventdata, handles)
% hObject    handle to InfoVoxel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoVoxel as text
%        str2double(get(hObject,'String')) returns contents of InfoVoxel as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function InfoMean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function InfoMean_Callback(hObject, eventdata, handles)
% hObject    handle to InfoMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoMean as text
%        str2double(get(hObject,'String')) returns contents of InfoMean as a double


% --- Executes during object creation, after setting all properties.
function InfoTR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function InfoTR_Callback(hObject, eventdata, handles)
% hObject    handle to InfoTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoTR as text
%        str2double(get(hObject,'String')) returns contents of InfoTR as a double


% --- Executes during object creation, after setting all properties.
function InfoSD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function InfoSD_Callback(hObject, eventdata, handles)
% hObject    handle to InfoSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoSD as text
%        str2double(get(hObject,'String')) returns contents of InfoSD as a double


% --- Executes during object creation, after setting all properties.
function InfoSNR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function InfoSNR_Callback(hObject, eventdata, handles)
% hObject    handle to InfoSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoSNR as text
%        str2double(get(hObject,'String')) returns contents of InfoSNR as a double


% --- Executes on button press in MovePlotP.
function MovePlotP_Callback(hObject, eventdata, handles)
% hObject    handle to MovePlotP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MovePlotP
if get(handles.MovePlotDiff,'Value') == 1
    set(handles.MovePlotP,'Value',1);
    set(handles.MovePlotDiff,'Value',0);
     mvmt_graph(handles);
end

        

% --- Executes during object creation, after setting all properties.
function InfoMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function InfoMin_Callback(hObject, eventdata, handles)
% hObject    handle to InfoMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InfoMin as text
%        str2double(get(hObject,'String')) returns contents of InfoMin as a double


