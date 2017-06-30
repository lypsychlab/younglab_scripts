import os, json
from collections import OrderedDict

def convert_TR(paramfile):
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
