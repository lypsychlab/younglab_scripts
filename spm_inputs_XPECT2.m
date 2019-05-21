function spm_inputs_XPECT2(root_dir,study,subjs,runs,taskname)
% spm_inputs_itemwise: creates new itemwise inputs variable from the
% regular spm_inputs variable.
% 
% Parameters:
% - root_dir: either "studies" or "englewood" to indicate dir structure
% - study: name of the study folder
% - subjs: cell string of subject names
% - runs: number of runs
% - taskname: name by which to identify behavioral .mats


	% root_dir='/younglab/studies/';
	% if strcmp(root_dir,'studies')
	% 	root_dir='/home/younglw';
	% else if strcmp(root_dir,'englewood')
	% 	root_dir='/home/younglw/server/englewood/mnt/englewood/data';
	% else
	% 	disp('Unrecognized root directory!')
	% 	return
	% end
	% end

	cd(fullfile(root_dir,study,'behavioural_new'));
	disp(pwd);
	for s=1:length(subjs)
		%try
			disp(['Subject ' subjs{s} 's spm_inputs_background'])
			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname '.background.' num2str(r) '.mat'];
					f=load(fname);
					num_items=length(f.items_run);
					clear spm_inputs_background
					spm_inputs_background(1).name = 'B'	
					spm_inputs_background(2).name = 'M'
					spm_inputs_background(1).ons=[]
					spm_inputs_background(1).dur=[]
					spm_inputs_background(2).ons=[]
					spm_inputs_background(2).dur=[]
					for it=1:num_items
						condstring = char(f.condnames(it))
						if condstring(1)=='B'							
							spm_inputs_background(1).ons = [spm_inputs_background(1).ons, f.spm_inputs(it).ons];
							spm_inputs_background(1).dur = [spm_inputs_background(1).dur; f.spm_inputs(it).dur]
						elseif condstring(1)=='M'
							spm_inputs_background(2).ons = [spm_inputs_background(2).ons, f.spm_inputs(it).ons];
							spm_inputs_background(2).dur = [spm_inputs_background(2).dur; f.spm_inputs(it).dur]

						end

					end
					save([subjs{s} '.' taskname '.background.' num2str(r) '.mat'],'spm_inputs_background','-append');
					clear f fname;
					disp(['Successfully processed run ' num2str(r)])

			end %end runs loop

			disp(['Subject ' subjs{s} 's spm_inputs_question'])
			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname '.question.' num2str(r) '.mat'];
					f=load(fname);
					clear spm_inputs_question
					spm_inputs_question(1).name = 'BB'	
					spm_inputs_question(2).name = 'BM'
					spm_inputs_question(3).name = 'MM'
					spm_inputs_question(4).name = 'MB'			
					spm_inputs_question(1).ons=[]
					spm_inputs_question(2).ons=[]
					spm_inputs_question(3).ons=[]
					spm_inputs_question(4).ons=[]
					spm_inputs_question(1).dur=[]
					spm_inputs_question(2).dur=[]
					spm_inputs_question(3).dur=[]
					spm_inputs_question(4).dur=[]

					for it=1:num_items
						condstring = char(f.condnames(it))
						if condstring(1:2)=='BB'				
							spm_inputs_question(1).ons = [spm_inputs_question(1).ons, f.spm_inputs(it).ons];
							spm_inputs_question(1).dur = [spm_inputs_question(1).dur; f.spm_inputs(it).dur]
						elseif condstring(1:2)=='BM'
							spm_inputs_question(2).ons = [spm_inputs_question(2).ons, f.spm_inputs(it).ons];
							spm_inputs_question(2).dur = [spm_inputs_question(2).dur; f.spm_inputs(it).dur]
						elseif condstring(1:2)=='MM'
							spm_inputs_question(3).ons = [spm_inputs_question(3).ons, f.spm_inputs(it).ons];
							spm_inputs_question(3).dur = [spm_inputs_question(3).dur; f.spm_inputs(it).dur]
						else
							spm_inputs_question(4).ons = [spm_inputs_question(4).ons, f.spm_inputs(it).ons];
							spm_inputs_question(4).dur = [spm_inputs_question(4).dur; f.spm_inputs(it).dur]
							

						end


					end
					save([subjs{s} '.' taskname '.question.' num2str(r) '.mat'],'spm_inputs_question','-append');
					clear f fname;
					disp(['Successfully processed run ' num2str(r)])
			end %end runs loop
		%catch
			%disp(['Error with ' subjs{s}])
			%continue
		%end %end try
	end %end subject loop

	for s=1:length(subjs)
		%try
			disp(['Subject ' subjs{s} 's contrast info'])
			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname '.background.' num2str(r) '.mat'];
					f=load(fname);

					%load contrasts for background section modelling
					con_info(1).name  = 'behavior vs mental';
					con_info(1).vals  = [1 -1];
					con_info(2).name  = 'mental vs behavior';
					con_info(2).vals  = [-1 1];
					
					save([subjs{s} '.' taskname '.background.' num2str(r) '.mat'],'con_info','-append');
					clear f fname;
			end %end runs loop

			disp(['Successfully processed background contrasts for subj ' num2str(s)])


			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname '.question.' num2str(r) '.mat'];
					f=load(fname);

					%load contrasts for question section modelling
					con_info(1).name  = 'behavior vs mental';
					con_info(1).vals  = [1 -1 -1 1];
					con_info(2).name  = 'mental vs behavior';
					con_info(2).vals  = [-1 1 1 -1];
					con_info(3).name  = 'b vs m background behavior';
					con_info(3).vals  = [1 -1 0 0];
					con_info(4).name  = 'm vs b background behavior';
					con_info(4).vals  = [-1 1 0 0];
					con_info(5).name  = 'b vs m background mental';
					con_info(5).vals  = [0 0 -1 1];
					con_info(6).name  = 'm vs b background mental';
					con_info(6).vals  = [0 0 1 -1];


					
					save([subjs{s} '.' taskname '.question.' num2str(r) '.mat'],'con_info','-append');
					clear f fname;
			end %end runs loop

			disp(['Successfully processed question contrasts for subj ' num2str(s)])


			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname '.outcome.' num2str(r) '.mat'];
					f=load(fname);

					%load contrasts for outcome modelling
					con_info(1).name  = 'expected vs unexpected';
					con_info(1).vals  = [1 1 1 1 -1 -1 -1 -1];
					con_info(2).name  = 'unexpected vs expected';
					con_info(2).vals  = [-1 -1 -1 -1 1 1 1 1];
					con_info(3).name  = 'behavior vs mental';
					con_info(3).vals  = [1 -1 -1 1 1 -1 -1 1];
					con_info(4).name  = 'mental vs behavior';
					con_info(4).vals  = [-1 1 1 -1 -1 1 1 -1];
					con_info(5).name  = 'exp behavior vs unexp behavior';
					con_info(5).vals  = [1 0 0 1 -1 0 0 -1];
					con_info(6).name  = 'unexp behavior vs exp behavior';
					con_info(6).vals  = [-1 0 0 -1 1 0 0 1];
					con_info(7).name  = 'exp mental vs unexp mental';
					con_info(7).vals  = [0 1 1 0 0 -1 -1 0];
					con_info(8).name  = 'unexp mental vs exp mental';
					con_info(8).vals  = [0 -1 -1 0 0 1 1 0];
					con_info(9).name  = 'exp behavior vs exp mental';
					con_info(9).vals  = [1 -1 -1 1 0 0 0 0];
					con_info(10).name  = 'exp mental vs exp behavior';
					con_info(10).vals  = [-1 1 1 -1 0 0 0 0];
					con_info(11).name  = 'unexp behavior vs unexp mental';
					con_info(11).vals  = [0 0 0 0 1 -1 -1 1];
					con_info(12).name  = 'unexp mental vs unexp behavior';
					con_info(12).vals  = [0 0 0 0 -1 1 1 -1];

					save([subjs{s} '.' taskname '.outcome.' num2str(r) '.mat'],'con_info','-append');
					clear f fname;
			end %end runs loop

			disp(['Successfully processed outcome contrasts for subj ' num2str(s)])



	end %end subject loop





end %end function