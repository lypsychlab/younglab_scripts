rootdir='/home/younglw/VERBS';
for sub=[3:47]
	try
		disp([sprintf('%02d',sub)])
		cd(fullfile(rootdir,['SAX_DIS_' sprintf('%02d',sub)],'results'));
		rmdir('model_alek*','s');
	catch
		disp(['Removed nothing for ' sprintf('%02d',sub)]);
		continue
	end
end