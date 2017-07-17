import os, json, fnmatch
from collections import OrderedDict

def convert_TR(paramfile):
	'''convert onsets that are in seconds, within a params file, to TRs

	Parameters:
	- paramfile: full path to params file, minus .json extension'''
	with open(paramfile+'.json','r') as jsonfile:
		params=json.load(jsonfile,object_pairs_hook=OrderedDict)
	TR = params['params']['slicetime']['TR']
	for tname in params['experiment_details']['spm_inputs'].keys():
		for sname in params['experiment_details']['spm_inputs'][tname].keys():
			for rnum in range(len(params['experiment_details']['spm_inputs'][tname][sname]['ons'])):
				for cnum in range(len(params['experiment_details']['spm_inputs'][tname][sname]['ons'][rnum])):
					for tnum in range(len(params['experiment_details']['spm_inputs'][tname][sname]['ons'][rnum][cnum])):
						# params['experiment_details']['spm_inputs'][tname][sname]['ons'][rnum][cnum][tnum]=int(round(params['experiment_details']['spm_inputs'][tname][sname]['ons'][rnum][cnum][tnum]))
						params['experiment_details']['spm_inputs'][tname][sname]['ons'][rnum][cnum][tnum]=int(round(params['experiment_details']['spm_inputs'][tname][sname]['ons'][rnum][cnum][tnum]/TR))
	with open(paramfile+'.json','w') as jsonfile:
		json.dump(params,jsonfile)

def arrange_niftis(study,wf_name,taskname,subj_tag,sub_nums):
	'''group vNav files into their own subfolder

	Parameters:
	- study: study name (str)
	- wf_name: workflow directory name (str)
	- taskname: task name (str)
	- subj_tag: subject tag, e.g. 'YOU_FIRSTTHIRD' (str)
	- sub_nums: subject numbers (list of ints)
	'''
	rootdir = '/home/younglw/lab'
	for i in sub_nums:
		subj_string = '_subject_id_' + subj_tag + '_' + str(i).zfill(2) + '_task_name_' + taskname
		srch_string = 'f' + subj_tag + '_' + str(i).zfill(2) + '-0006-*.nii'
		os.chdir(os.path.join(rootdir,study,wf_name,subj_string,'dicom','converted_dicom'))
		os.mkdir('0006')
		movefiles = [f for f in os.listdir('.') if fnmatch.fnmatch(f,srch_string)]
		for f in movefiles:
			os.rename(f,os.path.join('./0006',f))
		print('Done with subject '+str(i))

