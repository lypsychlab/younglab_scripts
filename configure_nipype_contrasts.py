import json, argparse, os, mat4py
from collections import OrderedDict

def configure_nipype_contrasts(spm_mat_path):
	'''Set up contrasts in your params file, based on contrasts drawn from an existing SPM.mat file.
	You must run pull_contrasts.m on your SPM.mat file first, which will product SPM_betas.mat.

	Usage:
	>> python configure_nipype_contrasts.py [path to dir containing SPM_betas.mat file]
	'''

	def ask_for_con():
		'''take input from user to build contrasts'''
		num_cons = len(params['params']['contrast']['contrasts'])
		params['params']['contrast']['contrasts'][str(num_cons+1)]=OrderedDict()
		con_name = input('Type name for contrast #{}: '.format(str(num_cons+1)))
		params['params']['contrast']['contrasts'][str(num_cons+1)]['name'] = con_name
		params['params']['contrast']['contrasts'][str(num_cons+1)]['con_type'] = 'T'
		con_vals = input('Type contrast values separated by spaces: ')
		con_vals = [float(x) for x in con_vals.split(' ')]
		if len(con_vals) ~= len(cond_names):
			print("Incorrect number of contrast values! Try again.")
			ask_for_con()
		params['params']['contrast']['contrasts'][str(num_cons+1)]['cond_names'] = cond_names
		params['params']['contrast']['contrasts'][str(num_cons+1)]['con_vals'] = con_vals

	paramfile = input('Type the full path to your parameter file, minus extension: ')
	with open(paramfile+'.json','r') as jsonfile:
		params = json.load(jsonfile,object_pairs_hook=OrderedDict)
	matfile = mat4py.loadmat(os.path.join(args.spm_mat_path,'SPM_betas.mat'))
	cond_names = [betaname for betaname in matfile['betanames']]
	# print('Condition names of betas in your SPM.mat file:')
	# for x in cond_names: print(x)
	params['params']['contrast']['contrasts']={}
	add_con = 'y'
	while add_con == 'y':
		print('Condition names of betas in your SPM.mat file:')
		for x in cond_names: print(x)
		ask_for_con()
		add_con = input('Add more contrasts? (y/n) ')

	print('Saving your parameter file.')
	with open(paramfile+'.json','w') as jsonfile:
		json.dump(params,jsonfile)

parser = argparse.ArgumentParser()
parser.add_argument("spm_mat_path",help="The full path to your SPM_betas.mat file, minus the filename")
args = parser.parse_args()
configure_nipype_contrasts(args)