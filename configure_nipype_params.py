import json, sys, os, shutil, fnmatch, mat4py

def configure_nipype_params(*argu):
	"""
	A little interactive function to fill in *_params_*.json file

	Arguments:
	[1]: full path to new parameter file, MINUS the .json extension
	[2]: v (to turn on verbose behavior)
	"""

	json_name = argu[1]
	with open('/Users/wass/GitHub/younglab_scripts/yl_nipype_params_MASTER.json','r') as jsonfile:
	# with open('/home/younglw/lab/scripts/yl_nipype_params_MASTER.json','r') as jsonfile:
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
		params["experiment_details"]["covariates"][t] = {}

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
			for k in matfile["covariates"].keys():
					params["experiment_details"]["design"][t][s]['covariates'][k] = [] 
			# start pulling data:
			for m in range(len(matname)): # for each run:
				matfile = mat4py.loadmat(matname[m])
				params["experiment_details"]["spm_inputs"][t][s]["ons"].append([]) # run-specific list
				params["experiment_details"]["spm_inputs"][t][s]["dur"].append([]) # run-specific list
				params["experiment_details"]["design"][t][s]['condition'].append([])
				params["experiment_details"]["design"][t][s]['items'].append([])
				# Pull spm_inputs: onsets, durations, condition names
				for k in matfile['spm_inputs'].keys():
					params["experiment_details"]["spm_inputs"][t][s]["ons"][m].append(matfile["spm_inputs"][k]["ons"].sort())
					# ex. params["experiment_details"]["spm_inputs"][t][s]['ons'] = [[[1,5],[3,7]],...]
					params["experiment_details"]["spm_inputs"][t][s]["dur"][m].append(matfile["spm_inputs"]["dur"])
					# ex. params["experiment_details"]["spm_inputs"][t][s]['dur'] = [[[2,2],[2,2]],...]
					params["experiment_details"]["design"][t][s]["condition"][m].append(k)
					# ex. params["experiment_details"]["design"][t][s]['condition'] = [['condname1','condname2'],...]
					# each of these fields contains (# of runs) lists, each list being (# of conditions) long
					# in the case of ons/dur, each list contains (# of conditions) lists, which are each (# of trials) long
					# in the case of condition, each list contains (# of conditions) strings, which are condition names for that run
				# Pull items
				try:
					params["experiment_details"]["design"][t][s]["items"].append(matfile["items_run"])
				except KeyError: # no 'items' variable in matfile
					params["experiment_details"]["design"][t][s]["items"].append(matfile["items"])
				# ex. params["experiment_details"]["design"][t][s]['items'] = [[10,1,7,4],...]					
				# Pull covariates
				for k in matfile["covariates"].keys():
					params["experiment_details"]["design"][t][s]['covariates'].append(matfile["covariates"][k])
					# assumes that "covariates" is a structure with fields corresponding to covariate variables (e.g., key, RT)
					# and values corresponding to covariate values
					# see: rework_behavioral.m	
					# ex. params["experiment_details"]["design"][t][s]['covariates'] = {'key':[[4,4],[2,4]],'RT':[[0.342,0.674],[0.983,0.356]]}
				if argu[2]=='v':
					print("Finished with %s" % m)
				except IndexError: pass

	print("Done!\nWriting to %s.json." % json_name)

	with open(json_name + '.json','w') as jsonfile:
		json.dump(params,jsonfile)

if __name__ == "__main__":
	configure_nipype_params(sys.argv)

