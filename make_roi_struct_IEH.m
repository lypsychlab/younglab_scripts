function [roi_struct] = make_roi_struct_IEH(study,subjIDs,numsess,anatomical,chosen_roi)
% [roi_struct] = make_roi_struct_PSYCH(study,subjIDs,numsess,anatomical,chosen_roi):
% - formats a structure to hold the names and file names associated with the ROI/S
% in question, as preparation for CONN analyses.
% - The anatomical flag is currently broken; don't use it.
%
% Parameters:
% - study: study name
% - subjIDs: cell string of subject names
% - numsess: number of sessions (put 0 for now)
% - anatomical: whether or not to include atlas ROIs (put 0 for now)
% - chosen_roi: cell string of roi names
    rootdir='/younglab/studies';
    mkdir(fullfile(rootdir,study,'logs'));
    diary(fullfile(rootdir,study,'logs',['make_roi_struct_IEH_' date '.txt']));
	roi_struct=struct('names',[],'files',[]);
	prev_dir=pwd;
    roinames=chosen_roi;
	for sub=1:length(subjIDs)
        for i=1:length(roinames)
            if strcmp(roinames{i},'RTPJ')
                cd(fullfile('/younglab/studies',study,subjIDs{sub},'roi'));
            else
                cd(fullfile('/younglab/studies',study,'ROI'));
            end
            d=fullfile(pwd,['*' roinames{i} '*.img']);
            roi_file_dir=dir(d);
            disp(roinames{i});
            disp(num2str(length(roi_file_dir)));
            roi_file=fullfile(pwd,roi_file_dir(1).name);
            roi_struct.names{i}=roinames{i};
            roi_struct.files{i}{sub}=roi_file;
        end
    end %end first subject loop 
    
    if anatomical %import anatomical rois from CONN
        n0=length(roi_struct.names);
        anat_path='/software/conn_15/conn/rois';
        anat_names=cat(1,dir(fullfile(anat_path,'*.nii')),...
            dir(fullfile(anat_path,'*.img')),...
            dir(fullfile(anat_path,'*.tal')));
        for n1=1:length(anat_names)
            [nill,name,nameext]=fileparts(anat_names(n1).name);
            filename=fullfile(anat_path,anat_names(n1).name);
            [V,str,icon,filename]=conn_getinfo(filename);
            roi_struct.names{n0+n1}=name; roi_struct.names{n0+n1+1}=' ';
            for sub=1:length(subjIDs), 
                    for sess=1:numsess
                        roi_struct.files{sub}{n0+n1}={filename,str,icon};
                    end
            end
            
        end %end n1 loop        
    end %end if anatomical
    
	cd(prev_dir);
    diary off;
end %end make_roi_struct_IEH

