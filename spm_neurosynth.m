function [good_activations, all_activations, spm_estimate_data] = spm_neurosynth(varargin)
%%%%%%%%%%%%
%Lookup voxel activations on neurosynth.org
%%%%%%%%%%%%
%%REQUIRED: SPM(only tested on 8) must be installed.
%You can use this script in two ways: 
%1) Pass a filename of an analyze-format statmap, or
%2) Estimate an SPM model and load it into the workspace with the "Results" button
%(in order to produce an xSPM structure)
%The script will then scrape neurosynth.org for information about your activations 
%%%%%%%%%%%%
%OPTIONS
%%%%%%%%%%%%
%%-If you pass the string 'savedata', a csv will be saved for each coordinate 
%found in the neurosynth database. 
%%-If you pass the string 'search', the program will search for activations
%in a "searchlight" centered on the given voxel. The default search is to
%test all voxels that share a face with the voxel in question; pass a
%number after the 'search' string to modify the extent of the search (i.e.,
%change the radius of the "searchlight". Beware of greatly diminishing returns,
%both in terms of relevant information and computing time, with higher
%radii (1-3 is probably best).
%-(old, lame search algorithm) If you pass the string 'jitter', coordinates without activation data on Neurosynth will be jittered up to
%5 voxels in all dimensions until information is returned.
%
%example 1A:
%spm_neurosynth(xSPM);
%example 1B:
%spm_neurosynth('my_statmap.hdr'); note that img/nii also work
%example 2:
%spm_neurosynth(xSPM,'savedata');
%example 3:
%spm_neurosynth(xSPM,'savedata','search',1);
%example 4(not really worth using...):
%spm_neurosynth(xSPM,'savedata','jitter')
%%%%%%%%%%%%
%By Drew Linsley (thanks to Jordan Theriault for suggestions + Sylvain Fiedler for the csv routine)
%Updated 1/21/13 -- added functionality for statmaps in analyze format
%Updated 1/18/13 -- "searchlight" routine added to find local voxel information 
%Updated 12/2/12 -- bug fix
%Updated 11/17/12 -- added 'jitter' routine
%%%%%%%%%%%%

if ischar(varargin{1})
input_volume = varargin{1}; 
head = spm_vol(input_volume);
vol = spm_read_vols(head);
xSPM.DIM = head.dim';
mat = head.mat;
[nx,ny,nz] = ind2sub(head.dim,find(vol>0));
xSPM.Z = vol(vol>0);
xSPM.XYZmm = mat*[nx(:,1) ny(:,1) nz(:,1) ones(numel(nx(:,1)),1)]';
xSPM.XYZ = [nx,ny,nz]';

%imat = inv(head.mat);
%origin = imat(1:3,4);

elseif isstruct(varargin{1})
 xSPM = varargin{1};
spm_estimate_data.t_values = xSPM.Z;
spm_estimate_data.t_threshold = xSPM.u;
else
    error('Pass the name of an analyze-format statmap or an xSPM structure')
end
spm_estimate_data.mni_coords = xSPM.XYZmm;
string_in = cellfun(@isstr,varargin);
string_in = varargin(string_in);
num_in = cellfun(@isnumeric,varargin);
num_in = varargin(num_in);
if numel(string_in)>0,
    if cell2mat(strfind(string_in,'savedata'))
        save_trigger = 1;
    end
    if cell2mat(strfind(string_in,'jitter'))
        round_coords = 1;
    end
    if cell2mat(strfind(string_in,'search')),
        search_coords = 1;
        if ~isempty(num_in),
            light_radius = cell2mat(num_in);
            
        else
            light_radius = 1;
        end
    end
end

all_activations = cell(numel(xSPM.XYZmm(1,:)),1);
activation_count = zeros(numel(xSPM.XYZmm(1,:)),1);
fprintf('\rAccessing neurosynth...\r\r')
first_status = 1;
for nn = 1:numel(xSPM.XYZmm(1,:)),
    scrape_here = sprintf('http://neurosynth.org/locations/ajax_data/?loc=%i_%i_%i',xSPM.XYZmm(1,nn),xSPM.XYZmm(2,nn),xSPM.XYZmm(3,nn));
    buffer = java.io.BufferedReader(java.io.InputStreamReader(openStream(java.net.URL(scrape_here))));
    buff_line = char(readLine(buffer));
    buff_line = buff_line(regexp(buff_line,'[[')+1:numel(buff_line)-1);
    brackets = regexp(buff_line,'],');
    
    
    
    if isempty(brackets) && exist('round_coords','var'),
        adj_coords = 0;
        permutation_limit = 1;
        rand_start = 2; %amount of coordinate jitter to start with
        rand_limit = 5; %limit on coordinate jitter... 21 mm
        fprintf('\rJittering empty coordinates...')
        tempXYZmm = zeros(3,1);
        while adj_coords < 1,
            if mod(xSPM.XYZmm(1,nn),2)
                jittered_vec = randperm(rand_start)-round(rand_start/2);
                tempXYZmm(1) = xSPM.XYZmm(1,nn) + jittered_vec(1);
            end
            if mod(xSPM.XYZmm(2,nn),2)
                jittered_vec = randperm(rand_start)-round(rand_start/2);
                tempXYZmm(2) = xSPM.XYZmm(2,nn) + jittered_vec(1);
            end
            if mod(xSPM.XYZmm(3,nn),2)
                jittered_vec = randperm(rand_start)-round(rand_start/2);
                tempXYZmm(3) = xSPM.XYZmm(3,nn) + jittered_vec(1);
            end
            scrape_here = sprintf('http://neurosynth.org/locations/ajax_data/?loc=%i_%i_%i',tempXYZmm(1),tempXYZmm(2),tempXYZmm(3));
            buffer = java.io.BufferedReader(java.io.InputStreamReader(openStream(java.net.URL(scrape_here))));
            buff_line = char(readLine(buffer));
            buff_line = buff_line(regexp(buff_line,'[[')+1:numel(buff_line)-1);
            brackets = regexp(buff_line,'],');
            permutation_limit = permutation_limit + 1;
            if permutation_limit > 5,
                permutation_limit = 1;
                rand_start = rand_start + 1;
            end
            if ~isempty(brackets) || rand_start > rand_limit,
                adj_coords = 1;
                xSPM.XYZmm(:,nn) = tempXYZmm;
                if nn ~= 1
                    fprintf(' ')
                end
            end
        end
        
    elseif isempty(brackets) && exist('search_coords','var'),
        
        [columnsInMesh rowsInMesh pagesInMesh] = meshgrid(1:xSPM.DIM(2),1:xSPM.DIM(1),1:xSPM.DIM(3));
        searchVol = logical((rowsInMesh-xSPM.XYZ(1,nn)).^2 + (columnsInMesh-xSPM.XYZ(2,nn)).^2 + (pagesInMesh-xSPM.XYZ(3,nn)).^2<=light_radius.^2);
        [nx ny nz] = ind2sub(xSPM.DIM',find(searchVol==1));
        rand_order = randperm(numel(nx(:,1)));
        
        search_brackets = cell(numel(nx),2);
        for oo = 1:numel(rand_order),
            scrape_here = sprintf('http://neurosynth.org/locations/ajax_data/?loc=%i_%i_%i',nx(rand_order(oo)),ny(rand_order(oo)),nz(rand_order(oo)));
            buffer = java.io.BufferedReader(java.io.InputStreamReader(openStream(java.net.URL(scrape_here))));
            buff_line = char(readLine(buffer));
            buff_line = buff_line(regexp(buff_line,'[[')+1:numel(buff_line)-1);
            search_brackets{oo,1} = buff_line;%regexp(buff_line,'],');
            search_brackets{oo,2} = regexp(buff_line,'],');
        end
        
        return_count = cellfun(@numel,search_brackets(:,1));
        if numel(return_count) == 1,
            brackets = {};
        else
            return_count = find(return_count==(max(return_count)));
            buff_line = search_brackets{return_count,1};
            brackets = search_brackets{return_count,2};
        end
    end
    
    
    if ~isempty(brackets),
        results = cell(numel(brackets),7);
        status = '<^>v';
        status_count = 1;
        this_coord = strcat('(',num2str(xSPM.XYZmm(:,nn)'),')');
        for nm = 1:numel(brackets),
            if nm == 1,
                this_result = buff_line(1:brackets(1));
            else
                this_result = buff_line(brackets(nm-1)+2:brackets(nm));
            end
            this_result_ind = regexp(this_result,'[a-z]');
            results{nm,1} = this_coord;
            results{nm,2} = xSPM.Z(nn);
            results{nm,3} = nm;
            results{nm,4} = this_result(this_result_ind(1):this_result_ind(numel(this_result_ind)));
            this_result_probs = regexp(this_result,'\d');
            results{nm,5} = str2double(this_result(this_result_probs(1):this_result_probs(3)));
            results{nm,6} = str2double(this_result(this_result_probs(4):this_result_probs(6)));
            if exist('adj_coords','var')
                if adj_coords,
                    results{nm,7} = 'Yes';
                end
            else
                results{nm,7} = 'No';
            end
            if first_status == 1,
                fprintf(sprintf('%s',status(status_count)));
                first_status = first_status + 1;
            else
                fprintf(sprintf('\b%s',status(status_count)));
            end
            status_count = status_count + 1;
            if status_count > numel(status),
                status_count = 1;
            end
        end
        z_ind = cell2mat(results(:,5));
        z_ind(:,2) = 1:numel(z_ind);
        z_ind = sortrows(z_ind,-1);
        t_results = cell(numel(results(:,1)),numel(results(1,:)));
        for nm = 1:numel(t_results(:,1)),
            t_results(nm,:) = results(z_ind(nm,2),:);
            t_results{nm,3} = nm; %comment this if you'd prefer sorting to reflect neurosynth default order as opposed to z-score
        end
        activation_count(nn) = 1;
    else
        
        
        t_results = cell(1,3);
        t_results{1,1} = 'No data for this coordinate';
        t_results{1,2} = 0;
        t_results{1,3} = 0;
        activation_count(nn) = 0;
    end
    all_activations{nn} = t_results;
    %t_results = cell(1);
end
good_activations = all_activations;
good_activations = good_activations(logical(activation_count));
csv_activations = [];
%dumb method but whatever...
for nn = 1:numel(good_activations(:,1)),
    csv_activations = [csv_activations;good_activations{nn}];
end
header = cell(1,6);
header{1} = 'MNI Coordinates';
header{2} = 'Contrast T-value';
header{3} = 'Label Number';
header{4} = 'Anatomical Label';
header{5} = 'Z-score';
header{6} = 'Posterior Probability';
header{7} = 'Rounded Coordinate?';
csv_activations = [header;csv_activations];

'Anatomical Label';
activation_coords = spm_estimate_data.mni_coords(:,logical(activation_count));
for nn = 1:numel(activation_coords(1,:)),
    good_activations{nn,2} = activation_coords(:,nn);
end

if exist('save_trigger','var'),
    
    fprintf(sprintf('\rWriting activations to csv'))
    csv_name = sprintf('results_for_%i_activations.csv',numel(good_activations(:,1)));
    cell2csv(csv_name,csv_activations);
    
    if sum(activation_count) > 0,
        sort_string = 'Sort by z-score or posterior probability!!';
    else
        sort_string = '';
    end
    fprintf(sprintf('\rOutput written as %s to %s\r%s',csv_name,pwd,sort_string))
end

status = sprintf('\rFound data for %i/%i voxels\r',sum(activation_count),numel(xSPM.XYZmm(1,:)));
if exist('adj_coords','var')
    status = strcat(status,'\rSome coordinates were adjusted to find the nearest NeuroSynth activation data\r');
end
fprintf(status);


function cell2csv(fileName, cellArray, separator, excelYear, decimal)
% Writes cell array content into a *.csv file.
%
% CELL2CSV(fileName, cellArray, separator, excelYear, decimal)
%
% fileName     = Name of the file to save. [ i.e. 'text.csv' ]
% cellArray    = Name of the Cell Array where the data is in
% separator    = sign separating the values (default = ';')
% excelYear    = depending on the Excel version, the cells are put into
%                quotes before they are written to the file. The separator
%                is set to semicolon (;)
% decimal      = defines the decimal separator (default = '.')
%
%         by Sylvain Fiedler, KA, 2004
% updated by Sylvain Fiedler, Metz, 06
% fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler
% added the choice of decimal separator, 11/2010, S.Fiedler

%% Checking fr optional Variables
if ~exist('separator', 'var')
    separator = ',';
end

if ~exist('excelYear', 'var')
    excelYear = 1997;
end

if ~exist('decimal', 'var')
    decimal = '.';
end

%% Setting separator for newer excelYears
if excelYear > 2000
    separator = ';';
end

%% Write file
datei = fopen(fileName, 'w');

for z=1:size(cellArray, 1)
    for s=1:size(cellArray, 2)
        
        var = eval(['cellArray{z,s}']);
        % If zero, then empty cell
        if size(var, 1) == 0
            var = '';
        end
        % If numeric -> String
        if isnumeric(var)
            var = num2str(var);
            % Conversion of decimal separator (4 Europe & South America)
            % http://commons.wikimedia.org/wiki/File:DecimalSeparator.svg
            if decimal ~= '.'
                var = strrep(var, '.', decimal);
            end
        end
        % If logical -> 'true' or 'false'
        if islogical(var)
            if var == 1
                var = 'TRUE';
            else
                var = 'FALSE';
            end
        end
        % If newer version of Excel -> Quotes 4 Strings
        if excelYear > 2000
            var = ['"' var '"'];
        end
        
        % OUTPUT value
        fprintf(datei, '%s', var);
        
        % OUTPUT separator
        if s ~= size(cellArray, 2)
            fprintf(datei, separator);
        end
    end
    if z ~= size(cellArray, 1) % prevent a empty line at EOF
        % OUTPUT newline
        fprintf(datei, '\n');
    end
end
% Closing file
fclose(datei);
% END

