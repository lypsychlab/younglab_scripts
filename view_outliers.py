import os, csv

def view_outliers(study,nums,subj_tag,resdir):
	root_dir = '/home/younglw/lab/%s' % study
	os.chdir(root_dir)
	outliers = []
	for n in nums:
		subj_dir = os.path.join(root_dir,subj_tag+'_'+str(n).zfill(2),'results',resdir)
		os.chdir(subj_dir)
		with open('SPM_outliers.txt','r') as f:
			rdr = csv.reader(f,delimiter='\t')
			line1 = next(rdr) # skip first line
			line2 = next(rdr)
			line2 = str.split(line2[0])
			print(line2[0])

study = 'HOWWHY'
nums = range(1,15)
subj_tag = 'YOU_HOWWHY'
resdir = 'HOWWHY_results_normed'
view_outliers(study,nums,subj_tag,resdir)