S1=cell(47,1);
S2=cell(47,1);

S3=cell(47,1);

S4=cell(47,1);

for s=3:47
	try
		cd(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS',sprintf('SAX_DIS_%02d',s),'results/DIS_results_itemwise_normed'));
		load('spherebetas_path_LIFG_fourconds.mat')
		S1{s} = spherebetas;
		clear spherebetas;
		load('spherebetas_inc_RTPJ_fourconds.mat')
		S2{s} = spherebetas;
		clear spherebetas;
		load('spherebetas_psyc_PC_fourconds.mat')
		S3{s} = spherebetas;
		clear spherebetas;
		load('spherebetas_phys_PC_fourconds.mat')
		S4{s} = spherebetas;
		clear spherebetas;

	catch
		continue
	end 
end 
save(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS','all_spherebetas_path_LIFG_fourconds.mat'),'S1');
save(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS','all_spherebetas_inc_RTPJ_fourconds.mat'),'S2');
save(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS','all_spherebetas_psyc_PC_fourconds.mat'),'S3');
save(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS','all_spherebetas_phys_PC_fourconds.mat'),'S4');