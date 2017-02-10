function DIS_combine_images(imtags,outtag)
	rootdir = '/home/younglw/lab/server/englewood/mnt/englewood/data';
	study = 'PSYCH-PHYS';
	load(fullfile(rootdir,study,'RSA_parameters.mat'));

	% elaborate image tags into filenames
	images = {};
	imcalc_string = 'i1';
	for(im = 1:length(imtags))
		images{end+1} = ['RSA_searchlight_regress_' imtags{im} '.img'];
		if(im > 1)
			imcalc_string = [imcalc_string sprintf('+i%d',im)];
		end
	end
	% imcalc_string = [imcalc_string ';']
	imcalc_string
	Vo = ['RSA_searchlight_regress_' outtag '.img'];
	Vi = char(images);

	% do imcalc for each set of images
	for(s=sub_nums)
		cd(fullfile(rootdir,study,sprintf('SAX_DIS_%02d',s),'results','DIS_results_itemwise_normed'));
		Vi = spm_vol(Vi);
		Q = spm_imcalc(Vi,Vo,imcalc_string);
	end

end