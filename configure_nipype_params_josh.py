import json, sys, os, shutil, fnmatch, mat4py

def configure_nipype_params(*argu):
	"""
	A little interactive function to fill in *_params_*.json file

	Arguments:
	[1]: full path to new parameter file, MINUS the .json extension
	[2]: v (to turn on verbose behavior)
	"""
	if type(argu) is tuple: 
		print('\nNote: script being run via test script.')
		argu=argu[0];
	json_name = argu[1]
	# with open('/Users/wass/GitHub/younglab_scripts/nipype/yl_nipype_params_MASTER.json','r') as jsonfile:
	with open('/home/younglw/lab/scripts/nipype/yl_nipype_params_MASTER.json','r') as jsonfile:
		params=json.load(jsonfile)

	rootdir = input('Enter root directory: ')
	studyname = input('Enter study name: ')
	wfname = input('Enter workflow name: ')
	subjtag = input('Enter subject tag (e.g. SAX_DIS): ')
	sub_nums=[str(x) for x in input('Enter subject numbers (separate with spaces): ').split(' ')]
	tsks = [str(x) for x in input('Enter task names (separate with spaces): ').split(' ')]

	params["config"]["logging"]["log_directory"] = os.path.join(rootdir,studyname,wfname,'logs')
	params["directories"]["study"] = studyname
	params["directories"]["workflow_name"] = wfname
	params["directories"]["root"] = rootdir
	params["experiment_details"]["subject_tag"] = subjtag
	params["experiment_details"]["subject_nums"] = sub_nums
	params["experiment_details"]["subject_ids"] = [subjtag + '_' + x.zfill(2) for x in sub_nums]
	params["experiment_details"]["task_names"] = tsks


	print("Pulling information from .mat files now...")
	os.chdir(os.path.join(rootdir,studyname,'behavioral'))
	for t in tsks:
		params["experiment_details"]["ips"][t] = 0
		params["experiment_details"]["contrast_info"][t] = {}
		params["experiment_details"]["spm_inputs"][t] = {}
		params["experiment_details"]["design"][t] = {}

		for s in params["experiment_details"]["subject_ids"]:
			matname = [f for f in os.listdir('.') if fnmatch.fnmatch(f,s+'*'+t+'*.mat')]
			if not matname: break # skip to next subject if they don't have this task
			matfile = mat4py.loadmat(matname[0]) # pull just first one to do some processing
			# Pull ips
			params["experiment_details"]["ips"][t] = matfile["ips"]
			# Pull contrast info
			contrast_dict = matfile["con_info"]
			for i in range(len(contrast_dict["name"])):
				params["experiment_details"]["contrast_info"][t][str(i)] = {}
				params["experiment_details"]["contrast_info"][t][str(i)]["name"] = contrast_dict["name"][i]
				params["experiment_details"]["contrast_info"][t][str(i)]["con_vals"] = contrast_dict["vals"][i]
				# params["experiment_details"]["contrast_info"][t][str(i)]["cond_names"] = matfile["cond_names"]
			# initialize empty lists/dicts:
			params["experiment_details"]["spm_inputs"][t][s] = {}
			params["experiment_details"]["spm_inputs"][t][s]["ons"] = []
			params["experiment_details"]["spm_inputs"][t][s]["dur"] = []
			params["experiment_details"]["design"][t][s] = {}
			params["experiment_details"]["design"][t][s]["items"] = []
			params["experiment_details"]["design"][t][s]['covariates'] = {}
			params["experiment_details"]["design"][t][s]['condition'] = [] 
			if 'covariates' in matfile.keys():
				for k in matfile["covariates"]:
					params["experiment_details"]["design"][t][s]['covariates'][k] = [] 
			# start pulling data:
			for m in range(len(matname)): # for each run:
				matname[m] = "%s.%s.%d.mat" % (s,t,m+1) # e.g. YOU_HOWWHY.HOWWHY.1.mat
				matfile = mat4py.loadmat(matname[m])
				print(matname[m])

				if 'spm_inputs' in matfile.keys():
					print(matfile.keys())
					params["experiment_details"]["spm_inputs"][t][s]["ons"].append([]) # run-specific list
					params["experiment_details"]["spm_inputs"][t][s]["dur"].append([]) # run-specific list
					params["experiment_details"]["design"][t][s]['condition'].append([])

					# Pull spm_inputs: onsets, durations, condition names
					params["experiment_details"]["design"][t][s]["condition"][m] = matfile["spm_inputs"]["name"]
					# ex. params["experiment_details"]["design"][t][s]['condition'] = [['condname1','condname2'],...]
					for k in range(len(matfile['spm_inputs']["name"])):
						# make sure each condition/run-specific onset list is actually a list, not a number
						if type(matfile["spm_inputs"]["ons"][k]) is not list:
							matfile["spm_inputs"]["ons"][k] = [matfile["spm_inputs"]["ons"][k]]
						if type(matfile["spm_inputs"]["dur"][k]) is not list:
							matfile["spm_inputs"]["dur"][k] = [matfile["spm_inputs"]["dur"][k]]
						params["experiment_details"]["spm_inputs"][t][s]["ons"][m].append(sorted(matfile["spm_inputs"]["ons"][k]))
						# ex. params["experiment_details"]["spm_inputs"][t][s]['ons'] = [[[1,5],[3,7]],...]
						params["experiment_details"]["spm_inputs"][t][s]["dur"][m].append(matfile["spm_inputs"]["dur"][k])
						# ex. params["experiment_details"]["spm_inputs"][t][s]['dur'] = [[[2,2],[2,2]],...]
						# ex. params["experiment_details"]["design"][t][s]['condition'] = [['condname1','condname2'],...]
						# each of these fields contains (# of runs) lists, each list being (# of conditions) long
						# in the case of ons/dur, each list contains (# of conditions) lists, which are each (# of trials) long
						# in the case of condition, each list contains (# of conditions) strings, which are condition names for that run
					# Pull items
					params["experiment_details"]["design"][t][s]["items"].append(matfile["items_run"])
					# ex. params["experiment_details"]["design"][t][s]['items'] = [[10,1,7,4],...]					
					# Pull covariates
					if 'covariates' in matfile.keys():
						for k in matfile["covariates"]:
							params["experiment_details"]["design"][t][s]['covariates'][k].append(matfile["covariates"][k])
						# assumes that "covariates" is a structure with fields corresponding to covariate variables (e.g., key, RT)
						# and values corresponding to covariate values
						# see: rework_behavioral.m	
						# ex. params["experiment_details"]["design"][t][s]['covariates'] = {'key':[[4,4],[2,4]],'RT':[[0.342,0.674],[0.983,0.356]]}
					try:
						if argu[2]=='v': # verbose behavior is on
							print("Finished with %s" % matname[m])
					except IndexError: pass

				else:
					params["experiment_details"]["spm_inputs"][t][s]["ons"].append([]) # run-specific list
					params["experiment_details"]["spm_inputs"][t][s]["dur"].append([]) # run-specific list
					params["experiment_details"]["design"][t][s]['condition'].append([])

	print("Done!\nWriting to %s.json." % json_name)
	
	with open(json_name + '.json','w') as jsonfile:
		json.dump(params,jsonfile)

if __name__ == "__main__":
	configure_nipype_params(sys.argv)


