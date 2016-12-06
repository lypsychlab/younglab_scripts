function snr_sd(varargin)
%snr_sd.m
%Calculates the mean, SD, and mean/SD (ie: SNR) seperately for each run 
%Outputs files called subject_snr_sd_runX.img in a folder called SNR
%Based on the script sd_images by Bas Neggers 2004
%DDW.2007.05.20
%Fixed spm scaling issue (2007.12.04) ddw
%Added ability to output .ps files (2007.12.06) ddw
%Fixed hardcoding for swuabold (allows for any swbold, which can occur if
%you opt not to do slicetiming correction) (2008.1.24) ddw.
%Fixed the way it determine if data is preprocessed, also it will now spit
%out a figure for raw bold data if no preprocessed data exists (2008.02.01)
%
% Usage:
% e.g. % snr_sd('SHAPES','YOU_SHAPES_01')

%Check inputs
if nargin==0
    msg1='Please specify the study name and a subject id, e.g. snr_sd(''SHAPES'',''YOU_SHAPES_01'')';
    error(msg1);
  
elseif nargin==1
    msg2='You''ve specified too few inputs. Please enter the study and subject name please. e.g. snr_sd(''SHAPES'',''YOU_SHAPES_01'')';
    error(msg2);
  
elseif nargin==2
    study = varargin{1};
    subjID = varargin{2};
else
    msg3='You''ve specified too many inputs. Please enter the study and subject name please. e.g. snr_sd(''SHAPES'',''YOU_SHAPES_01'')';
    error(msg3);
end

%turn on spm_defaults
spm_get_defaults;

%Init basic variable
EXPERIMENT_ROOT_DIR = '/home/younglw/lab';
functional_dir = 'bold';
data_dir= [EXPERIMENT_ROOT_DIR,'/', study, '/', subjID,'/',functional_dir,'/'];

% ================ To gather images for all spm steps =================
% First gather directory for current subject
cd(data_dir);
subj_dir = dir('0*');
if exist('func_runs')
    clear func_runs
end

% Now filter out BS and populate a cell array of functional run
% directories
x=1;
pace=1; % this is always 1 if pace protocol is used!

for dir_index=1:(1+pace):length(subj_dir) %if pace takes odd runs
    if subj_dir(dir_index).isdir && subj_dir(dir_index).name(1) == '0'
        func_runs{x} = subj_dir(dir_index).name;
        x=x+1;
    end
end

% figure out number of runs
numruns = length(func_runs);

%=====================================================================

%Go to the subject's directory
try
 cd(data_dir);
catch
  msg3=['I can''t seem to get to the subject''s dir. Are you sure ' ...
        'this path is correct? ',data_dir];
  error(msg3);
end

%Turn off annoying warnings
warning off MATLAB:divideByZero;
warning off

%Determine current preprocessed bold.
if ~isempty(dir([data_dir,char(func_runs(1)),'/','swraf*.hdr']))
    bold = 'swraf';
    bolddir = 'SWRABOLD';
elseif ~isempty(dir([data_dir,char(func_runs(1)),'/','swrf*.hdr']))
    bold = 'swrf';
    bolddir = 'SWRBOLD';
elseif ~isempty(dir([data_dir,char(func_runs(1)),'/','wraf*.hdr']))
    bold = 'wraf';   
    bolddir = 'WRABOLD';
elseif ~isempty(dir([data_dir,char(func_runs(1)),'/','wrf*.hdr']))
    bold = 'wrf';   
    bolddir = 'WRABOLD';
else
    bold = 'f';   
    bolddir = 'BOLD';
end  
    
