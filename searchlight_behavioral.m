function searchlight_behavioral(study,subj_tag,resdir,con_tag,behav_name,out_name)

	

	%these lines are dumb, but leave them in as a placeholder in the event of later edits
	% rootdir = '/ncf/mcl/03/alek/';
	rootdir ='/mnt/englewood/data/'
	% folders = dir([rootdir '1*']); %modify depending on dir structure
	% study=study;
	% subjIDs = [1:7 9:18];
	% subjIDs=subjIDs;
	% conditions=conditions; %number of conditions
	cd('/younglab/scripts/');
	load voxel_order2; 
	load greymattermask2;


	disp('Loading behavioral info...')
    load(fullfile(rootdir,study,'behavioural',[behav_name '.mat']));
    sub_nums = B(:,1);
    B=B(:,2);

    subjIDs={};
	for sub=1:length(sub_nums)
		subjIDs{end+1}=sprintf([subj_tag '_' '%02d'],sub_nums(sub));
	end

	disp('Loading searchlight images...')
	searchlights = [];
	for subj=1:length(subjIDs) 

	    searchlights = [searchlights; [fullfile(rootdir,study,subjIDs{subj},'results',resdir,['RSA_searchlight_' con_tag '.img']) ',1']]
	end
	searchlights
    searchlights = spm_vol(searchlights); %spm_vol reads header info
    [Y,XYZ]   = spm_read_vols(searchlights);clear XYZ; %read volumes

    disp('Initializing output template...')
    out_map = zeros(size(Y(:,:,:,1)));

    disp(['Iterating through voxels...'])
    for i=1:length(greymattermask2) %yeah looks like it
    	subj_values_list=[];
    	for subj=1:length(subjIDs)
            subj_value = Y(voxel_order2(greymattermask2(i),1),...
                    voxel_order2(greymattermask2(i),2),...
                    voxel_order2(greymattermask2(i),3),subj);
            subj_values_list=[subj_values_list; subj_value];
        end
        [R,P]=corrcoef(subj_values_list,B);
        out_map(voxel_order2(greymattermask2(i),1),...
                    voxel_order2(greymattermask2(i),2),...
                    voxel_order2(greymattermask2(i),3)) = R(1,2);
    end

    disp('Preparing to write output template...');
    template = spm_vol([fullfile(rootdir,study,subjIDs{1},'results', resdir,['RSA_searchlight_' con_tag '.img']) ',1']);
    template.fname = fullfile(rootdir,study,[out_name '.img']);
    spm_write_vol(template,out_map);
    disp(['File written as ' template.fname '.']);
    disp('Done.')


end %end searchlight_all