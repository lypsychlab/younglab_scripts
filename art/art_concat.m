function varargout = art_concat(varargin)
% see help2/art_readme.txt for most recent tutorial.
%
% art - module for automatic and manual detection and removal of outliers.
%
% This utility asks for SPM.mat file and an SPM text motion parameters
% file, an FSL par motion parameters file, or a file containing a list
% of Siemens MotionDetectionParameters.txt filenames. It then displays
% four graphs.
%
% The top graph is the global brain activation mean as a function of
% time.
%
% The second is a z-normalized (stdv away from mean) global brain
% activation as a function of time.
%
% The Third shows the linear motion parameters (X,Y,Z) in mm as a
% function of time and the fourth shows the rotational motion
% parameters (roll,pitch,yaw) in radians as a function of time.
%
% Using default threshold values for each of the bottom three graphs
% we define outliers as points that exceed the threshold in at least
% one of these graphs. The thresholds are shown as horizontal black
% lines in each of the graphs.
%
% Points which are identified as outliers, are indicated by a vertical
% red line in the graph that corresponds to the outlying
% parameter(s). For example, the if the absolute value of the Y motion
% parameter for time t=17 is above the motion threshold, it is
% identified as an outlier and indicated by a red vertical line at
% t=17 in the third graph. The union of all outliers is indicated by
% vertical lines on the top graph. The list of outliers is also
% displayed in the editable text box below the graphs.  The current
% values of the thresholds are displayed by the side of the
% corresponding graphs. These values may can be changed by the user
% either by pressing the up/down buttons, which increment/decrement
% the current value by 10%, or by specifying a new value in the text
% box.
%
% In Addition, the user can manually add or remove points from the
% list of outliers by editting the list. Note that the list is only
% updated once the curser points outside the text box (i.e. click the
% mouse somewhere outside the text box). Since any changes made by the
% user are overridden once the thresholds are updated, it is
% recommended to do any manual changes as the last step before saving.
%
% Pressing the save button lets the user choose wheter to save the
% motion statistics (.mat or .txt) the list of outliers (.mat or .txt),
% or save the graphs (.jpg, .eps or matlab .fig).
%
%
% ----------------------------------------------------------------------
% - if multiple sessions are specified, standard deviations are calculated
%   within sessions
%   oliver hinds 2008-04-23
% - added support for reading siemens motion paramter file format
%   oliver hinds 2008-04-23
% - added ability to read file names and sesions from config file
%   oliver hinds 2008-04-23
% - tiny fix to make Matlab 6.5 compatible - Shay 5/14/07
% - added "signal-task correlation" - 5/11/07
% - added "motion-task correlation" and "show spectrum"
% - minor GUI changes to support Windows and open a large graph
%   in a separate window. Also fixed starnge motion params filename
%   bug. Shay Mozes, 5/2/2007
% - fixed bug in display of motion outlier on the graph, Shay Mozes 4/30/2007
% - superimpose task conditions on the z-graph, Shay Mozes, 4/24/2007
% - added support for SPM5, Shay Mozes, 4/2007
% - now supporting FSL .par format, 4/9/2007
% - new GUI and features Shay Mozes, 2006
% + Mar. 2007 from art_global.m, by Paul Mazaika, April 2004.
%   from artdetect4.m, by Jeff Cooper, Nov. 2002
%   from artdetect3.m, by Sue Whitfield artdetect.m
% Sue Whitfield 2000



% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @art_OpeningFcn, ...
    'gui_OutputFcn',  @art_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before art is made visible.
% This is where the logic begins
function art_OpeningFcn(hObject, eventdata, handles, varargin)

% -----------------------
% Initialize, begin loop
% -----------------------

%pfig = [];

warning('OFF','all')

%find spm version
spm_ver = spm('ver');
switch(spm_ver),
    case 'SPM99', spm_ver=1;
    case 'SPM2', spm_ver=2;
    case 'SPM5', spm_ver=5;
    case {'SPM8b','SPM8'}, spm_ver=8;
    otherwise, disp(['Warning! unrecognized SPM version ',spm_ver]); spm_ver=5;
end

%clear data from previous sessions
try
    setappdata(handles.showDesign,'SPM',[]);
    setappdata(handles.showDesign,'sessions',[]);
    setappdata(handles.showDesign,'SPMfile',[]);
    setappdata(handles.zthresh,'g',[]);
    setappdata(handles.mvthresh,'mv_data',[]);
    setappdata(handles.mvthresh,'altval',[]);
    setappdata(handles.rtthresh,'altval',[]);
    setappdata(handles.savefile,'path',[]);
    setappdata(handles.savefile,'datafiles',[]);
    setappdata(handles.savefile,'stats_file',[]);
    setappdata(handles.savefile,'analyses',[]);
    setappdata(handles.mvthresh,'mv_stats',[]);
    setappdata(handles.zthresh,'zoutliers',[]);
    setappdata(handles.mvthresh,'mv_norm_outliers',[]);
    setappdata(handles.mvthresh,'mv_x_outliers',[]);
    setappdata(handles.mvthresh,'mv_y_outliers',[]);
    setappdata(handles.mvthresh,'mv_z_outliers',[]);
    setappdata(handles.rtthresh,'rt_norm_outliers',[]);
    setappdata(handles.rtthresh,'rt_p_outliers',[]);
    setappdata(handles.rtthresh,'rt_r_outliers',[]);
    setappdata(handles.rtthresh,'rt_y_outliers',[]);
end

% ------------------------
% Default values for outliers
% ------------------------
%  Deviations over n*std are outliers.
z_thresh = 9.0;%6.0;
%movement thresholds - shay
mvmt_thresh = 2.0;%1.0;%outliers have linear momevent norm > mm_thresh
rotat_thresh = .05;%outliers have angular movement > rad_thresh in at least one orientation - change this???
mvmt_diff_thresh = 2.0;%1.0;
rotat_diff_thresh = .02;

M = [];
P = [];
output_path='';
motionFileType = 0;
sess_file='';
stats_file='';


%% BEGIN ohinds 2008-04-23: config file loading

% look for args in varargin
for i=1:numel(varargin)-1
    if strcmp(varargin{i}, 'sess_file')
        sess_file = varargin{i+1};
    end
    if strcmp(varargin{i}, 'stats_file')
        stats_file = varargin{i+1};
    end
end
setappdata(handles.savefile,'stats_file',stats_file);


% ------------------------
% Collect files
% ------------------------
if ~isempty(sess_file) % read config
    [num_sess,global_type_flag,drop_flag,motionFileType,motion_threshold,global_threshold,use_diff_motion,use_diff_global,use_norms,SPMfile,mask_file,output_dir,P,M] = ...
        read_art_sess_file(sess_file);
    realignfile = 1;
    %% END ohinds 2008-04-23: config file loading
else
    motion_threshold=[];global_threshold=[];SPMfile=[];mask_file=[];output_dir=[];
    use_diff_motion=1;use_diff_global=1;use_norms=1;
    num_sess = spm_input('How many sessions?',1,'n',1,1);
    
    global_type_flag = spm_input('Which global mean to use?', 1, 'm', ...
        'Regular | User Mask',...
        [1 2], 1);
