% rootdir='/home/younglw/VERBS/behavioural';
% cd(rootdir);
% for sub=[3:47]
% 	try
% 		for runnum=1:6
% 			try
% 				disp(num2str(runnum));
% 				fname=['SAX_DIS_' sprintf('%02d',sub) '.DIS_verbs.' num2str(runnum) '.mat'];
% 				load(fname,'spm_inputs');
% 				spm_inputs=0;
% 				save(fname,'spm_inputs','-append');
% 			catch
% 				continue
% 			end
% 		end

% 	catch
% 		disp(['Removed nothing for ' sprintf('%02d',sub)]);
% 		continue
% 	end
% end

rootdir='/home/younglw/VERBS/behavioural';
cd(rootdir);
sub=37;
for runnum=1:6
	fname=['SAX_DIS_' sprintf('%02d',sub) '.DIS.' num2str(runnum) '.mat'];
	copyfile(fname,['SAX_DIS_' sprintf('%02d',sub) '.DIS_verbs.' num2str(runnum) '.mat']);
end
spm_inputs=0;
for runnum=1:6
	fname=['SAX_DIS_' sprintf('%02d',sub) '.DIS_verbs.' num2str(runnum) '.mat'];
	save(fname,'spm_inputs','-append');
end

