function process_dcmHeaders(pth)

	reject = {'MoCo','AAScout','RMS'};
	% load the dcmHeaders.mat file
	fname=fullfile(pth,'dcmHeaders.mat');
	try
		load(fname);
		% iterate through the fields of h
		% if it's one we want to keep, spit it out as a separate .mat file
		oldfldnames = fieldnames(h);
		for i=1:length(oldfldnames)
			rejectflag=0;
			for j=1:length(reject)
				if ~isempty(strfind(oldfldnames{i},reject{j}))
					rejectflag=1;
				end
			end
			if rejectflag==0
				vname = genvarname(oldfldnames{i});
				val=getfield(h,oldfldnames{i});
				eval([vname '= val;']);

				outvars = eval(['fieldnames(' vname ');']);
				for k = 1:length(outvars)
					vname2=genvarname(outvars{k});
					eval([vname2 '=' vname '.' vname2 ';']);
					if k==1
						save(fullfile(pth,[vname '.mat']),vname2);
					else
						save(fullfile(pth,[vname '.mat']),vname2,'-append');
					end
					clear(vname2);
				end
				clear(vname);
				clear vname2 vname outvars val;
			end
		end
	catch
		exit
	end

	exit % quit MATLAB
end % end function