%         'Regular | Every Voxel | User Mask | Auto ( Generates ArtifactMask )',...
%         [1 2 3 4], 1);
    
    realignfile = 1;   % Default case is like artdetect4.
    % If there are no realignment files available,
    % compute some instead.
    %this is no longer supported - Shay(04/2007)
    %if global_type_flag == 4
    %realignfile = spm_input('Have realignment
    %files(1) or not(0)',1);
    % realignfile = spm_input('Have realignment
    %    files?',1, 'b', ' Yes | No ', [ 1 0 ], 1);
    %end
    
    if realignfile == 1 %ask for type of input files
        %for moition params
        motionFileType = spm_input('Select type of motion params file.',1,'m',...
            ' txt(SPM) | par(FSL) | txt(Siemens)', ...
            [0 1 2], 0);
        
    end
    for i = 1:num_sess
        switch spm_ver
            case {1,2}
                P{i} = spm_get(Inf,'.img',['Select functional volumes for session'  num2str(i) ':']);
            case {5,8}
                P{i} = spm_select(Inf,'image',['Select functional volumes for session'  num2str(i) ':']);
        end
        if realignfile == 1
            if motionFileType == 0 %SPM format
                switch spm_ver
                    case {1,2}
                        mvmt_file = spm_get(1,'.txt',['Select movement params file for session' num2str(i) ':']);
                    case {5,8}
                        mvmt_file = spm_select(1,'^.*\.txt$',['Select movement params file for session' num2str(i) ':']);
                end
                M{i} =load(mvmt_file);
            elseif motionFileType == 1 %FSL format
                switch spm_ver
                    case {1,2}
                        mvmt_file = spm_get(1,'.par',['Select movement params file for session' num2str(i) ':']);
                    case {5,8}
                        mvmt_file = spm_select(1,'^.*\.par$',['Select movement params file for session' num2str(i) ':']);
                end
                M{i} =load(mvmt_file);
            elseif motionFileType == 2 % Siemens MotionDetectionParameter.txt
                switch spm_ver
                    case {1,2}
                        mvmt_file = spm_get(1,'.txt',['Select movement params file for session' num2str(i) ':']);
                    case {5,8}
                        mvmt_file = spm_select(1,'^.*\.txt$',['Select movement params file for session' num2str(i) ':']);
                end
                M{i} = read_siemens_motion_parm_file(mvmt_file);
            end
            [output_path,mv_name,mv_ext] = fileparts(mvmt_file);
        end
    end
    
    
    
%     if global_type_flag==3,
%         mask = spm_select(1, '.*\.nii|.*\.img', 'Select mask image in functional space');
%         [maskY,maskXYZmm] = spm_read_vols(spm_vol(mask));
%         maskXYZmm = maskXYZmm(:,maskY>0);
%         maskXYZmm = maskXYZmm(:,find(maskY==max(max(max(maskY)))));
%     end
%     if global_type_flag == 4   %  Automask option
%         disp('Generated mask image is written to file ArtifactMask.img.')
%         Pnames = P{1};
%         Automask = art_automask(Pnames(1,:),-1,1);
%         maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
%         voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
%     end
    
    drop_flag = spm_input('Drop 1st scan of each session?', '+1', 'y/n', [1 0], 2);
    
end

if global_type_flag==2,
    if isempty(mask_file),
        mask_file = spm_select(1, 'image', 'Select mask image in functional space');
    end
    mask=spm_vol(mask_file);
end
setappdata(handles.showDesign,'sessions',-(1:num_sess));
setappdata(handles.showDesign,'SPMfile',SPMfile);
if ~isempty(SPMfile), temp=load(SPMfile); setappdata(handles.showDesign,'SPM',temp.SPM); clear temp; end
datafiles={};for i=1:length(P),if ~isempty(P{i}),datafiles{i}=fliplr(deblank(fliplr(deblank(P{i}(1,:)))));else datafiles{i}=[];end;end; % <alfnie>: keep filenames of functional data (first scan per session only)
if ~isempty(motion_threshold), mvmt_thresh=motion_threshold; mvmt_diff_thresh=motion_threshold; end
if ~isempty(global_threshold), z_thresh=global_threshold; end

if ( drop_flag == 1 && realignfile == 1 )
    for i = 1:num_sess
        currP = P{i};
        currP(1,:) = [];
        P{i} = currP;
        currM = M{i};
        currM(1,:) = [];
        M{i} = currM;
    end
end

%P = char(P);
mv_data = [];
for i = 1:length(M)
    mv_data = vertcat(mv_data,M{i});
end
%in FSL order of fields is three Euler angles (x,y,z in radians) then
%three translation params (x,y,z in mm).
%in SPM: x y z pitch roll yaw
if motionFileType == 1
    tmp = mv_data(:,1:3);
    mv_data(:,1:3) = mv_data(:,4:6);
    mv_data(:,4:6) = tmp;
end





% -------------------------
% get file identifiers and Global values
% -------------------------

%% BEGIN ohinds 2008-04-23: session specific computations
g = {}; % g is a cell array of the global mean for each scan in each session
maskscan={};
cumdisp;
for sess=1:num_sess
    fprintf('%-4s: ',['Mapping files for session ' num2str(sess) '...']);
    VY     = spm_vol(P{sess});
    fprintf('%3s\n','...done')
    
    switch spm_ver
        case {1,2}
            if any(any(diff(cat(1,VY.dim),1,1),1)&[1,1,1,0])
                error('images do not all have the same dimensions')
            end
        case {5,8}
            if any(any(diff(cat(1,VY.dim),1,1),1))
                error('images do not all have the same dimensions')
            end
    end
    
    nscans = size(VY,1);
    %keyboard;
    % ------------------------
    % Compute Global variate
    %--------------------------
    
    %GM     = 100;
    g{sess} = zeros(nscans,4);
    
    fprintf('%-4s: %3s','Calculating globals...',' ')
    if global_type_flag==1  % regular mean : Global-conjunction (uses conjunction of individual scan masks; individual scan mask are defined as voxels above mean/8 for each scan)
        Mask=ones(VY(1).dim(1:3));
        VY1inv=pinv(VY(1).mat);
        for i = 1:nscans,
            temp=spm_read_vols(VY(i));
            [maskscan{end+1},masktemp]=art_maskglobal_scan(temp,VY(i),VY(1),VY1inv);
            Mask=Mask&masktemp;
            cumdisp([num2str(i),'/',num2str(nscans)]);
        end
        idxMask=find(Mask);
        if length(idxMask)<numel(Mask)/10,
            for i  = 1:nscans
                g{sess}(i) = spm_global(VY(i));
            end
        else 
            if length(VY)>1&&any(any(VY(2).mat~=VY(1).mat)),
                [tempx,tempy,tempz]=ind2sub(VY(1).dim(1:3),idxMask);xyz=VY(1).mat*[tempx(:),tempy(:),tempz(:),ones(numel(tempx),1)]';
                for i = 1:nscans,
                    temp=spm_get_data(VY(i),pinv(VY(i).mat)*xyz);
                    g{sess}(i)=mean(temp);
                end
            else 
                for i = 1:nscans,
                    temp=spm_read_vols(VY(i));
                    g{sess}(i)=mean(temp(idxMask));
                end
            end
        end
    elseif global_type_flag==2  % user-defined mask
        VY1inv=pinv(VY(1).mat);
        [tempx,tempy,tempz]=ind2sub(VY(1).dim(1:3),1:prod(VY(1).dim(1:3)));
        xyz=VY(1).mat*[tempx(:),tempy(:),tempz(:),ones(numel(tempx),1)]';
        Mask=spm_get_data(mask,pinv(mask.mat)*xyz);
        idxMask=find(Mask>0);
        if length(VY)>1&&any(any(VY(2).mat~=VY(1).mat)),
            [tempx,tempy,tempz]=ind2sub(VY(1).dim(1:3),idxMask);xyz=VY(1).mat*[tempx(:),tempy(:),tempz(:),ones(numel(tempx),1)]';
            for i = 1:nscans,
                temp=spm_read_vols(VY(i));
                [maskscan{end+1},masktemp]=art_maskglobal_scan(temp,VY(i),VY(1),VY1inv);
                temp=spm_get_data(VY(i),pinv(VY(i).mat)*xyz);
                g{sess}(i)=mean(temp);
                cumdisp([num2str(i),'/',num2str(nscans)]);
            end
        else 
            for i = 1:nscans,
                temp=spm_read_vols(VY(i));
                [maskscan{end+1},masktemp]=art_maskglobal_scan(temp,VY(i),VY(1),VY1inv);
                g{sess}(i)=mean(temp(idxMask));
                cumdisp([num2str(i),'/',num2str(nscans)]);
            end
        end
    end
%     elseif 0,%global_type_flag==2  % every voxel
%         VY1inv=pinv(VY(1).mat);
%         for i = 1:nscans,
%             temp=spm_read_vols(VY(i));
%             maskscan{end+1}=art_maskglobal_scan(temp,VY(i),VY(1),VY1inv);
%             g{sess}(i) = mean(mean(mean(temp)));
%             cumdisp([num2str(i),'/',num2str(nscans)]);
%         end
%     elseif 0,%global_type_flag == 3 % user masked mean
%         [dummy, XYZmm] = spm_read_vols(VY(1));
%         vinv = inv(VY(1).mat);
%         [dummy, idx_to_mask] = intersect(XYZmm', maskXYZmm', 'rows');
%         maskcount = length(idx_to_mask);
%         for i = 1:nscans
%             Y = spm_read_vols(VY(i));
%             maskscan{end+1}=art_maskglobal_scan(Y,VY(i),VY(1),vinv);
%             Y(idx_to_mask) = [];
%             voxelcount = prod(size(Y));
%             g{sess}(i) = mean(Y)*voxelcount/maskcount;
%             cumdisp([num2str(i),'/',num2str(nscans)]);
%         end
%     elseif 0,%global_type_flag == 4  %  auto mask
%         VY1inv=pinv(VY(1).mat);
%         for i = 1:nscans
%             Y = spm_read_vols(VY(i));
%             maskscan{end+1}=art_maskglobal_scan(Y,VY(i),VY(1),VY1inv);
%             Y = Y.*Automask;
%             if realignfile == 0
%                 output = art_centroid(Y);
%                 centroiddata(i,1:3) = output(2:4);
%                 g{sess}(i) = output(1)*voxelcount/maskcount;
%             else     % realignfile == 1
%                 g{sess}(i) = mean(mean(mean(Y)))*voxelcount/maskcount;
%             end
%             cumdisp([num2str(i),'/',num2str(nscans)]);
%         end
%         if realignfile == 0    % change to error values instead of means.
%             centroidmean = mean(centroiddata,1);
%             for i = 1:nscans
%                 mv0data(i,:) = centroiddata(i,:) - centroidmean;
%             end
%         end
%     end
    fprintf('...done');cumdisp;
%     if global_type_flag==3
%         fprintf('\n%g voxels were in the user mask.\n', maskcount)
%     end
%     if global_type_flag==4
%         fprintf('\n%g voxels were in the auto generated mask.\n', maskcount)
%     end
    
    % ------------------------
    % Compute default out indices by z-score
    % ------------------------
    
    %gsigma{sess} = std(g{sess});
    %gmean{sess} = mean(g{sess});
    %pctmap{sess} = 100*gsigma{sess}/gmean{sess};
    gsigma{sess} = .7413*diff(prctile(g{sess}(:,1),[25,75]));gsigma{sess}(gsigma{sess}==0)=1;
    gmean{sess} = median(g{sess}(:,1));
    g{sess}(:,2)=(g{sess}(:,1)-gmean{sess})/max(eps,gsigma{sess});
    g{sess}(2:end,3)=diff(g{sess}(:,1),1,1);
    dgsigma{sess} = .7413*diff(prctile(g{sess}(:,3),[25,75]));dgsigma{sess}(dgsigma{sess}==0)=1;
    dgmean{sess} = median(g{sess}(:,3));
    g{sess}(2:end,4)=(g{sess}(2:end,3)-dgmean{sess})/max(eps,dgsigma{sess});
    
    z_thresh = 0.1*round(z_thresh*10);
    
end
VY1=VY(1);save('art_mask_temporalfile.mat','maskscan','VY1');
%% END ohinds 2008-04-23: session specific computations

% TODO: how do we display session specific info???
%update text fields
set(handles.data_stdv,'String',num2str(cat(2,gsigma{:}),'%0.1f '));
set(handles.zthresh,'String',num2str(z_thresh));
set(handles.mvthresh,'String',num2str(mvmt_thresh));
set(handles.rtthresh,'String',num2str(rotat_thresh));

%%columns 8:13 store the difference series
%mv_data(2:end,8:13)  = abs(mv_data(2:end,1:6) - mv_data(1:end-1,1:6));

%for i=1:size(mv_data,1)
%  %7th column holds euclidean norms of movement
%  mv_data(i,7) = norm(mv_data(i,1:3));
%  %14-15th column stores the sums/norms of linear and angular motion
%  %    mv_data(i,14) = norm(mv_data(i,8:10));
%  %    mv_data(i,15) = norm(mv_data(i,11:13));
%end

respos=diag([70,70,75]);resneg=diag([-70,-110,-45]);
res=[respos,zeros(3,1),zeros(3,4),zeros(3,4),eye(3),zeros(3,1); % 6 control points: [+x,+y,+z,-x,-y,-z];
    zeros(3,4),respos,zeros(3,1),zeros(3,4),eye(3),zeros(3,1);
    zeros(3,4),zeros(3,4),respos,zeros(3,1),eye(3),zeros(3,1);
    resneg,zeros(3,1),zeros(3,4),zeros(3,4),eye(3),zeros(3,1);
    zeros(3,4),resneg,zeros(3,1),zeros(3,4),eye(3),zeros(3,1);
    zeros(3,4),zeros(3,4),resneg,zeros(3,1),eye(3),zeros(3,1);];
%columns 14:31 store the control points positions
for i=1:size(mv_data,1)
    temp=spm_matrix([1*mv_data(i,1:3),mv_data(i,4:6)]); temp=temp(:)';
    mv_data(i,14:31)=temp*res';
end
cur_sess_start=0;
for sess=1:num_sess
    n=length(g{sess}(:,1));
    %7th column holds euclidean norms of movement
    mv_data(cur_sess_start+(1:n),7) = sqrt(sum(abs(mv_data(cur_sess_start+(1:n),1:3)).^2,2));
    %columns 8:13 store the difference series
    mv_data(cur_sess_start+(2:n),8:13)  = diff(mv_data(cur_sess_start+(1:n),1:6),1,1);
    %columns 32 stores the compound movement measure
    mv_data(cur_sess_start+(1:n),32)=sqrt(mean(abs(detrend(mv_data(cur_sess_start+(1:n),14:31),'constant')).^2,2));
    %columns 33:50 store the control points positions
    mv_data(cur_sess_start+(2:n),33:50)=diff(mv_data(cur_sess_start+(1:n),14:31),1,1);
    %columns 51 stores the compound scan-to-scan movement measure
    mv_data(cur_sess_start+(2:n),51)=max(sqrt(sum(reshape(abs(mv_data(cur_sess_start+(2:n),33:50)).^2,[n-1,3,6]),2)),[],3);
    cur_sess_start = cur_sess_start + n;
end

%save application data for use in callbacks
setappdata(handles.zthresh,'g',g);
setappdata(handles.mvthresh,'mv_data',mv_data);
setappdata(handles.mvthresh,'altval',num2str(mvmt_diff_thresh));
setappdata(handles.rtthresh,'altval',num2str(rotat_diff_thresh));
%setappdata(handles.savefile,'data',P);
setappdata(handles.savefile,'path',output_path);
setappdata(handles.savefile,'dir',output_dir);
setappdata(handles.savefile,'datafiles',datafiles);
setappdata(handles.savefile,'mv_data_raw',M);

%plot global mean
axes(handles.globalMean);
%% BEGIN ohinds 2008-04-23: plot and print global mean
hold on;

%% ohinds: can't put the range for all sessions on the ylabel, not
%% enough room
%ylabstr = 'Range (sess): ';

cur_sess_start=1;
for sess=1:num_sess
    rng{sess} = range(g{sess}(:,1));
    plot(cur_sess_start:cur_sess_start+length(g{sess}(:,1))-1, g{sess}(:,1));
    fprintf('\nSession %d global statistics -  mean: %7.4f stdv: %7.4f',sess,gmean{sess},gsigma{sess});
    %ylabstr = sprintf('%s %f (%d)', ylabstr, rng{sess}, sess);
    cur_sess_start = cur_sess_start + length(g{sess}(:,1));
end
hold off;
set(gca,'xlim',[0,cur_sess_start]);
fprintf('\n');

%ylabel(ylabstr, 'FontSize', 8);
ylabel('mean image\newlineintensity');

%% END ohinds 2008-04-23: plot global mean

if ( global_type_flag == 1 ), title('Global Mean - SPM mask'); end
if ( global_type_flag == 2 ), title('Global Mean - User-defined mask'); end
% if ( global_type_flag == 3 ) title('Global Mean - User Defined Mask'); end
% if ( global_type_flag == 4 ) title('Global Mean - Generated ArtifactMask'); end

%plot in stddev
%z_Callback(hObject, eventdata, handles,1.0);
%plot movement
%mv_Callback(hObject, eventdata, handles,1.0);
%plot rotation
%rt_Callback(hObject, eventdata, handles,1.0);

% DEFAULTS: set 'Use differences&norms' as default (alfnie 04/09)
%
if ~isempty(SPMfile), set(handles.showDesign,'Value',get(handles.showDesign,'Max')); end
set(handles.norms,'Value',use_norms);
set(handles.diff1,'value',use_diff_global);
set(handles.diff2,'value',use_diff_motion);
showMask_Callback(hObject, eventdata, []);
if use_diff_global&&use_diff_motion,diffs_Callback(hObject, [], handles);
elseif use_diff_global,diffs1_Callback(hObject, [], handles);
elseif use_diff_motion,diffs2_Callback(hObject, [], handles);
else  z_Callback(hObject, eventdata, handles,1.0);mv_Callback(hObject, eventdata, handles,1.0);rt_Callback(hObject, eventdata, handles,1.0);end
idx=str2num(get(handles.all_outliers, 'String'));
disp(['Outlier detection: ',num2str(length(idx)),' identified outliers']);

%calculate all outliers and plot
%calc_all(hObject, eventdata, handles)

%calculate and print statistics of movement

mv_data = getappdata(handles.mvthresh,'mv_data');
mv_stats = [mean(abs(mv_data)); std(abs(mv_data)); max(abs(mv_data)) ];
%global_stats = [gmean, gsigma];
setappdata(handles.mvthresh,'mv_stats',mv_stats);

fprintf('\n\nStatistics of movement data:\n\n');
fprintf('%5s%10s%10s%10s%11s%10s%9s%10s\n',' ','x','y','z',' pitch','roll','yaw','norm');
fprintf('%7s%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n','mean ',mv_stats(1,1:3),mv_stats(1,4:6),mv_stats(1,32));
fprintf('%7s%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n','stdv ',mv_stats(2,1:3),mv_stats(2,4:6),mv_stats(2,32));
fprintf('%7s%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n\n\n','max ',mv_stats(3,1:3),mv_stats(3,4:6),mv_stats(3,32));

%% BEGIN ohinds 2008-04-23: save stats to file
if ~isempty(stats_file)
    if isempty(fileparts(stats_file)),stats_file=fullfile(output_dir,stats_file);end
    fp = fopen(stats_file,'w');
    if fp ~= -1
        fprintf('saving global motion stats to %s\n',[pwd '/' stats_file]);
        fprintf(fp,'%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n',mv_stats(1,1:3),mv_stats(1,4:6),mv_stats(1,32));
        fprintf(fp,'%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n',mv_stats(2,1:3),mv_stats(2,4:6),mv_stats(2,32));
        fprintf(fp,'%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n\n\n',mv_stats(3,1:3),mv_stats(3,4:6),mv_stats(3,32));
        fclose(fp);
    end
end
%% END ohinds 2008-04-23: save stats to file

% Choose default command line output for art
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Saves regressor matrix with outliers & new analysis mask
savefile_Callback_SaveRegressor(handles);
savefile_Callback_SaveMask(handles);

%function that retreives all different outliers and outputs
%a single list of outliers
function calc_all(hObject, eventdata, handles)

%get data

idx = getappdata(handles.zthresh,'zoutliers');
if ~(get(handles.norms,'Value') == get(handles.norms,'Max'))
    idx = [idx , getappdata(handles.mvthresh,'mv_x_outliers')];
    idx = [idx , getappdata(handles.mvthresh,'mv_y_outliers')];
    idx = [idx , getappdata(handles.mvthresh,'mv_z_outliers')];
    idx = [idx , getappdata(handles.rtthresh,'rt_p_outliers')];
    idx = [idx , getappdata(handles.rtthresh,'rt_r_outliers')];
    idx = [idx , getappdata(handles.rtthresh,'rt_y_outliers')];
else 
    idx = [idx , getappdata(handles.rtthresh,'rt_norm_outliers')];
    idx = [idx , getappdata(handles.mvthresh,'mv_norm_outliers')];
end

idx = unique(idx);

%update data
set(handles.all_outliers, 'String', int2str(idx));

%plot
all_outliers_Callback(hObject, eventdata, handles);



function all_outliers_Callback(hObject, eventdata, handles)
% Plots the outliers in the global graph based on the current
% outliers in the all_outliers edit field
%get data
g = getappdata(handles.zthresh,'g');
num_sess = length(g);
%    idx = round(str2num(get(handles.all_outliers,'String')));
tmps = get(handles.all_outliers,'String');
if ~isempty(tmps)
    idx = round(str2num(tmps(1,:)));
    [nstrings,stam] = size(tmps);
    for i=2:nstrings
        idx = [idx , round(str2num(tmps(i,:)))];
    end
    set(handles.all_outliers, 'String', int2str(idx));
else
    idx = [];
end

%plot global mean
axes(handles.globalMean);
cla;
%% BEGIN ohinds 2008-04-23: plot and print global mean
hold on;

%% ohinds: can't put the range for all sessions on the ylabel, not
%% enough room
%ylabstr = 'Range (sess): ';
cur_sess_start=1;
rng_mean=0;rng_minmax=[-inf,-inf];
for sess=1:num_sess
    rng{sess} = range(g{sess}(:,1));
    rng_mean=rng_mean+mean(g{sess}(:,1));
    rng_minmax=max(rng_minmax,[-min(g{sess}(:,1)),max(g{sess}(:,1))]);
    plot(cur_sess_start:cur_sess_start+length(g{sess}(:,1))-1, g{sess}(:,1));
    %ylabstr = sprintf('%s %f (%d)', ylabstr, rng{sess}, sess);
    cur_sess_start = cur_sess_start + length(g{sess}(:,1));
end
set(gca,'xlim',[0,cur_sess_start]);
rng_mean=rng_mean/num_sess;

%ylabel(ylabstr, 'FontSize', 8);
ylabel('mean image\newlineintensity');
%% END ohinds 2008-04-23: plot global mean

y_lim = get(gca, 'YLim');
for i = 1:length(idx)
    line((idx(i)*ones(1, 2)), y_lim, 'Color', 'red');
end
hold off;
analyses=getappdata(handles.savefile,'analyses');
analyses.outliers.scans=idx;
setappdata(handles.savefile,'analyses',analyses);

%show design (moved to global plot <alfnie> 2009-01)
if (get(handles.showDesign,'Value') == get(handles.showDesign,'Max'))
    [SPM,design,names] = get_design(handles);
    stats_file=getappdata(handles.showDesign,'SPMfile');
    %stats_file=getappdata(handles.savefile,'stats_file');
    hold on
    colors = {'k:','b:','r:','g:','c:','m:','y:'};
    h=plot(1,nan,'.','markersize',1);
    for i=1:size(design,2)
        h(i+1)=plot(1:size(design,1) , rng_mean+sum(rng_minmax)/2*design(:,i),colors{mod(i,5)+1},'MarkerSize',4);
    end
    % computes number of outliers per condition
    %<alfnie@gmail.com>
    %2009-01
    out_idx=round(idx(idx>0));
    if cur_sess_start-1~=size(design,1),
        disp(['warning: incorrect number of scans (design matrix: ',num2str(size(design,1)),' ; functional data: ',num2str(cur_sess_start-1),')']);
        outliers_per_condition=length(out_idx);
    else 
        outliers_per_condition=[length(out_idx),sum(abs(design(out_idx,:)>0),1); size(design,1),sum(abs(design(:,:)>0),1)];
    end
    if size(outliers_per_condition,2)==length(names)+1,
        legendnames={['Total :',num2str(outliers_per_condition(1,1)),' outliers (',num2str(100*outliers_per_condition(1,1)/max(eps,outliers_per_condition(2,1)),'%0.0f'),'%)']};
        for i=1:length(names), legendnames{i+1}=[names{i},' :',num2str(outliers_per_condition(1,i+1),'%0.0f'),' outliers (',num2str(100*outliers_per_condition(1,i+1)/max(eps,outliers_per_condition(2,i+1)),'%0.0f'),'%)']; end
        [nill,h2]=legend(h,legendnames{:});%set(h2(1),'visible','off');
    end
    analyses=getappdata(handles.savefile,'analyses');
    analyses.outliers.condition_effects=outliers_per_condition(1,2:end);
    analyses.outliers.condition_names=names;
    setappdata(handles.savefile,'analyses',analyses);
    [statsfile_path,statsfile_name,statsfile_ext] = fileparts(stats_file); if isempty(statsfile_path),statsfile_path=pwd;end;
    stats_file_outliers=fullfile(statsfile_path,[statsfile_name,'_outliers.txt']);
    if ~isempty(stats_file_outliers)
        for fpidx = 1:2,
            if fpidx==1,
                fp=1;
                fprintf('Number of outliers\n');
            else 
                fp=fopen(stats_file_outliers,'w');
                fprintf('saving outlier statistics to %s\n',[stats_file_outliers]);
            end
            if fp ~= -1
                fprintf(fp,'%10s ','Total');
                fprintf(fp,'%10s ',names{:});
                fprintf(fp,'\n');
                fprintf(fp,'%10.0f ',outliers_per_condition(1,:));
                fprintf(fp,'\n');
                fprintf(fp,' %9.1f%%',100*outliers_per_condition(1,:)./max(eps,outliers_per_condition(2,:)));
                fprintf(fp,'\n');
            end
            if fpidx>1, fclose(fp); end
        end
    end
    hold off
    
else  legend off; end
if (get(handles.showMask,'Value') == get(handles.showMask,'Max'))
    showMask_Callback(hObject, eventdata, handles);
else 
    showMask_Callback(hObject, eventdata, []);
end

% --- Executes on button press in z_up.
function z_up_Callback(hObject, eventdata, handles)

z_Callback(hObject, eventdata, handles, 1.05);
calc_all(hObject, eventdata, handles)

% obsolete function? please check
function z_figure_obsolete(hObject, eventdata, handles)
incr=1.0;
h = figure;
hold on;
%get data
z_thresh = str2num(get(handles.zthresh,'String'));
g = getappdata(handles.zthresh,'g');
num_sess = length(g);

%calc new outliers
%% BEGIN ohinds 2008-04-23: plot zscores
cur_sess_start=1;
out_idx=[];
for sess=1:num_sess
    z_thresh = z_thresh*incr;
    out_idx = [out_idx; (find(abs(zscore(g{sess})) > z_thresh))'];
    
    %update text ????
    %set(handles.zthresh{sess},'String',num2str(z_thresh{sess}));
    
    %update plot
    plot(cur_sess_start:cur_sess_start+length(g{sess}), (zscore(g{sess})));
    
    l=ylabel('global signal\newline[std]');%ylabel('stdv away \newlinefrom mean');
    
    thresh_x = cur_sess_start:length(g{sess});
    thresh_y = z_thresh*ones(1,length(g{sess}));
    line(thresh_x, thresh_y, 'Color', 'black');
    line(thresh_x, -1*thresh_y, 'Color', 'black');
    
    cur_sess_start = cur_sess_start + length(g{sess});
end
setappdata(handles.zthresh,'zoutliers',out_idx);
%% END ohinds 2008-04-23: plot zscores

axes_lim = get(gca, 'YLim');
axes_height = axes_lim;
for i = 1:length(out_idx)
    line((out_idx(i)*ones(1, length(axes_height))), axes_height, 'Color', 'black');
end
hold off;

if (get(handles.showDesign,'Value') == get(handles.showDesign,'Max'))
    [SPM,design] = get_design(handles);
    
    hold on
    colors = {'go','ro','co','mo','yo'};
    for i=1:size(design,2)
        plot(1:size(design,1) , design(:,i),colors{mod(i,5)+1},'MarkerSize',4);
    end
    hold off
end

%function for getting SPM design matrix information
function [SPM,design,names] = get_design(handles)
SPM = getappdata(handles.showDesign,'SPM');
if (isempty(SPM))
    spm_ver = spm('ver');
    switch(spm_ver),
        case 'SPM99', spm_ver=1;
        case 'SPM2', spm_ver=2;
        case 'SPM5', spm_ver=5;
        case {'SPM8b','SPM8'}, spm_ver=8;
        otherwise, disp(['Warning! unrecognized SPM version ',spm_ver]); spm_ver=5;
    end
    switch spm_ver
        case {1,2}
            tmpfile = spm_get(1,'.mat','Select design matrix:');
        case {5,8}
            tmpfile = spm_select(1,'^.*\.mat$','Select design matrix:');
    end
    load(tmpfile);
    setappdata(handles.showDesign,'SPMfile',tmpfile);
    setappdata(handles.showDesign,'SPM',SPM);
end
sessions = getappdata(handles.showDesign,'sessions');
if isempty(sessions)||any(sessions<0),
    if length(sessions)==length(SPM.Sess) && all(sessions==-(1:length(sessions))),
        sessions = abs(sessions);
    else 
        tmpsess = inputdlg('What session(s) to use? (e.g. 1 or [1,2])','',1,{['[',num2str(abs(sessions)),']']});
        sessions = eval(char(tmpsess));
    end
    setappdata(handles.showDesign,'sessions',sessions);
end
rows = [];
cols = [];
names={};
for s = sessions
    rows = [rows SPM.Sess(s).row];
    %cols = [cols SPM.Sess(s).col]; % extracts all columns of design matrix
    %names=cat(1,names,SPM.xX.name(SPM.Sess(s).col));
    cols = [cols SPM.Sess(s).col(1:length(SPM.Sess(s).U))]; % extracts only effects of interest (no covariates) from design matrix
    names=cat(1,names,SPM.Sess(s).U(:).name);
end

design = SPM.xX.X(rows,cols);



% base callback for (re)plotting outliers graph
function z_Callback(hObject, eventdata, handles, incr)

%get data
z_thresh = str2num(get(handles.zthresh,'String'));
g = getappdata(handles.zthresh,'g');
num_sess = length(g);

%calc new outliers
%% BEGIN ohinds 2008-04-23: plot zscores
axes(handles.zvalue);
cla;
hold on;
cur_sess_start=1;
out_idx = [];
z_thresh = z_thresh*incr; % (bug? moved this line here <alfnie> 01/09)
idxind=2;
for sess=1:num_sess
    if get(handles.diff1,'value'),
        out_idx = [out_idx, ...
            cur_sess_start+(find(abs(g{sess}(:,idxind)) > z_thresh|abs([g{sess}(2:end,idxind);0]) > z_thresh))'-1]; % (bug? added "-1" here <alfnie> 01/09)
    else 
        out_idx = [out_idx, ...
            cur_sess_start+(find(abs(g{sess}(:,idxind)) > z_thresh))'-1]; % (bug? added "-1" here <alfnie> 01/09)
    end
    %update plot
    plot(cur_sess_start:cur_sess_start+size(g{sess},1)-1, g{sess}(:,idxind));
    cur_sess_start = cur_sess_start + size(g{sess},1);
end
set(gca,'xlim',[0,cur_sess_start]);
l=ylabel('global mean\newline     [std]');%ylabel('stdv away \newlinefrom mean');
set(l,'VerticalAlignment','bottom','horizontalalignment','center');
set(gca,'XTickLabel',[]);

thresh_x = 1:cur_sess_start-1;
thresh_y = z_thresh*ones(1,length(thresh_x));
line(thresh_x, thresh_y, 'Color', 'black');
line(thresh_x, -1*thresh_y, 'Color', 'black');

%update text
set(handles.zthresh,'String',num2str(z_thresh));
setappdata(handles.zthresh,'zoutliers',out_idx);
hold off;
%% END ohinds 2008-04-23: plot zscores

%plot outliers
axes_lim = get(gca, 'YLim');
axes_height = axes_lim;
for i = 1:length(out_idx)
    line((out_idx(i)*ones(1, length(axes_height))), axes_height, 'Color', 'black');
end



% --- Executes on button press in z_down.
function z_down_Callback(hObject, eventdata, handles)

z_Callback(hObject, eventdata, handles,0.95);
calc_all(hObject, eventdata, handles)

function zthresh_Callback(hObject, eventdata, handles)
% hObject    handle to zthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
z_Callback(hObject, eventdata, handles,1.0);
calc_all(hObject, eventdata, handles)


% base callback for (re)plotting movement graphs
function mv_Callback(hObject, eventdata, handles, incr)

%get data
mvmt_thresh = str2num(get(handles.mvthresh,'String'));
mv_data = getappdata(handles.mvthresh,'mv_data');

%calc new outliers
mvmt_thresh = mvmt_thresh*incr;

if get(handles.diff2,'value'),
    out_mvmt_idx = (find(abs(mv_data(:,1:3)) > mvmt_thresh | [abs(mv_data(2:end,1:3));[0,0,0]] > mvmt_thresh ))';
else 
    out_mvmt_idx = (find(abs(mv_data(:,1:3)) > mvmt_thresh))';
end
out_mvmt_idx_X=[];
out_mvmt_idx_Y=[];
out_mvmt_idx_Z=[];
for i =1:length(out_mvmt_idx)
    if out_mvmt_idx(i) <= length(mv_data)
        out_mvmt_idx_X=[out_mvmt_idx_X; out_mvmt_idx(i)];
    elseif out_mvmt_idx(i) > length(mv_data) && out_mvmt_idx(i) <= 2*length(mv_data) % bug: (changed < to <=) <alfnie>01/09
        out_mvmt_idx_Y=[out_mvmt_idx_Y; out_mvmt_idx(i)-length(mv_data)];
    else
        out_mvmt_idx_Z = [out_mvmt_idx_Z; out_mvmt_idx(i)-2*length(mv_data)];
    end
end
out_mvmt_idx_X = out_mvmt_idx_X';
out_mvmt_idx_Y = out_mvmt_idx_Y';
out_mvmt_idx_Z = out_mvmt_idx_Z';

%find norm outliers
if (get(handles.norms,'Value') == get(handles.norms,'Max'))
    %normv = zeros(size(mv_data,1),1);
    %for i=1:length(mv_data)
    %  normv(i) = norm(mv_data(i,1:3));
    %end
    normv=mv_data(:,32);
    if get(handles.diff2,'value'),
        out_mvmt_idx_norm = find(normv>mvmt_thresh|[normv(2:end);0]>mvmt_thresh);
    else 
        out_mvmt_idx_norm = find(normv>mvmt_thresh);
    end
    out_mvmt_idx_norm = out_mvmt_idx_norm';
    setappdata(handles.mvthresh,'mv_norm_outliers',out_mvmt_idx_norm);
end


%update text
set(handles.mvthresh,'String',num2str(mvmt_thresh));
setappdata(handles.mvthresh,'mv_x_outliers',out_mvmt_idx_X);
setappdata(handles.mvthresh,'mv_y_outliers',out_mvmt_idx_Y);
setappdata(handles.mvthresh,'mv_z_outliers',out_mvmt_idx_Z);

axes(handles.mvmtGraph);
cla;
if (get(handles.norms,'Value') == get(handles.norms,'Max'))
    plot(normv);
    set(gca,'xlim',[0,length(normv)+1]);
else
    plot(mv_data(:,1:3));
    set(gca,'xlim',[0,size(mv_data,1)+1]);
end
l=ylabel('movement \newline   [mm]');
set(l,'VerticalAlignment','bottom','horizontalalignment','center');
set(gca,'XTickLabel',[]);
if (get(handles.norms,'Value') == get(handles.norms,'Max'))
    %l=legend('norm','Location','East');
else
    %    l=legend('x mvmt', 'y mvmt', 'z mvmt','Location','East');
    l=legend('x', 'y', 'z','Location','East');
end
%set(l,'Position',[116.4 15.4 12 5.1]);
h = gca;
set(h,'Ygrid','on');

thresh_mv_x = 1:size(mv_data,1);
thresh_mv_y = mvmt_thresh*ones(1,size(mv_data,1));
line(thresh_mv_x, thresh_mv_y, 'Color', 'black');
if ~(get(handles.norms,'Value') == get(handles.norms,'Max'))
    line(thresh_mv_x, -1*thresh_mv_y, 'Color', 'black');
end

axes_lim = get(gca, 'YLim');
axes_height = axes_lim;
if ~(get(handles.norms,'Value') == get(handles.norms,'Max'))
    for i = 1:length(out_mvmt_idx_X)
        line((out_mvmt_idx_X(i)*ones(1, length(axes_height))), axes_height, 'Color', 'black');
    end
    for i = 1:length(out_mvmt_idx_Y)
        line((out_mvmt_idx_Y(i)*ones(1, length(axes_height))), axes_height, 'Color', 'black');
    end
    for i = 1:length(out_mvmt_idx_Z)
        line((out_mvmt_idx_Z(i)*ones(1, length(axes_height))), axes_height, 'Color', 'black');
    end
else 
    for i = 1:length(out_mvmt_idx_norm)
        line((out_mvmt_idx_norm(i)*ones(1, length(axes_height))), axes_height, 'Color', 'black');
    end
end




% --- Executes on button press in mv_up.
function mv_up_Callback(hObject, eventdata, handles)
mv_Callback(hObject, eventdata, handles,1.05);
calc_all(hObject, eventdata, handles)

% --- Executes on button press in mv_down.
function mv_down_Callback(hObject, eventdata, handles)
mv_Callback(hObject, eventdata, handles,0.95);
calc_all(hObject, eventdata, handles)

% --- Executes on update of mvthresh.
function mvthresh_Callback(hObject, eventdata, handles)
mv_Callback(hObject, eventdata, handles,1.0);
calc_all(hObject, eventdata, handles)


% base callback for (re)plotting rotation graphs
function rt_Callback(hObject, eventdata, handles, incr)

%get data
rotat_thresh = str2num(get(handles.rtthresh,'String'));
mv_data = getappdata(handles.mvthresh,'mv_data');

%calc new outliers
rotat_thresh = rotat_thresh*incr;

out_rotat_idx = (find(abs(mv_data(:,4:6)) > rotat_thresh))';
out_rotat_idx_p=[];
out_rotat_idx_r=[];
out_rotat_idx_y=[];
for i =1:length(out_rotat_idx)
    if out_rotat_idx(i) <= length(mv_data)
        out_rotat_idx_p=[out_rotat_idx_p; out_rotat_idx(i)];
    elseif out_rotat_idx(i) > length(mv_data) && out_rotat_idx(i) < 2*length(mv_data)
        out_rotat_idx_r=[out_rotat_idx_r; out_rotat_idx(i)-length(mv_data)];
    else
        out_rotat_idx_y = [out_rotat_idx_y; out_rotat_idx(i)-2*length(mv_data)];
    end
end
out_rotat_idx_p = out_rotat_idx_p';
out_rotat_idx_r = out_rotat_idx_r';
out_rotat_idx_y = out_rotat_idx_y';

%find norm/sum outliers
if (get(handles.norms,'Value') == get(handles.norms,'Max'))
    normv = zeros(length(mv_data),1);
    %for i=1:length(mv_data)
    %  normv(i) = norm(mv_data(i,4:6));
    %end
    normv(:)=nan;
    out_rt_idx_norm = find(normv>rotat_thresh);
    out_rt_idx_norm = out_rt_idx_norm';
    setappdata(handles.rtthresh,'rt_norm_outliers',out_rt_idx_norm);
end


%update text
set(handles.rtthresh,'String',num2str(rotat_thresh));
setappdata(handles.rtthresh,'rt_p_outliers',out_rotat_idx_p);
setappdata(handles.rtthresh,'rt_r_outliers',out_rotat_idx_r);
setappdata(handles.rtthresh,'rt_y_outliers',out_rotat_idx_y);

axes(handles.rotatGraph);
cla;
if (get(handles.norms,'Value') == get(handles.norms,'Max'))
    plot(normv);
    set(gca,'xlim',[0,length(normv)+1]);
else
    plot(mv_data(:,4:6));
    set(gca,'xlim',[0,size(mv_data,1)+1]);
end
l=ylabel('rotation \newline  [rad]');
set(l,'VerticalAlignment','Bottom');
xlabel('scans');

% DRG (2009-08-25) next line is never used.
%y_lim = get(gca, 'YLim');
if (get(handles.norms,'Value') == get(handles.norms,'Max'))
    %l=legend('norm','Location','East');
else
    l=legend('pitch', 'roll', 'yaw', 'Location', 'East');
end
%set(l,'Position',[116.4 9.4 12 5.1]);
h = gca;
set(h,'Ygrid','on');

thresh_rt_x = 1:length(mv_data);
thresh_rt_y = rotat_thresh*ones(1,length(mv_data));

y_lim = get(gca, 'YLim');
if ~(get(handles.norms,'Value') == get(handles.norms,'Max'))
    line(thresh_rt_x, thresh_rt_y, 'Color', 'black');
    line(thresh_rt_x, -1*thresh_rt_y, 'Color', 'black');
    for i = 1:length(out_rotat_idx_p)
        line((out_rotat_idx_p(i)*ones(1, 2)), y_lim, 'Color', 'black');
    end
    for i = 1:length(out_rotat_idx_r)
        line((out_rotat_idx_r(i)*ones(1, 2)), y_lim, 'Color', 'black');
    end
    for i = 1:length(out_rotat_idx_y)
        line((out_rotat_idx_y(i)*ones(1, 2)), y_lim, 'Color', 'black');
    end
    set([h,handles.rt_up,handles.rt_down,handles.rtthresh,handles.text13],'visible','on')
    
else 
    for i = 1:length(out_rt_idx_norm)
        line((out_rt_idx_norm(i)*ones(1, 2)), y_lim, 'Color', 'black');
    end
    set([h,handles.rt_up,handles.rt_down,handles.rtthresh,handles.text13],'visible','off')
end



% --- Executes on button press in rt_up.
function rt_up_Callback(hObject, eventdata, handles)
rt_Callback(hObject, eventdata, handles,1.05)
calc_all(hObject, eventdata, handles)

% --- Executes on button press in rt_down.
function rt_down_Callback(hObject, eventdata, handles)
rt_Callback(hObject, eventdata, handles,0.95)
calc_all(hObject, eventdata, handles)

% --- Executes on update of mvthresh.
function rtthresh_Callback(hObject, eventdata, handles)
rt_Callback(hObject, eventdata, handles,1.0)
calc_all(hObject, eventdata, handles)


% --- Executes when difference button uis pressed
function diffs_Callback(hObject, eventdata, handles)

%switch thresholds
tmp = get(handles.mvthresh,'String');
set(handles.mvthresh,'String',getappdata(handles.mvthresh,'altval'));
setappdata(handles.mvthresh,'altval',tmp);
tmp = get(handles.rtthresh,'String');
set(handles.rtthresh,'String',getappdata(handles.rtthresh,'altval'));
setappdata(handles.rtthresh,'altval',tmp);

%switch data used
mv_data = getappdata(handles.mvthresh,'mv_data');
tmp = mv_data(:,1:6);
mv_data(:,1:6) = mv_data(:,8:13);
mv_data(:,8:13) = tmp;
tmp = mv_data(:,14:32);
mv_data(:,14:32) = mv_data(:,33:51);
mv_data(:,33:51) = tmp;
setappdata(handles.mvthresh,'mv_data',mv_data);

g = getappdata(handles.zthresh,'g');
for n1=1:length(g), g{n1}(:,[2,4])=g{n1}(:,[4,2]); end
setappdata(handles.zthresh,'g',g);

%plot global
z_Callback(hObject, eventdata, handles,1.0);

%plot movement
mv_Callback(hObject, eventdata, handles,1.0);

%plot rotation
rt_Callback(hObject, eventdata, handles,1.0);

%calculate all outliers and plot
calc_all(hObject, eventdata, handles);


function diffs1_Callback(hObject, eventdata, handles)

%switch thresholds
% tmp = get(handles.mvthresh,'String');
% set(handles.mvthresh,'String',getappdata(handles.mvthresh,'altval'));
% setappdata(handles.mvthresh,'altval',tmp);
% tmp = get(handles.rtthresh,'String');
% set(handles.rtthresh,'String',getappdata(handles.rtthresh,'altval'));
% setappdata(handles.rtthresh,'altval',tmp);

%switch data used
% mv_data = getappdata(handles.mvthresh,'mv_data');
% tmp = mv_data(:,1:6);
% mv_data(:,1:6) = mv_data(:,8:13);
% mv_data(:,8:13) = tmp;
% tmp = mv_data(:,14:32);
% mv_data(:,14:32) = mv_data(:,33:51);
% mv_data(:,33:51) = tmp;
% setappdata(handles.mvthresh,'mv_data',mv_data);

g = getappdata(handles.zthresh,'g');
for n1=1:length(g), g{n1}(:,[2,4])=g{n1}(:,[4,2]); end
setappdata(handles.zthresh,'g',g);

%plot global
z_Callback(hObject, eventdata, handles,1.0);

%plot movement
mv_Callback(hObject, eventdata, handles,1.0);

%plot rotation
rt_Callback(hObject, eventdata, handles,1.0);

%calculate all outliers and plot
calc_all(hObject, eventdata, handles);


function diffs2_Callback(hObject, eventdata, handles)

%switch thresholds
tmp = get(handles.mvthresh,'String');
set(handles.mvthresh,'String',getappdata(handles.mvthresh,'altval'));
setappdata(handles.mvthresh,'altval',tmp);
tmp = get(handles.rtthresh,'String');
set(handles.rtthresh,'String',getappdata(handles.rtthresh,'altval'));
setappdata(handles.rtthresh,'altval',tmp);

%switch data used
mv_data = getappdata(handles.mvthresh,'mv_data');
tmp = mv_data(:,1:6);
mv_data(:,1:6) = mv_data(:,8:13);
mv_data(:,8:13) = tmp;
tmp = mv_data(:,14:32);
mv_data(:,14:32) = mv_data(:,33:51);
mv_data(:,33:51) = tmp;
setappdata(handles.mvthresh,'mv_data',mv_data);

% g = getappdata(handles.zthresh,'g');
% for n1=1:length(g), g{n1}(:,[2,4])=g{n1}(:,[4,2]); end
% setappdata(handles.zthresh,'g',g);

%plot global
z_Callback(hObject, eventdata, handles,1.0);

%plot movement
mv_Callback(hObject, eventdata, handles,1.0);

%plot rotation
rt_Callback(hObject, eventdata, handles,1.0);

%calculate all outliers and plot
calc_all(hObject, eventdata, handles);


% --- Executes when norms checkbox is changed
function norms_Callback(hObject, eventdata, handles)

%plot movement
mv_Callback(hObject, eventdata, handles,1.0);

%plot rotation
rt_Callback(hObject, eventdata, handles,1.0);

%calculate all outliers and plot
calc_all(hObject, eventdata, handles);

% --- Executes when show design checkbox is changed
function showDesign_Callback(hObject, eventdata, handles)
%plot movement
%z_Callback(hObject, eventdata, handles,1.0);
all_outliers_Callback(hObject, eventdata, handles)


function showCorr_Callback(hObject, eventdata, handles)
if (get(handles.showCorr,'Value') == get(handles.showCorr,'Max'))
    %display correlations
    [SPM,design,names] = get_design(handles);
    mv_data = getappdata(handles.mvthresh,'mv_data');
    sessions = getappdata(handles.showDesign,'sessions');
    f = figure;
    setappdata(handles.showCorr,'figure',f);
    nrows=0;
    for sess=1:length(sessions),
        s = sessions(sess);
        rows = SPM.Sess(s).row;
        %cols = SPM.Sess(s).col;
        cols = SPM.Sess(s).col(1:length(SPM.Sess(s).U)); % alfnie@gmail.com 02/09 extracts only effects of interest (no covariates) from design matrix
        nrows=[nrows,length(rows)];
        
        %create partial matrix to correlate
        %(we only want to correlate with the motion parameters within each
        %session). NOTE: This may cause weird behaviour in weird designs...
        part = [SPM.xX.X(rows,cols) mv_data(sum(nrows(1:end-1))+(1:nrows(end)),1:6)];
        cm{sess} = corrcoef(part);
        a = subplot(length(sessions),1,sess);
        
        imagesc(cm{sess}(1:end-6,end-5:end),[-1,1]);
        colorbar;
        set(a,'XTickLabel',{'x','y','z','pitch','roll','yaw'});
        set(a,'YTick',[1:length(cols)]);
        %names = {};
        %for i=1:length(cols)
        %    names(i) = SPM.Sess(s).U(i).name;
        %end
        set(a,'YTickLabel',names);
        title(sprintf('Session %d',s));
        analyses=getappdata(handles.savefile,'analyses');
        analyses.motion_task_correlation(sess)=struct('r',cm{sess}(1:end-6,end-5:end),'rows',{get(a,'yticklabel')},'cols',{get(a,'xticklabel')});
        setappdata(handles.savefile,'analyses',analyses);
        
    end
else
    f = getappdata(handles.showCorr,'figure');
    if ishandle(f),close(f);end
end

function show_signal_corr_Callback(hObject, eventdata, handles)
if (get(handles.sigCorr,'Value') == get(handles.sigCorr,'Max'))
    %display correlations
    [SPM,design,names] = get_design(handles);
    g = getappdata(handles.zthresh,'g');
    sessions = getappdata(handles.showDesign,'sessions');
    f = figure;
    setappdata(handles.sigCorr,'figure',f);
    for sess=1:length(sessions),
        s = sessions(sess);
        rows = SPM.Sess(s).row;
        %cols = SPM.Sess(s).col;
        cols = SPM.Sess(s).col(1:length(SPM.Sess(s).U)); % alfnie@gmail.com 02/09 extracts only effects of interest (no covariates) from design matrix
        
        %create partial matrix to correlate
        %(we only want to correlate with the motion parameters within each
        %session). NOTE: This may cause weird behaviour in weird designs...
        part = [SPM.xX.X(rows,cols) g{sess}(:,1)];%g(rows)];
        cm{sess} = corrcoef(part);
        a = subplot(length(sessions),1,sess);
        
        imagesc(cm{sess}(end:end,1:end-1),[-1,1]);
        colorbar;
        names = {};
        for i=1:length(cols)
            names(i) = SPM.Sess(s).U(i).name;
        end
        set(a,'XTick',[1:length(cols)]);
        set(a,'XTickLabel',names);
        set(a,'YTick',1);
        set(a,'YTickLabel','mean activation');
        title(sprintf('Session %d',s));
        analyses=getappdata(handles.savefile,'analyses');
        analyses.signal_task_correlation(sess)=struct('r',cm{sess}(end,1:end-1),'rows',{get(a,'yticklabel')},'cols',{get(a,'xticklabel')});
        setappdata(handles.savefile,'analyses',analyses);
    end
else
    f = getappdata(handles.sigCorr,'figure');
    if ishandle(f),close(f);end
end


function showSpec_Callback(hObject, eventdata, handles)
if (get(handles.showSpec,'Value') == get(handles.showSpec,'Max'))
    %get data and compute power spectrum
    [SPM,design,names] = get_design(handles);
    mv_data = getappdata(handles.mvthresh,'mv_data');
    g = getappdata(handles.zthresh,'g');
    sessions = getappdata(handles.showDesign,'sessions');
    f = figure;
    setappdata(handles.showSpec,'figure',f);
    
    %sampling freq.
    sf = 1/SPM.xY.RT;
    
    nrows=0;
    for sess=1:length(sessions),
        s = sessions(sess);
        rows = SPM.Sess(s).row;
        %cols = SPM.Sess(s).col;
        cols = SPM.Sess(s).col(1:length(SPM.Sess(s).U)); % alfnie@gmail.com 02/09 extracts only effects of interest (no covariates) from design matrix
        nrows=[nrows,length(rows)];
        
        %create partial design matrix which only contains relevant data
        %for curent session
        data = [SPM.xX.X(rows,cols),mv_data(sum(nrows(1:end-1))+(1:nrows(end)),1:6),g{sess}(:,1)]; %alfnie 08/2009: add global signal
        
        cf = sf/2; %Nyquist freq.
        n = size(data,1);
        freqs = (0:cf/n:cf-cf/n)';%these are the descrete freqs used by dct
        
        %this is done in a loop (and not in matrix ops)
        %since dct encounters memory problems for large matrices.
        hold on
        n=n*5;freqs = (0:cf/n:cf-cf/n)';f = zeros(5*size(data,1),size(data,2));%alfnie 08/2009: resample
        for i=1:size(data,2)
            %%calculate dct
            %f(:,i) = dct(data(:,i));
            %calculate log10(abs(fft))
            temp=(abs(fft(detrend(data(:,i)).*hanning(size(data,1)),2*5*size(data,1))).^2);%alfnie 08/2009: plot spectral densities
            f(:,i) = temp(1:end/2);
            %normalize
            F(:,i) = f(:,i)/(sum(abs(f(:,i))));F(1,i)=nan;
        end
        
        a = subplot(length(sessions), 1, sess);
        hs = plot(freqs,F,'-'); axis tight; set(gca,'xlim',[sf/size(data,1),cf],'xscale','log','yscale','lin');set(gcf,'color',.9412*[1,1,1])
        names = {};
        for i=1:length(cols)
            names(i) = SPM.Sess(s).U(i).name;
        end
        names(end+1:end+7) = {'x','y','z','pitch','roll','yaw','BOLD'};
        l = legend(names,'Location','EastOutside');
        pos = get(l,'Position');
        set(l,'Visible','off');
        
        
        for i = 1:length(names)
            color = get(hs(i),'Color');
            box = uicontrol('Style','checkbox','String',names(i),'ForegroundColor', color,'Callback',{@setvisibility},'Value',1,'UserData',hs(i),'Units','normalized');
            tmppos = get(box,'Position');
            tmppos(1:2) = pos(1:2);
            set(box,'Position',tmppos);
            pos(2) = pos(2)+ 0.035;
            if (i > length(names)-7)
                set(box,'Value',0);
                setvisibility(box,0);
            end
        end
        
        title(sprintf('Session %d',s));
%         xlabel('Frequency [Hz]');  DRG (2009-08-25) This line was moved
%         ~15 lines down.
        ylabel('Power density \newline(normalized)');
        %try finding highpass freq. in SPM.xX.K(s).Hparam
        try
            cutoff = 1/SPM.xX.K(s).HParam;
        catch
            fprintf('no highpass cutoff frequency found in SPM.mat, using default (128).\n');
            cutoff = 1/128;
        end
        %draw cutoff freq.
        % DRG (2009-08-25) added to show cutoff frequency more clearly
        %         ylim = get(a,'YLim');   %%%%% YLIM IS ALREADY A COMMAND %%%%
        %         l=line(cutoff*ones(1,2),ylim,'Color','black');
        x_lim = xlim(a);
        l = patch([x_lim(1) x_lim(1) cutoff cutoff],[ylim(a) fliplr(ylim(a))],[.8 .8 .8]);
        xlabel(sprintf('Frequency [Hz], cutoff=1/%i',1/cutoff));
        set(a,'UserData',l);
        
        analyses=getappdata(handles.savefile,'analyses');
        analyses.motion_task_spectra(sess)=struct('Power',f,'rows',freqs,'cols',{names});
        setappdata(handles.savefile,'analyses',analyses);
        
    end
    
else
    f = getappdata(handles.showSpec,'figure');
    if ishandle(f),close(f);end
end

%toggle visibility for spectrum graph
function setvisibility(handle,tmp)
h = get(handle,'UserData');
if (get(handle,'Value') == get(handle,'Max'))
    set(h(1),'Visible','on');
else
    set(h(1),'Visible','off');
end

% DRG (2009-08-25) DON'T NEED TO DO THIS. LIMITS ARE ALWAYS THIS SAME
% ANYWAYS BECAUSE DATA IS THERE, BUT JUST HIDDEN.
%redraw the cutoff
% a = ancestor(h(1),'axes');
% l = get(a,'UserData');
% set(l,'Visible','off');
% ylim = get(a,'YLim');
% set(l,'YData',ylim,'Visible','on');




function showMask_Callback(hObject, eventdata, handles)
persistent plotdata
if isempty(plotdata)||isempty(handles),
   if isempty(handles), return; end
   plotdata=load(['art_mask_temporalfile.mat']);%,'maskscan','VY1');
   plotdata.Ma=spm_read_vols(plotdata.VY1);
   plotdata.Ma=plotdata.Ma/max(plotdata.Ma(:));
%    plotdata.Mb=ones(plotdata.VY1.dim);
%    plotdata.Mb(cat(1,plotdata.maskscan{setdiff(1:length(plotdata.maskscan),out_idx)}))=0;
%    [x,y,z]=ndgrid(1:plotdata.VY1.dim(1),1:plotdata.VY1.dim(2),1:plotdata.VY1.dim(3));
%    xyz=plotdata.VY1.mat*[x(:),y(:),z(:),ones(numel(x),1)]';
%    plotdata.ma=spm_vol(fullfile(fileparts(which('spm')),'canonical','avg152T1.nii'));
%    plotdata.Ma=reshape(spm_get_data(plotdata.ma,pinv(plotdata.ma.mat)*xyz),plotdata.VY1.dim(1:3));
%    plotdata.Ma=plotdata.Ma/max(plotdata.Ma(:));
   first=1;
else
    first=0; 
end
%hfig=findobj('tag','art_showmask_callback_figure');
%if isempty(hfig), hfig=figure('units','norm','position',[0.33,0.05,0.64,0.2000],'color','w','name','art mask display','numbertitle','off','menubar','none','tag','art_showmask_callback_figure','colormap',gray); first=1; end
%if first, figure(hfig); end
%if isempty(handles)||get(handles.showMask,'Value')==0,set(hfig,'visible','off'); return; elseif strcmp(get(hfig,'visible'),'off'), set(hfig,'visible','on'); end
if isempty(handles)||get(handles.showMask,'Value')==0,if ~isempty(handles),set([handles.axes_mask,get(handles.axes_mask,'children')],'visible','off'); set([handles.text_all_outliers,handles.all_outliers],'visible','on'); end; return; 
elseif strcmp(get(handles.axes_mask,'visible'),'off'), set(get(handles.axes_mask,'children'),'visible','on'); set([handles.axes_mask,handles.text_all_outliers,handles.all_outliers],'visible','off'); end
out_idx=round(str2num(get(handles.all_outliers, 'String')));
b=ones(plotdata.VY1.dim);
for n1=setdiff(1:length(plotdata.maskscan),out_idx),b(plotdata.maskscan{n1})=0;end

nhoriz=16;
slices=1:size(b,3);%round(linspace(1,size(b,3),15));
temp=reshape(b(:,:,slices).*(1+plotdata.Ma(:,:,slices)),[size(b,1),size(b,2)*length(slices)]);
temp2=[];
for n1=1:ceil(length(slices)/nhoriz),
    temp2=cat(1,temp2,[temp(:,size(b,2)*(n1-1)*nhoriz+1:size(b,2)*min(n1*nhoriz,length(slices))),zeros(size(b,1),max(0,size(b,2)*(n1*nhoriz-length(slices))))]);
end
if first||~isfield(plotdata,'h')||~ishandle(plotdata.h),
    axes(handles.axes_mask);
    plotdata.h=imagesc(2-temp2);
    colormap(gray);
    set(gca,'clim',[0,2],'visible','off');
    axis equal;
    axis off;
%if first||~isfield(plotdata,'h')||~ishandle(plotdata.h),plotdata.h=imagesc(2-temp2);set(gca,'units','norm','position',[0,0,1,1],'clim',[0,2]);axis equal;axis off;
else
    set(plotdata.h,'cdata',2-temp2); 
end
%set(hfig,'name',['art: analysis mask ',num2str(sum(b(:))),' voxels']); 



% --- Executes on button press in savefile.
function savefile_Callback(hObject, eventdata, handles)

d = dir;
str = {d.name};
[s,v] = listdlg('PromptString','What would you like to save?',...
    'SelectionMode','single',...
    'ListSize',[160,80], ...
    'ListString',{'Outliers','Motion Statistics','Graphs','SPM regressors','Analysis mask'});

if v==0
    return;
end

%get path
tmpdir = pwd;
pathname = '.'; %getappdata(hObject, 'path');
cd(pathname);

switch s
    
    %save outliers
    case 1
        
        out_idx = round(str2num(get(handles.all_outliers, 'String')));
        
        %ask user to choose filename
        filter = {'*.mat';'*.txt'};
        ext = {'.mat';'.txt'};
        [filename, pathname, filteridx] = uiputfile( filter,'Save outliers as:');
        
        %save according to file format
        switch filteridx
            
            %binary MAT file
            case 1
                filename = strcat(char(pathname), char(filename));
                save(filename ,'out_idx', '-mat');
                %txt file
            case 2
                filename = strcat(char(pathname), char(filename));
                save(filename,'out_idx','-ascii');
        end
        
        %save motion statistics
    case 2
        
        mv_stats = getappdata(handles.mvthresh,'mv_stats');
        analyses=getappdata(handles.savefile,'analyses');
        
        %save statistics to .mat file
        %mv_stats has 7 columns corresponding to x y z pitch roll yaw norm
        %and 3 rows corresponding to mean, stdv and max of the absolute values of
        %the movement parameters
        
        %ask user to choose filename
        filter = {'*.mat'; '*.txt'};
        ext = {'.mat';'.txt'};
        [filename, pathname, filteridx] = uiputfile( filter,'Save motion statistics as');
        
        %save according to file format
        switch filteridx
            %binary MAT file
            case 1
                filename = strcat(char(pathname), char(filename));
                save(filename ,'mv_stats','analyses','-mat');
                %txt file
            case 2
                filename = strcat(char(pathname), char(filename));
                save(filename,'mv_stats','analyses','-ascii');
        end
        
        %save graphs
    case 3
        
        %ask user to choose filename
        filter = {'*.jpg';'*.eps';'*.fig'};
        ext = {'.jpg';'.eps';'.fig'};
        [filename, pathname, filteridx] = uiputfile( filter,'Save figure as:');
        
        filename = strcat(char(pathname), char(filename));
        saveas(gcf,filename);
        
        % saves SPM regressor files (one regressor file per session, named art_regression_outliers_*.mat)
        % Regressor matrices contains 1's at the location of each outlier.
        % This implements outlier removal in SPM when these regressor files are used as covariates.
        % <alfnie@gmail.com>
        % 2009-01
    case 4, % save SPM regressors
        savefile_Callback_SaveRegressor(handles);
    case 5, % save mask
        savefile_Callback_SaveMask(handles);
end

cd(tmpdir);

function savefile_Callback_SaveRegressor(handles)
g = getappdata(handles.zthresh,'g');
M = getappdata(handles.savefile,'mv_data_raw');
num_sess = length(g);
out_idx = round(str2num(get(handles.all_outliers, 'String')));
datafiles=getappdata(handles.savefile,'datafiles');

cur_idx=0;
for j=1:num_sess,
    idx=find(out_idx>cur_idx&out_idx<=cur_idx+size(g{j},1));
    R1=zeros(size(g{j},1),length(idx));
    R1(out_idx(idx)-cur_idx,:)=eye(length(idx));
    R2=cat(2,R1,M{j});
    [datafiles_path,datafiles_name,datafiles_ext] = fileparts(datafiles{j});
    disp(['Saving SPM regressor file ',fullfile(datafiles_path,['art_regression_outliers_',datafiles_name,'.mat']),' and ',fullfile(datafiles_path,['art_regression_outliers_and_movement_',datafiles_name,'.mat'])]);
    try
        R=R1;save(fullfile(datafiles_path,['art_regression_outliers_',datafiles_name,'.mat']),'R','-mat');
        R=R2;save(fullfile(datafiles_path,['art_regression_outliers_and_movement_',datafiles_name,'.mat']),'R','-mat');
    catch
        [filename, pathname, filteridx] =uiputfile({'*.mat'},['Save session ',num2str(j),' regressor:'],fullfile(datafiles_path,['art_regression_outliers_',datafiles_name,'.mat']));
        filename = fullfile(char(pathname), char(filename));
        R=R1;save(filename ,'R','-mat');
        [filename, pathname, filteridx] =uiputfile({'*.mat'},['Save session ',num2str(j),' regressor:'],fullfile(datafiles_path,['art_regression_outliers_and_movement_',datafiles_name,'.mat']));
        filename = fullfile(char(pathname), char(filename));
        R=R2;save(filename ,'R','-mat');
    end
    
    cur_idx=cur_idx+size(g{j},1);
end

function savefile_Callback_SaveMask(handles)
output_dir=getappdata(handles.savefile,'dir');
plotdata=load(['art_mask_temporalfile.mat']);%,'maskscan','VY1');
out_idx=round(str2num(get(handles.all_outliers, 'String')));
b=ones(plotdata.VY1.dim);
for n1=setdiff(1:length(plotdata.maskscan),out_idx),b(plotdata.maskscan{n1})=0;end
V=plotdata.VY1;
V.fname=fullfile(output_dir,'art_mask.img');
V.dt=[spm_type('uint8') spm_platform('bigend')];
spm_write_vol(V,b);
disp(['New analysis mask saved to ',V.fname]);

% --- Executes during object creation, after setting all properties.
function all_outliers_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Outputs from this function are returned to the command line.
function varargout = art_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function zthresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function mvthresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function rtthresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% reads a siemens motion detection parameter file
% Oliver Hinds <ohinds@mit.edu>
% 2007-07-23
function mp = read_siemens_motion_parm_file(fname)

mp = [];

% open the file
fp = fopen(fname);

if fp == -1
    error('coulnd''t open motion parm file.');
%     return (error exits the function. return is never executed (DRG))
end

% read each parameter
i = 1;
while(~feof(fp))
    % read the motion header
    fscanf(fp,'%s',6);
    
    if feof(fp)
        break;
    end
    
    if i == 1
        fscanf(fp,'%s',5);
    end
    
    fscanf(fp,'%s',7);
    
    
    for j=1:6
        fscanf(fp,'%s',4);
        mp(i,j) = fscanf(fp,'%f',1);
    end
    
    fscanf(fp,'%s',1);
    
    i=i+1;
end

% siemens keeps their params in a different order than spm does,
% and their rotations in degrees.
% fix it
m = mp;
mp(:,4:6) = m(:,4:6)*pi/180;
mp(:,1)   = m(:,2);
mp(:,2)   = m(:,1);
mp(:,3)   =-m(:,3);


return

%% BEGIN ohinds 2008-04-23: read session file
% read an art session file
function [num_sess,global_type_flag,drop_flag,motionFileType,motion_threshold,global_threshold,use_diff_motion,use_diff_global,use_norms,SPMfile,mask_file,output_dir,P,M] = read_art_sess_file(sess_file)

if ~exist(sess_file)
    error(['session file ' sess_file ' cant be opened']);
end

num_sess = 1;
global_type_flag = 1;
drop_flag = 0;
motionFileType = 0;
image_dir = '';
motion_dir = '';
auto_motion_fname = 0;
motion_threshold=[];
global_threshold=[];
use_diff_motion=1;
use_diff_global=1;
use_norms=1;
SPMfile=[];
mask_file=[];
output_dir=[];

fp = fopen(sess_file);

% read each param
s = fscanf(fp,'%s',1);
while(~strcmp(s,'end'))
    if length(s)>1 && s(1) == '#'
        % skips until end of line
        nill=fgetl(fp);
    elseif strcmp(s,'sessions:')
        % num_sessions
        num_sess = fscanf(fp,'%d',1);
    elseif strcmp(s,'global_mean:')
        % global_type_flag
        global_type_flag = fscanf(fp,'%d',1);
    elseif strcmp(s,'drop_flag:')
        % drop_flag
        drop_flag = fscanf(fp,'%d',1);
    elseif strcmp(s,'motion_file_type:')
        motionFileType = fscanf(fp,'%d',1);
    elseif strcmp(s,'image_dir:')
        image_dir = fscanf(fp,'%s',1);
    elseif strcmp(s,'motion_dir:')
        motion_dir = fscanf(fp,'%s',1);
    elseif strcmp(s,'motion_fname_from_image_fname:')
        auto_motion_fname = str2num(fscanf(fp,'%s',1));
    elseif strcmp(s,'motion_threshold:')
        motion_threshold = fscanf(fp,'%f',1);
    elseif strcmp(s,'global_threshold:')
        global_threshold = fscanf(fp,'%f',1);
    elseif strcmp(s,'spm_file:')
        SPMfile = fscanf(fp,'%s',1);
    elseif strcmp(s,'use_diff_motion:')
        use_diff_motion = fscanf(fp,'%d',1);
    elseif strcmp(s,'use_diff_global:')
        use_diff_global = fscanf(fp,'%d',1);
    elseif strcmp(s,'use_norms:')
        use_norms = fscanf(fp,'%d',1);
    elseif strcmp(s,'mask_file:')
        mask_file = fscanf(fp,'%s',1);
    elseif strcmp(s,'output_dir:')
        output_dir = fscanf(fp,'%s',1);
    end
    s = fscanf(fp,'%s',1);
end
keyboard
M = {};
P = {};
% read the filenames
s = fscanf(fp,'%s',1);
while(~strcmp(s,'end'))
    if strcmp(s,'session')
        sess = fscanf(fp,'%d',1);
        type = fscanf(fp,'%s',1);
        
        
        % set up P
        if size(P,2) < sess
            P{sess} = {};
        end
    elseif s(1) == '#'
        % skips until end of line
        nill=fgetl(fp);
    elseif strcmp(type,'image')
        if any(s=='?'),
            idx=find(s=='?');
            ns=length(idx);
            for sn=0:10^ns-1,
                st=s;st(idx)=num2str(sn,['%0',num2str(ns),'d']);
                if ~isempty(dir(fullfile(image_dir,st))),
                    P{sess}{end+1} = fullfile(image_dir,st);
                end
            end
            s(idx)=num2str(1,['%0',num2str(ns),'d']);
        else 
            P{sess}{end+1} = fullfile(image_dir,s);
        end
        
        if auto_motion_fname && length(P{sess})<=1
            tmotion_dir=image_dir;
            if motionFileType == 2
                M{sess} = read_siemens_motion_parm_file(strprepend('',fullfile(tmotion_dir,s),'.txt'));
            elseif motionFileType == 0
                M{sess}=[];
                for n1=0:5,
                    if ~isempty(dir(strprepend('concat_rp_',strprepend(-n1,fullfile(tmotion_dir,s)),'.txt'))),
                        M{sess} = load(strprepend('concat_rp_',strprepend(-n1,fullfile(tmotion_dir,s)),'.txt'));
                        break;
                    end
                end
                if isempty(M{sess}),error(['No motion file found: ',strprepend('rp_',fullfile(tmotion_dir,s),'.txt'),' or similar']); end
            elseif motionFileType == 1
                M{sess} = load(strprepend('',fullfile(tmotion_dir,s),'.par'));
            end
        end
        
    elseif strcmp(type,'movement') || strcmp(type,'motion')
        if motionFileType == 2
            M{sess} = read_siemens_motion_parm_file(fullfile(motion_dir,s));
        else
            M{sess} = load(fullfile(motion_dir,s));
        end
    end
    s = fscanf(fp,'%s',1);
end

for i=1:numel(P)
    P{i} = strvcat(P{i}); %make_spm_file_matrix(P{i});
end

fclose(fp);

return

function [idx,data1]=art_maskglobal_scan(data,VYi,VY1,VY1inv)
idx=find(~isnan(data));
data1=data>mean(data(idx))/8; % global-signal mask
data=(data>0.80*mean(data(data1>0))); % analysis mask
idx=find(data~=true);
if any(any(VYi.mat~=VY1.mat)),
    [tempx,tempy,tempz]=ind2sub(VYi.dim(1:3),idx);
    xyz=round(VY1inv*VYi.mat*[tempx(:),tempy(:),tempz(:),ones(numel(tempx),1)]');
    idx=sub2ind(VY1.dim(1:3),max(1,min(VY1.dim(1),xyz(1,:))),max(1,min(VY1.dim(2),xyz(2,:))),max(1,min(VY1.dim(3),xyz(3,:))));
end
idx=uint32(idx(:));

            
% take a cell array and pad appropritately to make a matrix
function m = make_spm_file_matrix(p)

mx = -1;
for i=1:numel(p)
    if size(p{i},2) > mx
        mx = size(p{i},2);
    end
end

m = char(32*ones(numel(p),mx));
for i=1:numel(p)
    m(i,mx-length(p{i})+1:end) = p{i};
end

return

%% END ohinds 2008-04-23: read session file

function z = zscore(x)
%ZSCORE Standardized z score.
% z=zscore(x);
%
stdx=std(x);stdx(stdx==0)=1;
z=(x-mean(x))./stdx;
return;

function d=range(x)
%RANGE  Sample range.
%d=range(x);
%
d=max(x)-min(x);
return;

function fileout=strprepend(str1,file,str2)

[fpath,ffile,fext]=fileparts(file);
if nargin<3, str2=fext; end
if ~ischar(str1),ffile=ffile(1+abs(str1):end);str1=''; end
if ~ischar(str2),ffile=ffile(1:end-abs(str2));str2=''; end
fileout=fullfile(fpath,[str1,ffile,str2]);

function cumdisp(txt)
% CUMDISP persistent disp
% cumdisp; initializes persistent display
% cumdisp(text); displays persistent text
%
persistent oldtxt;
if nargin<1,
    oldtxt=''; 
    fprintf(1,'\n'); 
else 
    fprintf(1,[repmat('\b',[1,length(oldtxt)]),txt]);
    oldtxt=sprintf(txt);
end

function z=prctile(x,p)
nx=length(x);
z=zeros(size(p));
sx=sort(x);
q = [0,100*(0.5:(nx-0.5))./nx,100]';
xx = [sx(1);sx(:);sx(end)];
z(:) = interp1q(q,xx,p(:));


function w=hanning(n)

if ~rem(n,2),%even
    w = .5*(1 - cos(2*pi*(1:n/2)'/(n+1))); 
    w=[w;flipud(w)];
else %odd
   w = .5*(1 - cos(2*pi*(1:(n+1)/2)'/(n+1)));
   w = [w; flipud(w(1:end-1))];
end


%************************************************************************%
%%% $Source: /home/ohinds/cvs/mri/analysis/matlab/art/art.m,v $
%%% Local Variables:
%%% mode: Matlab
%%% fill-column: 76
%%% comment-column: 0
%%% End:
