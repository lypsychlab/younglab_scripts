function permute_test_roi(rootdir,study,resdir,subnums,bmatrix,iter,roi,findtag)
% performs permutation test for ROI RSA results
% 
% Parameters:
% - rootdir: root directory
% - study: study directory
% - resdir: results directory 
% - subnums: subject numbers (array)
% - bmatrix: name of regressor to be scrambled
% - iter: number of iterations
% - roi: name of masked ROI to use
% - findtag: identifier for categorical RSA results (i.e., the H0 model)
% 

	cd(fullfile(rootdir,study,'results'));
	load(['all_regressinfo_' findtag '.mat'],'ALL');
	%you must have previously run the categorical-only ROI RSA 
	ALL_cat=ALL;
	clear ALL;

	H=[];
	P=[];
	RDIFF2=[];

    for it=1:iter
        
        disp(['ITERATION ' num2str(it)]);
		cd(fullfile(rootdir,study,'behavioural'));
		load(bmatrix);
		bmat=behav_matrix;
		behav_matrix=sim2tril(bmat); %stretch into vector
		newmat = behav_matrix(randperm(length(behav_matrix))); %scramble
		behav_matrix=tril2sim(newmat); %make it a similarity matrix again
		behav_matrix=tril(behav_matrix); %get the lower triangle
		bname=['behav_matrix_PERM_' num2str(it) '.mat'];
		save(fullfile(rootdir,study,'behavioural',bname),'behav_matrix');
		% NOTE: this behavior saves all the scrambled matrices, for recording purposes
		% you can delete the matrix at the end of each iteration to avoid this  

        for sub=subnums
            try
		        searchlight_all_regress_roi_pleiades(rootdir,...
		      study,'SAX_DIS',resdir,sub,1:48,3,...
		      {'phys' 'psyc' 'inc' 'path' 'physVpsyc' 'incVpath' ['PERM_' num2str(it)]},roi,'_PERM');
	    
	        catch
	            disp(['Could not process subject ' num2str(sub)]);
	            continue
            end
        end %end subject loop

        load_corrs(rootdir,study,resdir,[roi '_PERM'],0); %aggregate the results across subjects
        cd(fullfile(rootdir,study,'results'));
        load(['all_regressinfo_' roi '_PERM.mat'],'ALL'); %load up the aggregated results
        ALL_perm=ALL; clear ALL;


        rdiff2=[];
        for i=2:length(ALL_cat) %first one is blank
            if ALL_cat(i).Stats(3)<0.05 %if the category-only model is itself significant
            rdiff2=[rdiff2; ALL_perm(i).Stats(1) - ALL_cat(i).Stats(1)]; 
            %get the R2 improvement from adding the junk regressor
            end
        end
        [h,p]=ttest(rdiff2); %test against zero
        H=[H;h]; 
        P=[P;p];
        RDIFF2=[RDIFF2 rdiff2];
    end %end iterations loop
    save(['permute_test_' roi '_' bmatrix '.mat'],'H','P','RDIFF2');

end %end function