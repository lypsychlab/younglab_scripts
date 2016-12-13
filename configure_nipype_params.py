import json, sys

def configure_nipype_params(argu):
	"""
	A little interactive function to fill in *_params.json file
	"""

	json_name = argu[1]
	with open('/home/younglw/lab/scripts/yl_nipype_params_MASTER.json','r') as jsonfile:
		params=json.load(jsonfile)

	studyname = raw_input('Enter study name: ')
	wfname = raw_input('Enter workflow name: ')
	subjtag = raw_input('Enter subject tag (e.g. SAX_DIS): ')
	sub_nums=[str(x) for x in raw_input('Enter subject numbers (separate with spaces): ').split(' ')]
	tsks = [str(x) for x in raw_input('Enter task names (separate with spaces): ').split(' ')]

	params["directories"]["study"] = studyname
	params["directories"]["workflow_name"] = wfname
	params["experiment_details"]["subject_tag"] = subjtag
	params["experiment_details"]["subject_nums"] = sub_nums
	params["experiment_details"]["task_names"] = tsks

	print("Pulling information from .mat files now...\n")

	print("Done!\nWriting to " + json_name ".json.\n")

	with open(json_name + '.json','w') as jsonfile:
		json.dump(params,jsonfile)

if __name__ == "__main__":
	configure_nipype_params(sys.argv)

