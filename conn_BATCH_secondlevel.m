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
	    cfile=load([connmat '.mat']);
	catch
	    sprintf('No .mat file named %s in directory %s',connmat,pwd)
	    return
	end	

	BATCH=cfile.BATCH;
    vars={'effect_names','contrast'};
    
	if between_subjects==0
		between_subjects={};
	else
		between_subjects=load([between_subjects '.mat'],vars{:})
	end

	if between_conditions==0
		between_conditions={};
	else
		between_conditions=load([between_conditions '.mat'],vars{:});
	end

	if between_sources==0
		between_sources={};
	else
		between_sources=load([between_sources '.mat'],vars{:});
	end


	firstlevel=cfile.firstlevel;
	for a=1:length(firstlevel) %note that this means ALL of your first-level analyses will undergo the same second-level analysis steps
		%so choose wisely! only input first-level analyses you mean to use at the second level
		BATCH.Results.analysis_number=a;
		if isempty(between_subjects)&&isempty(between_conditions)&&isempty(between_sources)
			disp(['No second-level analyses specified for analysis #' num2str(a)])
            return
		end
		if ~isempty(between_subjects)
			BATCH.Results.between_subjects=between_subjects;
            disp('Between-subjects analysis')
		end
		if ~isempty(between_conditions)
			BATCH.Results.between_conditions=between_conditions;
            disp('Between-conditions analysis')
		end
		if ~isempty(between_sources)
			BATCH.Results.between_sources=between_sources;
            disp('Between-sources analysis')
		end
		disp(['Analysis #' num2str(a)])
	end
	BATCH.Results.done=1;

	disp('Second-level analysis setup complete.')

	analysis_name=[connmat '_' nametag '.mat'];
	sprintf('Saving %s in directory %s',analysis_name,pwd)
	save(analysis_name,'BATCH');

	if run_batch
	    conn_batch(BATCH);
% 		disp('Functional connectivity analysis successful!')	    
	else if run_batch == 0
	    ;
	else
	    disp('run_batch parameter can only take values 0 or 1.')
	end
	end


	

end %end conn_BATCH_secondlevel