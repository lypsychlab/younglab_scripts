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
			matfile = mat4py.loadmat(matname[0]) # pull just one to do the bulk of processing
			# Pull ips
			params["experiment_details"]["ips"][t] = matfile["ips"]
			# Pull contrast info
			contrast_dict = matfile["con_info"]
			for i in range(len(contrast_dict["name"])):
				params["experiment_details"]["contrast_info"][t][str(i)] = {}
				params["experiment_details"]["contrast_info"][t][str(i)]["name"] = contrast_dict["name"][i]
				params["experiment_details"]["contrast_info"][t][str(i)]["con_vals"] = contrast_dict["vals"][i]
				# params["experiment_details"]["contrast_info"][t][str(i)]["cond_names"] = matfile["cond_names"]
			params["experiment_details"]["spm_inputs"][t][s] = {}
			params["experiment_details"]["spm_inputs"][t][s]["ons"] = []
			params["experiment_details"]["spm_inputs"][t][s]["dur"] = []
			params["experiment_details"]["design"][t][s] = {}
			params["experiment_details"]["design"][t][s]["items"] = []
			params["experiment_details"]["covariates"][t][s] = {}
			for k in matfile["conditions"].keys():
					params["experiment_details"]["design"][t][s][k] = [] # initialize lists
			for k in matfile["covariates"].keys():
					params["experiment_details"]["covariates"][t][s][k] = [] # initialize lists
			for m in matname:
				matfile = mat4py.loadmat(m)
				# Pull spm_inputs
				params["experiment_details"]["spm_inputs"][t][s]["ons"].append(matfile["spm_inputs"]["ons"].sort())
				params["experiment_details"]["spm_inputs"][t][s]["dur"].append(matfile["spm_inputs"]["dur"])
				# Pull items
				try:
					params["experiment_details"]["design"][t][s]["items"].append(matfile["items_run"])
				except KeyError:
					params["experiment_details"]["design"][t][s]["items"].append(matfile["items"])
				# Pull design
				for k in matfile["conditions"].keys():
					params["experiment_details"]["design"][t][s][k].append(matfile["conditions"][k])
					# assumes that "conditions" is a structure with fields corresponding to condition variables
					# see: rework_behavioral.m
				# Pull covariates
				for k in matfile["covariates"].keys():
					params["experiment_details"]["covariates"][t][s][k].append(matfile["covariates"][k])
					# assumes that "covariates" is a structure with fields corresponding to covariate variables (e.g., key, RT)
					# see: rework_behavioral.m	
				if argu[2]=='v':
					print("Finished with %s" % m)

	print("Done!\nWriting to %s.json." % json_name)

	with open(json_name + '.json','w') as jsonfile:
		json.dump(params,jsonfile)

if __name__ == "__main__":
	configure_nipype_params(sys.argv)

