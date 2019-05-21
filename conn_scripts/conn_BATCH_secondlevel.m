function conn_BATCH_secondlevel(study,connmat,between_subjects,between_conditions,between_sources,nametag,run_batch)
%========================================================================================
%conn_BATCH_secondlevel loads second-level analysis information into the batch structure
%
%Form: conn_BATCH_secondlevel(study,connmat,between_subjects,between_conditions,between_sources,nametag,run_batch)
%
%Parameters:
%
%connmat: file output from conn_BATCH_firstlevel (.mat)
%between_subjects: specifies between-subjects second-level analyses. structure with fields .effect_names and .contrast...
%where .effect_names is a subset of second_levels.effect_names and .contrast is a contrast vector ranging over .effect_names
%between_conditions: specifies between-condition results; structure similar to between_subjects
%takes its values from spmfiles
%between_sources: similar to between_conditions. Reference manual p. 68 for specifying derivatives/components
%nametag: unique identifier string for this analysis. 
%run_batch: 0 or 1. 0 = do not call conn_batch() (we want to save the analysis setup without running it). 
%1 = run conn_batch()
%
%sample call:
%conn_BATCH_secondlevel('RACA_02_03_roi','02vs03',0,0,'2v3',1)
%(where 02vs03.mat is a file containing variables 'effect_names' and 'contrast')
%
%The "between" parameters should be .mat structures saved in /younglab/studies/study/conn/. 
%If you do not want to specify an analysis for one of these parameters, enter 0 as a placeholder.
%By default, CONN will perform a separate second-level analysis for each condition defined
%in BATCH.Setup.conditions.
%
%To graphically explore your second-level analyses instead of running them as a batch,
%open CONN and load your .mat project created with conn_BATCH_firstlevel.
%
%=======================================================================================


	
	EXPERIMENT_ROOT_DIR='/younglab/studies';
	cd(fullfile(EXPERIMENT_ROOT_DIR,study,'conn/'))
	try
	    conn_file=load([connmat '.mat'])
	catch
	    sprintf('No .mat file named %s in directory %s',connmat,pwd)
	    return
	end	

	BATCH=conn_file.BATCH;

	if between_subjects==0
		;
	else
		between_subjects=load(between_subjects,'-mat');
	end

	if between_conditions==0
		;
	else
		between_conditions=load(between_conditions,'-mat');
	end

	if between_sources==0
		;
	else
		between_sources=load(between_sources,'-mat');
	end


	firstlevel=conn_file.firstlevel;
	for a=1:length(firstlevel) %note that this means ALL of your first-level analyses will undergo the same second-level analysis steps
		%so choose wisely! only input first-level analyses you mean to use at the second level
		BATCH.Results.analysis_number=a;
		if between_subjects & between_conditions & between_sources == 0
			disp(['No second-level analyses specified for analysis #' num2str(a)])
			disp('Performing CONN default second-level analyses.')
		end
		if between_subjects ~= 0
			%define between subjects analysis
			BATCH.Results.second_levels.effect_names=between_subjects.effect_names;
			BATCH.Results.second_levels.contrast=between_subjects.contrast;
		end
		if between_conditions~=0
			BATCH.Results.between_conditions.effect_names=between_conditions.effect_names;
			BATCH.Results.between_conditions.contrast=between_conditions.contrast;
		end
		if between_sources~=0
			BATCH.Results.between_sources.effect_names=between_sources.effect_names;
			BATCH.Results.between_sources.contrast=between_sources.contrast;
		end
		disp(['Performing specified second-level analyses for analysis #' num2str(a)])
	end
	BATCH.Results.done=1;

	disp('Second-level analysis setup complete.')

	analysis_name=[connmat '_' nametag '.mat'];
	sprintf('Saving %s in directory %s',analysis_name,pwd)
	save(analysis_name,'BATCH');

	if run_batch
	    conn_batch(BATCH);
		disp('Functional connectivity analysis successful!')	    
	else if run_batch == 0
	    ;
	else
	    disp('run_batch parameter can only take values 0 or 1.')
	end
	end


	

end %end conn_BATCH_secondlevel