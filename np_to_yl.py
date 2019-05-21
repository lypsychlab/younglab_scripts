import os, re, fnmatch, shutil

def np_to_yl(study,sub_nums,subj_tag,task,max_run,wf_name):

	def make_new_dir(in_dir):
		if not os.path.exists(in_dir):
			os.mkdir(in_dir)

	rootdir = '/home/younglw/lab'
	# for each subject:
	for sub in sub_nums:
		subj_id = subj_tag + '_' + str(sub).zfill(2)
		# create 'bold'/3danat folder if it doesn't exist
		anat_dir = os.path.join(rootdir,study,subj_id,'3danat')
		make_new_dir(anat_dir)
		bold_dir = os.path.join(rootdir,study,subj_id,'bold')
		make_new_dir(bold_dir)
		for run_num in range(1,max_run+1):
			make_new_dir(os.path.join(rootdir,study,subj_id,'bold',str(run_num).zfill(3)))
		# go to the wf_name/_subject_id_SUBJID_task_name_TASK/dicom/converted_dicom/ folder
		subj_folder = '_subject_id_' + subj_id + '_task_name_' + task
		os.chdir(os.path.join(rootdir,study,wf_name,subj_folder,'dicom','converted_dicom'))
		# get run number (e.g. 001) via regex group matching
		reg_exp = 'f' + subj_id + '-0([0-9]{3})'
		# copy all f* files depending on their run number into the bold folder
		for fname in [f for f in os.listdir('.') if fnmatch.fnmatch(f,'f*.nii')]:
			# grab run number from the filename
			run_string = re.match(reg_exp,fname).group(1)
			f_dest = os.path.join(bold_dir,run_string,fname)
			print(fname)
			shutil.copyfile(fname,f_dest)
		# copy s* file corresponding to run 10 into the 3danat folder
		anat_file = 's' + subj_id + '-0010-00001-000176-01.nii' # structural image string here
		anat_dest = os.path.join(anat_dir,anat_file)
		try:
			shutil.copyfile(anat_file,anat_dest)
		except:
			print('No anatomical file found for {}'.format(subj_id))
