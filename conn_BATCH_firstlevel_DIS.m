function conn_BATCH_firstlevel_DIS(study,connmat,firstlevel,run_batch)
%=====================================================================
%conn_BATCH_firstlevel loads first-level analysis information into the
%batch structure used by CONN.
%Always run conn_BATCH_firstlevel after running conn_BATCH_setup.
%
%Form: conn_BATCH_firstlevel(study,connmat,firstlevel,run_batch)
%
%Parameters:
%study: name of the study (string). Needs to correspond to directory in
%/younglab/studies/
%connmat: file output from conn_BATCH_setup (.mat)
%firstlevel: information on which analyses to run. Acceptable values are:
%'corr' (bivariate correlation), 'semicorr' (semipartial correlation),...
%'regress'(bivariate regression),'multiregress'(multivariate regression).
%run_batch: 0 or 1. 0 = do not call conn_batch() (we want to set up second-level analyses first). 
%1 = run conn_batch()
%
%sample call:
%conn_BATCH_firstlevel('RACA','RACA_YOU_RACA_02_roi',{'corr semicorr'},1)
%=====================================================================

EXPERIMENT_ROOT_DIR='/younglab/studies';
cd(fullfile(EXPERIMENT_ROOT_DIR,study,'conn/'))
try
    conn_file=load([connmat '.mat']);
catch
    sprintf('No .mat file named %s in directory %s',connmat,pwd)
    return
end


if isempty(firstlevel) && ~ismember('voxel',an) %if no firstlevel analyses specified and we don't want voxel-to-voxel
        disp('First-level analysis: Bivariate Correlation')
        firstlevel_analyses(1); %run the default (bivariate corr)
    else if isempty(firstlevel) && ismember('voxel',an) %no analyses specified and we DO want voxel-to-voxel
        disp('First-level analysis: Voxel to Voxel')
        firstlevel_analyses(0);
    else
        for meas=1:length(firstlevel)
            conn_file.BATCH.Analysis.analysis_number=meas;
            switch firstlevel{meas}
                case 'corr'
                    disp('First-level analysis: Bivariate Correlation')
                    firstlevel_analyses(1);
                case 'semicorr'
                    disp('First-level analysis: Semipartial Correlation')
                    firstlevel_analyses(2);
                case 'regress'
                    disp('First-level analysis: Bivariate Regression')
                    firstlevel_analyses(3);
                case 'multiregress'
                    disp('First-level analysis: Multivariate Regression')
                    firstlevel_analyses(4);
                case 'voxel'
                    disp('First-level analysis: Voxel to Voxel')
                    firstlevel_analyses(0);
                otherwise
                    warning('Unrecognized parameter for first-level analysis measure.')
                    return;
            end
        end

        end
end

conn_file.BATCH.Analysis.done=1;
disp('First-level analysis complete.')
BATCH=conn_file.BATCH;
sprintf('Saving %s in directory %s',connmat,pwd)
savename=[connmat '.mat'];
save(savename,'BATCH','-append');
save(savename,'firstlevel','-append');
save(savename,'study','-append');


if run_batch
    conn_batch(BATCH);
    disp('Functional connectivity analysis successful!')
else if run_batch == 0
    ;
else
    disp('run_batch parameter can only take values 0 or 1.')
    end
end

clear;

    function firstlevel_analyses(m)
    	if m==0 %we know this is a voxel-to-voxel
    		conn_file.BATCH.Analysis.analysis_number=0; %just going to run all the default voxel-to-voxel analyses for now
            disp('Voxel to voxel analysis')
        else
            conn_file.BATCH.Analysis.measure=m;
    		%note that this will run as many analyses as it can. 
    		%e.g. if firstlevel=={'corr' 'regress'} and analyze={'roi' 'seed'},
    		%it will run every combination of analysis type and analysis measure (4 analyses)
    		if ismember('roi',conn_file.an) && ismember('seed',conn_file.an)
    			conn_file.BATCH.Analysis.type=3;        
                disp('ROI-ROI and seed-voxel analysis')
    		else if ismember('roi',conn_file.an)==1
    			conn_file.BATCH.Analysis.type=1;
                disp('ROI-ROI analysis')
    		else if ismember('seed',conn_file.an)
    			conn_file.BATCH.Analysis.type=2;
                disp('Seed-voxel analysis')
    		else
    			warning('Incorrect input for analyze parameter. Must be: roi, seed, and/or voxel');
    			return;
    		end
    		
            end
            end %end firstlevel_analyses
        end
    end

end
