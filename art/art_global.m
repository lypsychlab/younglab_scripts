function art_global(varargin)
% FORMAT art_global(varargin)
%
%     Art_global is the latest version of a script intended to allow 
% visual inspection of fMRI data and automated or by-hand removal of 
% 'outlier' scans, whose intensities are radically different from the
% mean of the timeseries.  
%     "Radically different" is a user-set threshold of standard deviations
% from the mean which is set interactively in the graphical viewing window.
% A default minimum threshold for outliers is set at 1.5% of the mean value. 
% This limit corresponds to the 3-sigma limit for expected 
% physiological noise with an RMS value of 0.5% on a 3T scanner.
%     Outlier scans are selected automatically as points above the
% threshold, and the threshold can be adjusted up or down using the Up or
% Down buttons. Outlier scans can also be selected manually by text editing
% the list of outlier scans.
%     The script offers two choices of removal methods - insertion of the 
% global mean, or interpolation from surrounding scans. 
%     New features of this version include an option to automatically
% generate a custom mask for the image, and an option to run cases without
% a movement parameter file, i.e. before realignment is done. Note for some
% cases that the automatically generated mask or a user defined mask are
% necessary for accurate results.
% ----------------------------------------------------------------------
%
% Paul Mazaika, April 2004.
% from artdetect4.m, by Jeff Cooper, Nov. 2002
% from artdetect3.m, by Sue Whitfield + Max Gray.


% -----------------------
% Initialize, begin loop
% -----------------------

pfig = [];
%intfig = [];
%do_more = 1;
%while do_more == 1;

% ------------------------
% Default values for outliers
% ------------------------
%  Deviations over 2*std are outliers, if std is not very small.
      z_thresh = 2;  % Currently not used for default.

% When std is very small, set a minimum threshold based on expected physiological
% noise. Scanners have about 0.1% error when fully in spec. 
% Gray matter physiology has ~ 1% range, ~0.5% RMS variation from mean. 
% For 500 samples, expect a 3-sigma case, so values over 1.5% are
% suspicious as non-physiological noise. Data within that range are not
% outliers. Set the default minimum percent variation to be suspicious...
Percent_thresh = 1.5; 


% ------------------------
% Collect files
% ------------------------

num_sess = spm_input('How many sessions?',1,'n',1,1);

global_type_flag = spm_input('Which global mean to use?', 1, 'm', ...
    'Regular | Every Voxel | User Mask | Auto ( Generates ArtifactMask and can Calculate Movement )',...
              [1 2 3 4], 4);

% If there are no realignment files available, compute some instead.
realignfile = 1;   % Default case is like artdetect4.
if global_type_flag == 4
    %realignfile = spm_input('Have realignment files(1) or not(0)',1);
    realignfile = spm_input('Have realignment files?',1, 'b', ' Yes | No ', [ 1 0 ], 1);
end

M = [];
P = [];
for i = 1:num_sess
    P{i} = spm_get(Inf,'.img',['Select data images for session'  num2str(i) ':']);
    if realignfile == 1
        mvmt_file = spm_get(1,'.txt',['Select movement params file for session' num2str(i) ':']);
        load(mvmt_file);
        [mv_path,mv_name,mv_ext] = fileparts(mvmt_file);
	
        dot = findstr(mv_name, '.');
        if ~(isempty(dot))
           mv_name = mv_name(1:(dot - 1));
        end
        M{i} = eval(mv_name);
    end
end



if global_type_flag==3
    mask = spm_get(1, '.img', 'Select mask image in functional space');
    [maskY,maskXYZmm] = spm_read_vols(spm_vol(mask));
    maskXYZmm = maskXYZmm(:,find(maskY==max(max(max(maskY)))));
end
if global_type_flag == 4   %  Automask option
    disp('Generated mask image is written to file ArtifactMask.img.')
    Pnames = P{1};
    Automask = art_automask(Pnames(1,:),-1,1);
    maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
    voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
end

drop_flag = spm_input('Drop 1st scan of each session?', '+1', 'y/n', [1 0], 2);