%Check for presence of preprocessing
if strcmp(bold,'f') ~= 1
    %Do SD for preprocessed BOLDS
    for ii=1:numruns
    disp(['Calculating snr_sd on preprocessed data for run ', func_runs{ii}])
    
    % go into the bold directory
    cd([data_dir, func_runs{ii}]);
    
    files = spm_vol(spm_select('list','.',['^',bold,'.+img']));
    data=spm_read_vols(files(1));
    avg=zeros(size(data));
    sd_tmp=zeros(size(data));
    n=size(files,1);
    disp('Calculating average signal:')
    for i=1:n,
        data=spm_read_vols(files(i));
        avg=avg+data/n;
        fprintf ('.')
    end
    disp(' ')
    disp('Calculating standard deviation:')
    for i=1:n,
        data=spm_read_vols(files(i));
        sd_tmp=sd_tmp+(avg-data).^2;  
        fprintf('.')
    end
    disp(' ')
    sd=sqrt(sd_tmp/(n-1));
    snr=avg./sd;
    
    %Clean up snr varaible
    snr(isnan(snr))=0;
    snr(snr>5000)=0; %eliminates the absurdly high values that can occur outside the brain
  
    %Make sure SNR directories exists
    try
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR']);
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_AVERAGE']); 
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SD']);
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SNR']);
    end

    %output files to the SNR dir
    avg_output=files(1);
    sd_output=files(1);
    snr_output=files(1);
    avg_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_AVERAGE/',subjID,'_average_run',func_runs{ii},'.img'];
    sd_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SD/',subjID,'_sd_run',func_runs{ii},'.img'];
    snr_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SNR/',subjID,'_snr_run',func_runs{ii},'.img'];
    
    %spm_write_vol(avg_output,avg); %this way outputs as float, but with a scaling factor
    %spm_write_vol(sd_output,sd);
    %spm_write_vol(snr_output,snr);
    
    %the following method keeps the scaling factor set to 1
    avg_output=spm_create_vol(avg_output);
    sd_output=spm_create_vol(sd_output);
    snr_output=spm_create_vol(snr_output);
    disp('Writing out volumes:')
    for i=1:avg_output.dim(3);
        avg_output=spm_write_plane(avg_output,avg(:,:,i),i);
        sdoutput=spm_write_plane(sd_output,sd(:,:,i),i);
        snr_output=spm_write_plane(snr_output,snr(:,:,i),i); 
        fprintf ('.')
    end
    disp(' ')

    
    end %end snr_sd on preprocessed data for all runs
   
    %######Do snr on average of all Runs.
    if numruns>1
        
        %Make sure SNR directories exists
        try
            [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/']); 
        end

        for ii=1:numruns
            % go into the bold directory
            cd([data_dir, func_runs{ii}]);
            copyfile([bold '*'],[EXPERIMENT_ROOT_DIR,'/',study,'/SNR/'])
        end
        disp('Calculating snr_sd on preprocessed data for average of all runs')
        cd([EXPERIMENT_ROOT_DIR,'/',study,'/SNR/']);
        files = spm_vol(spm_select('list','.',['^',bold,'.+img']));
        data=spm_read_vols(files(1));
        avg=zeros(size(data));
        sd_tmp=zeros(size(data));
        n=size(files,1);
        disp('Calculating average signal:')
        for i=1:n,
            data=spm_read_vols(files(i));
            avg=avg+data/n;
            fprintf ('.')
        end
        disp(' ')
        disp('Calculating standard deviation:')
        for i=1:n,
            data=spm_read_vols(files(i));
            sd_tmp=sd_tmp+(avg-data).^2;  
            fprintf('.')
        end
        disp(' ')
        sd=sqrt(sd_tmp/(n-1));
        snr=avg./sd;
    
        %Clean up snr varaible
        snr(isnan(snr))=0;
        snr(snr>5000)=0; %eliminates the absurdly high values that can occur outside the brain
        
    
        %Make sure SNR directories exists
        try
            [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/']); 
        end

        %output files to the SNR dir
        avg_output=files(1);
        sd_output=files(1);
        snr_output=files(1);
        avg_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',subjID,'_average.img'];
        sd_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',subjID,'_sd.img'];
        snr_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',subjID,'_snr.img'];
    
        %spm_write_vol(avg_output,avg); %this way outputs as float, but with a scaling factor
        %spm_write_vol(sd_output,sd);
        %spm_write_vol(snr_output,snr);
    
        %the following method keeps the scaling factor set to 1
        avg_output=spm_create_vol(avg_output);
        sd_output=spm_create_vol(sd_output);
        snr_output=spm_create_vol(snr_output);
        disp('Writing out volumes:')
        for i=1:avg_output.dim(3);
            avg_output=spm_write_plane(avg_output,avg(:,:,i),i);
            sdoutput=spm_write_plane(sd_output,sd(:,:,i),i);
            snr_output=spm_write_plane(snr_output,snr(:,:,i),i); 
            fprintf ('.')
        end
        disp(' ')
    end
    
    % delete copies of bold files
    cd([EXPERIMENT_ROOT_DIR,'/',study,'/SNR/']);
    delete([bold '*']);    
    
else
    msg4=['It appears the subject ', subjID, ' has not yet been preprocessed with spm8.' ...
            'snr_sd will only operate on the RAW bold images'];
    disp(msg4)
end

%Calculate SD per run for raw data
for ii=1:numruns
    disp(['Calculating snr_sd on raw data for run ', func_runs{ii}])
    cd([data_dir, func_runs{ii}]);
    files = spm_vol(spm_select('list','.',['^',bold,'.+img']));
    data=spm_read_vols(files(1));
    avg=zeros(size(data));
    sd_tmp=zeros(size(data));
    n=size(files,1);
    disp('Calculating average signal:')
    for i=1:n,
        data=spm_read_vols(files(i));
        avg=avg+data/n;
        fprintf ('.')
    end
    disp(' ')
    disp('Calculating standard deviation:')
    for i=1:n,
        data=spm_read_vols(files(i));
        sd_tmp=sd_tmp+(avg-data).^2;  
        fprintf('.')
    end
    disp(' ')
    sd=sqrt(sd_tmp/(n-1));
    snr=avg./sd;
    
    %Clean up snr varaible
    snr(isnan(snr))=0;
    snr(snr>5000)=0; %eliminates the absurdly high values that can occur outside the brain
        
    
    %Make sure SNR directories exists
    try
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR']);
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/BOLD_AVERAGE']); 
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/BOLD_SD']);
        [s,w]=unix(['mkdir ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/BOLD_SNR']);
    end

    %output files to the SNR dir
    avg_output=files(1);
    sd_output=files(1);
    snr_output=files(1);
    avg_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/BOLD_AVERAGE/',subjID,'_average_run',func_runs{ii},'.img'];
    sd_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/BOLD_SD/',subjID,'_sd_run',func_runs{ii},'.img'];
    snr_output.fname    = [EXPERIMENT_ROOT_DIR,'/',study,'/SNR/BOLD_SNR/',subjID,'_snr_run',func_runs{ii},'.img'];
    
    %spm_write_vol(avg_output,avg); %this way outputs as float, but with a scaling factor
    %spm_write_vol(sd_output,sd);
    %spm_write_vol(snr_output,snr);
    
    %the following method keeps the scaling factor set to 1
    avg_output=spm_create_vol(avg_output);
    sd_output=spm_create_vol(sd_output);
    snr_output=spm_create_vol(snr_output);
    disp('Writing out volumes:')
    for i=1:avg_output.dim(3);
        avg_output=spm_write_plane(avg_output,avg(:,:,i),i);
        sdoutput=spm_write_plane(sd_output,sd(:,:,i),i);
        snr_output=spm_write_plane(snr_output,snr(:,:,i),i); 
        fprintf ('.')
    end
    disp(' ')
end %end snr_sd on raw data for all runs

%write completed
disp(['Subject ',subjID,' SNR_sd calculated and stored in ',EXPERIMENT_ROOT_DIR,'/',study,'/SNR/'])
%Return to root
cd(EXPERIMENT_ROOT_DIR);

%##########################################################
%New part, might be buggy.
%Make and print out figures.
%So Far it only makes figures for preprocessed data only. 

%Removes previous .ps files so as not to over-append
if exist([EXPERIMENT_ROOT_DIR,'/',study,'/',subjID,'/',subjID,'_snr.ps']);
    delete([EXPERIMENT_ROOT_DIR,'/',study,'/',subjID,'/',subjID,'_snr.ps']);
end

if ~isempty(dir([data_dir,char(func_runs(1)),'/','*.hdr']))
    subj2 = regexprep(subjID,'_','\_'); %small fix for figure printing
    currentplot = 1;
    for ii=1:numruns
        %load files
        cd([EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_AVERAGE/']);
        files_avg=spm_vol(spm_select('list',[EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_AVERAGE/'],[subjID,'_average_run',func_runs{ii},'.img']));
        data_avg=spm_read_vols(files_avg);
        cd([EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SD/']);
        files_sd=spm_vol(spm_select('list',[EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SD/'],[subjID,'_sd_run',func_runs{ii},'.img']));
        data_sd=spm_read_vols(files_sd);
        cd([EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SNR/']);
        files_snr=spm_vol(spm_select('list',[EXPERIMENT_ROOT_DIR,'/',study,'/SNR/',bolddir,'_SNR/'],[subjID,'_snr_run',func_runs{ii},'.img']));
        data_snr=spm_read_vols(files_snr);
        %Slices
        slice1_avg=squeeze(data_avg(:,:,20));
        slice2_avg=squeeze(data_avg(:,:,24));
        slice1_sd=squeeze(data_sd(:,:,20));
        slice2_sd=squeeze(data_sd(:,:,24));
        axial1_snr=squeeze(data_snr(:,:,20));
        axial2_snr=squeeze(data_snr(:,:,24));
        sagital_snr=squeeze(data_snr(26,:,:));
        coronal_snr=squeeze(data_snr(:,32,:));
        if currentplot == 1
            %Do Figure
            width=8.5;
            height=11;
            % Get the screen size in inches
            set(0,'units','inches')
            scrsz=get(0,'screensize');
            % Calculate the position of the figure
            position=[scrsz(3)/2-width/2 scrsz(4)/2-height/2 width height];
            figure(1), clf;
            h=figure(1);
            set(h,'units','inches')
            % Place the figure
            set(h,'position',position)
            % Do not allow Matlab to resize the figure while printing
            set(h,'paperpositionmode','auto')
            % Set screen and figure units back to pixels
            set(0,'units','pixel')
            set(h,'units','pixel')
            %Set colors
            set(gcf,'color',[1 1 1])
            colormap(hot)
        end
        %Start Plotting
        if currentplot == 1
            titlepos = 0.985;
            subpos = 1;
            reduction = 0;
        else
            titlepos = 0.5;
            subpos = 9;
            reduction = 0.475;
        end
        %Plots
        subplot(4,4,subpos)
            set(gca,'position',[0.05,(0.75-reduction),0.2,0.2])
            imagesc(flipud(slice1_avg'),[10,900])
            hold on
            axis equal
            axis off
            title('Avg1','fontweight','bold','position',[27,0.5])
       subplot(4,4,(subpos+1))
            set(gca,'position',[0.26,(0.75-reduction),0.2,0.2])
            imagesc(flipud(slice2_avg'),[10,900])
            hold on
            axis equal
            axis off
            title('Avg2','fontweight','bold','position',[27,0.5])
       subplot(4,4,(subpos+2))
            set(gca,'position',[0.54,(0.75-reduction),0.2,0.2])
            imagesc(flipud(slice1_sd'),[2,20])
            hold on
            axis equal
            axis off
            title('SD1','fontweight','bold','position',[27,0.5])
       subplot(4,4,(subpos+3))
            set(gca,'position',[0.75,(0.75-reduction),0.2,0.2])
            imagesc(flipud(slice2_sd'),[2,20])
            hold on
            axis equal
            axis off
            title('SD2','fontweight','bold','position',[27,0.5])
       subplot(4,4,(subpos+4))
            set(gca,'position',[0.05,(0.53-reduction),0.2,0.2])
            imagesc(flipud(axial1_snr'),[10,350])
            hold on
            axis equal
            axis off
            title('SnR1','fontweight','bold','position',[27,0.5])
       subplot(4,4,(subpos+5))
            set(gca,'position',[0.26,(0.53-reduction),0.2,0.2])
            imagesc(flipud(axial2_snr'),[10,350])
            hold on
            axis equal
            axis off
            title('SnR2','fontweight','bold','position',[27,0.5])
       subplot(4,4,(subpos+6))
            set(gca,'position',[0.54,(0.53-reduction),0.2,0.2])
            imagesc(flipud(sagital_snr'),[10,350])
            hold on
            axis equal
            axis off
            title('SnR Sagital','fontweight','bold','position',[33,0.5])
       subplot(4,4,(subpos+7))
            set(gca,'position',[0.75,(0.53-reduction),0.2,0.2])
            imagesc(flipud(coronal_snr'),[10,350])
            hold on
            axis equal
            axis off
            title('SnR Coronal','fontweight','bold','position',[27,0.5])
       %Title
       ttl = ['SNR\_SD: ',subj2, ' Run ',func_runs{ii}];
       tax = axes('Position',[0.01,titlepos,1,1]);
       tmp= text(0,0,ttl);
       set(tax,'xlim',[0,1],'ylim',[0,1])
       set(tmp,'FontSize',16,'HorizontalAlignment','left','FontWeight','bold')
       axis off
       %Plot checks
       if ii == numruns
               %Print, close and return
               prnstr = ['print -dpsc2 -painters -append ',[EXPERIMENT_ROOT_DIR,'/',study,'/',subjID,'/',subjID,'_snr.ps']];
               eval(prnstr);
               disp(['SNR_SD output printed to ','/',subjID,'/',subjID,'_snr.ps'])
               close (1);
               return;
       end            
       if currentplot == 1
           currentplot = 2;
       else
           %print and clear figure
           prnstr = ['print -dpsc2 -painters -append ',[EXPERIMENT_ROOT_DIR,'/',study,'/',subjID,'/',subjID,'_snr.ps']];
           eval(prnstr);
           pause(0.5);
           clf;
           currentplot = 1;
       end     
    end
end