function [roi_struct] = make_roi_struct_pleiades(study,subjIDs,chosen_roi)
% [roi_struct] = make_roi_struct_PSYCH(study,subjIDs,numsess,anatomical,chosen_roi):
% - formats a structure to hold the names and file names associated with the ROI/S
% in question, as preparation for CONN analyses.
% - The anatomical flag is currently broken; don't use it.
%
% Parameters:
% - study: study name
% - subjIDs: cell string of subject names
% - chosen_roi: cell string of roi names
    rootdir='/home/younglw';
    mkdir(fullfile(rootdir,study,'logs'));
    diary(fullfile(rootdir,study,'logs',['make_roi_struct_' date '.txt']));
	roi_struct=struct('names',[],'files',[]);
	prev_dir=pwd;
    roinames=chosen_roi;
	for sub=1:length(subjIDs)
        for i=1:length(roinames)
            % default to searching for subject-specific ROIs:
            cd(fullfile('/home/younglw',study,subjIDs{sub},'roi'));
            d=fullfile(pwd,['*' roinames{i} '*.img']);
            roi_file_dir=dir(d);
            if length(roi_file_dir) == 0 
                % check for group ROI
                cd(fullfile('/home/younglw',study,'ROI'));
                d=fullfile(pwd,['*' roinames{i} '*.img']);
                roi_file_dir=dir(d);
                if length(roi_file_dir) == 0 
                    % it doesn't exist in /ROI either
                    disp(['No ' roinames{i} ' in either group or subject ROI folders.'])
                    return
                end
            end
            disp(['Entering information for ' roinames{i} '...']);
            roi_file=fullfile(pwd,roi_file_dir(1).name);
            roi_struct.names{i}=roinames{i};
            roi_struct.files{i}{sub}=roi_file;
            disp([roinames{i} ' complete.']);
        end
    end %end first subject loop 
    
	cd(prev_dir);
    diary off;
end %end make_roi_struct_IEH