if ( drop_flag == 1 & realignfile == 1 )
    for i = 1:num_sess
        currP = P{i};
        currP(1,:) = [];
        P{i} = currP;
        currM = M{i};
        currM(1,:) = [];
        M{i} = currM;
    end
end


P = char(P);
mv_data = [];
for i = 1:length(M)
    mv_data = vertcat(mv_data,M{i});
end



% -------------------------
% get file identifiers and Global values
% -------------------------

fprintf('%-4s: ','Mapping files...')                                  
VY     = spm_vol(P);
fprintf('%3s\n','...done')                                          

if any(any(diff(cat(1,VY.dim),1,1),1)&[1,1,1,0])
	error('images do not all have the same dimensions')
end

nscans = size(P,1);
%keyboard;
% ------------------------
% Compute Global variate
%--------------------------

%GM     = 100;
g      = zeros(nscans,1);

fprintf('%-4s: %3s','Calculating globals...',' ')
if global_type_flag==1  % regular mean
    for i  = 1:nscans  
	    g(i) = spm_global(VY(i));
    end
elseif global_type_flag==2  % every voxel
    for i = 1:nscans
        g(i) = mean(mean(mean(spm_read_vols(VY(i)))));
    end
elseif global_type_flag == 3 % user masked mean
    [dummy, XYZmm] = spm_read_vols(VY(1));
    vinv = inv(VY(1).mat);
    [dummy, idx_to_mask] = intersect(XYZmm', maskXYZmm', 'rows');
    maskcount = length(idx_to_mask);
    for i = 1:nscans
        Y = spm_read_vols(VY(i));
        Y(idx_to_mask) = [];
        voxelcount = prod(size(Y));
        g(i) = mean(Y)*voxelcount/maskcount;
    end
else   %  global_type_flag == 4  %  auto mask
    for i = 1:nscans
        Y = spm_read_vols(VY(i));
        Y = Y.*Automask;
        if realignfile == 0
            output = art_centroid(Y);
            centroiddata(i,1:3) = output(2:4);
            g(i) = output(1)*voxelcount/maskcount;
        else     % realignfile == 1
            g(i) = mean(mean(mean(Y)))*voxelcount/maskcount;
        end
    end
    if realignfile == 0    % change to error values instead of means.
        centroidmean = mean(centroiddata,1);
        for i = 1:nscans
            mv0data(i,:) = centroiddata(i,:) - centroidmean;
        end
    end
end
    
    
fprintf('%s%3s\n','...done\n')
if global_type_flag==3
    fprintf('\n%g voxels were in the user mask.\n', maskcount)
end
if global_type_flag==4
    fprintf('\n%g voxels were in the auto generated mask.\n', maskcount)
end

% ------------------------
% Compute default out indices by z-score, or by Percent-level is std is small.
% ------------------------ 
%  Consider values > Percent_thresh as outliers (instead of z_thresh*gsigma) if std is small.
    gsigma = std(g);
    gmean = mean(g);
    pctmap = 100*gsigma/gmean;
    mincount = Percent_thresh*gmean/100;
    %z_thresh = max( z_thresh, mincount/gsigma );
    z_thresh = mincount/gsigma;        % Default value is PercentThresh.
    z_thresh = 0.1*round(z_thresh*10); % Round to nearest 0.1 Z-score value

    out_idx = (find(abs(zscore(g)) > z_thresh))';


% -----------------------
% Draw initial figure
% -----------------------


figure('Units', 'normalized', 'Position', [0.2 0.2 0.6 0.7]);
rng = range(g);
pfig = gcf;

subplot(5,1,1);
plot(g);
%xlabel(['artifact index list [' int2str(out_idx') ']'], 'FontSize', 8, 'Color','r');
ylabel(['Range = ' num2str(rng)], 'FontSize', 8);
if ( global_type_flag == 1 ) title('Global Mean - Regular SPM'); end
if ( global_type_flag == 2 ) title('Global Mean - Every Voxel'); end
if ( global_type_flag == 3 ) title('Global Mean - User Defined Mask'); end
if ( global_type_flag == 4 ) title('Global Mean - Generated ArtifactMask'); end

subplot(5,1,2);
%thresh_axes = gca;
%set(gca, 'Tag', 'threshaxes');
plot(abs(zscore(g)));
ylabel('std away from mean');

thresh_x = 1:nscans;
thresh_y = z_thresh*ones(1,nscans);
line(thresh_x, thresh_y, 'Color', 'r');

axes_lim = get(gca, 'YLim');
axes_height = axes_lim(1):1:axes_lim(2);
for i = 1:length(out_idx)
    line((out_idx(i)*ones(1, length(axes_height))), axes_height, 'Color', 'r');
end

if realignfile == 1
	subplot(5,1,3);
	plot(mv_data(:,1:3));
	ylabel('movement in mm');
	xlabel('scans');
	legend('x mvmt', 'y mvmt', 'z mvmt',0);
	h = gca;
	set(h,'Ygrid','on');
	
	subplot(5,1,4);
	plot(mv_data(:,4:6));
	ylabel('movement in rad');
	xlabel('scans');
	y_lim = get(gca, 'YLim');
	legend('pitch', 'roll', 'yaw', ['max:' num2str(y_lim(2))], ['min:' num2str(y_lim(1))],0);
	h = gca;
	set(h,'Ygrid','on');
end
if realignfile == 0
    subplot(5,1,3);
	plot(mv0data(:,1:3));
	ylabel('movement in Voxels');
	xlabel('scans');
	legend('x mvmt', 'y mvmt', 'z mvmt',0);
	h = gca;
	set(h,'Ygrid','on');
end 

%keyboard;
h_rangetext = uicontrol(gcf, 'Units', 'characters', 'Position', [10 10 18 2],...
        'String', 'StdDev of data is: ', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_rangenum = uicontrol(gcf, 'Units', 'characters', 'Position', [29 10 10 2], ...
        'String', num2str(gsigma), 'Style', 'text', ...
        'HorizontalAlignment', 'left',...
        'Tag', 'rangenum',...
        'BackgroundColor', [0.8 0.8 0.8]);
h_threshtext = uicontrol(gcf, 'Units', 'characters', 'Position', [25 8 18 2],...
        'String', 'Current threshold (std devs):', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_threshnum = uicontrol(gcf, 'Units', 'characters', 'Position', [44 8 10 2],...
        'String', num2str(z_thresh), 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'threshnum');
h_threshtextpct = uicontrol(gcf, 'Units', 'characters', 'Position', [66 8 18 2],...
        'String', 'Current threshold (% of mean):', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_threshnumpct = uicontrol(gcf, 'Units', 'characters', 'Position', [86 8 10 2],...
        'String', num2str(z_thresh*pctmap), 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'threshnumpct');
h_indextext = uicontrol(gcf, 'Units', 'characters', 'Position', [10 3 15 2],...
        'String', 'Outlier indices: ', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'ForegroundColor', 'r');
h_indexedit = uicontrol(gcf, 'Units', 'characters', 'Position', [25 3.25 40 2],...
        'String', int2str(out_idx), 'Style', 'edit', ...
        'HorizontalAlignment', 'left', ...
        'Callback', 'art_outlieredit',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'indexedit');
h_indexinst = uicontrol(gcf, 'Units', 'characters', 'Position', [66 3 40 2],...
        'String', '[Hit return to update after editing]', 'Style', 'text',...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_repair = uicontrol(gcf, 'Units', 'characters', 'Position', [10 1 10 2],...
        'String', 'Repair', 'Style', 'pushbutton', ...
        'Tooltipstring', 'Repair data by eliminating outliers', ...
        'Callback', 'art_repair');
h_up = uicontrol(gcf, 'Units', 'characters', 'Position', [10 8 10 2],...
        'String', 'Up', 'Style', 'pushbutton', ...
        'TooltipString', 'Raise threshold for outliers', ...
        'Callback', 'art_threshup');
h_down = uicontrol(gcf, 'Units', 'characters', 'Position', [10 6 10 2],...
        'String', 'Down', 'Style', 'pushbutton', ...
        'TooltipString', 'Lower threshold for outliers', ...
        'Callback', 'art_threshdown');

guidata(gcf, g);
setappdata(h_repair,'data',P);



