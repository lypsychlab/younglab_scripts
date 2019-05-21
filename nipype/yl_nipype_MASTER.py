# import statements here
import nipype.interfaces.io as nio 
import nipype.interfaces.utility as nutil
import custom_utils
import nipype.interfaces.spm as nspm
import nipype.interfaces.afni as nafni
import nipype.interfaces.fsl as nfsl
import nipype.algorithms.rapidart as nart
import nipype.algorithms.misc as nmisc
import nipype.algorithms.modelgen as ngen
import nipype.pipeline.engine as npe 
import json, os, shutil, sys
from collections import OrderedDict


def yl_nipype_MASTER(yl_nipype_params_file,*args):
	"""
	Master function to implement a nipype processing pipeline.
	
	Required arguments:
	yl_nipype_params_file : full path to *_params.json file
	
	Optional arguments:
	args[0] : full path to *_software_dict.json file 

	If you are saving a modified copy of this function, please name like so:
	yl_nipype_myfunction.py
	"""

	# note: need to add Align_epi_anat, 3dDeconvolve, 3dREMLfit, 3dANOVA, 3dClustSim
	# to nipype interfaces
	# if isinstance(yl_nipype_params_file,str): 
	# # running from another function, e.g. test function
	# 	yl_nipype_params_file=[yl_nipype_params_file,args]
	print(args)
	try:
		if sys.ps1: # we're in interactive mode
			pass # don't need to do anything
	except AttributeError: # we're in command-line mode
		if len(yl_nipype_params_file) > 1: # we have optional arguments
			args = yl_nipype_params_file[1:]
		else: args = []
		yl_nipype_params_file = yl_nipype_params_file[0] # mandatory argument

	##### SETTING UP #####
	# Find parameter file & load
	print('Loading files and setting up...')
	print('Using parameter file: {}'.format(yl_nipype_params_file))
	with open(yl_nipype_params_file,'r') as jsonfile:
		params = json.load(jsonfile, object_pairs_hook=OrderedDict)

	# Navigate to study directory & set up directory/workflow name for nipype
	studydir = os.path.join(params["directories"]["root"],
		params["directories"]["study"])
	workflow = npe.Workflow(name=params["directories"]["workflow_name"])
	workflow.base_dir = studydir
	if not os.path.exists(os.path.join(studydir,params["directories"]["workflow_name"])):
		os.makedirs(os.path.join(studydir,params["directories"]["workflow_name"]))

	# Set up software dictionary mapping software names to interface functions
	if len(args) and isinstance(args[0],tuple):
		args[0]=args[0][0]
	if len(args): # if we have optional arguments
		print('Using custom software file: %s',args[0])
		software_file = args[0] 
	else:
		software_file = '/home/younglw/lab/scripts/nipype/yl_nipype_software_dict_MASTER.json'
	with open(software_file,'r') as jsonfile:
		software_dict = json.load(jsonfile, object_pairs_hook=OrderedDict)

	# Convert the function name strings in the dict to function pointers
	for k in software_dict: # for each software type
		for k2 in software_dict[k]: # for each node type
			for k3 in software_dict[k][k2]: # for each parameter pair
				if k3 == 'func':
					software_dict[k][k2][k3] = eval(software_dict[k][k2][k3]) # point to the function object


	software_key = params["global_software_specs"]["software"]

	os.chdir(os.path.join(params["directories"]["root"],params["directories"]["study"]))

	##### SUBFUNCTION DEFINITIONS #####
	def create_subj_info(params,subject_id,task_name):
		"""get list of Bunches containing cond/ons/dur info per subject/task"""
		from nipype.interfaces.base import Bunch
		output = []
		spm_inputs = params['experiment_details']['spm_inputs']
		for this_run in range(len(spm_inputs[task_name][subject_id]['dur'])):
			on = []
			du = []
			cn = []
			# only append if there's data for this condition
			for this_cond in range(len(spm_inputs[task_name][subject_id]['ons'][this_run])):
				if spm_inputs[task_name][subject_id]['ons'][this_run][this_cond]:
					on.append(spm_inputs[task_name][subject_id]['ons'][this_run][this_cond])
					du.append(spm_inputs[task_name][subject_id]['dur'][this_run][this_cond])
					cn.append(params['experiment_details']['design'][task_name][subject_id]['condition'][this_run][this_cond])
			output.append(Bunch(conditions = cn, onsets=on, durations = du))
		return output

	def create_func_runs(params,subject_id,task_name):
		"""get list of lists containing functional files per run"""
		import os
		from glob import glob
		functional_runs = []
		# _subject_id_%s_task_name_%s/swraf%s-00%d-*.nii (DataGrabber format) ->
		# _subject_id_{subj}_task_name_{task}/swraf{subj}-00{run}-*.nii (Python native format)
		run_nums = params["experiment_details"]["design"][task_name][subject_id]["runs"]
		infile_dir = params["params"]["specify_design"]["infile_dir"]
		template = params["params"]["specify_design"]["template"]
		dir_string = os.path.join(infile_dir,template)
		for this_run in run_nums:
			srch_string = dir_string.format(subj=subject_id,task=task_name,run=str(this_run))
			func_files = glob(srch_string)
			# func_files = [os.path.join(srch_string,x) for x in os.listdir(srch_string)]
			functional_runs.append(func_files)
		return functional_runs	

	def add_node(node_name,is_first):
		"""
		Add a generic node to the workflow.
		"""
		software_key = get_software_key(node_name)
		print(software_key)
		# grab the corresponding function defined in software_dict
		node_function = software_dict[software_key][node_name]["func"]
		# do you want to specify custom input files? 
		node_inputs = params["params"][node_name]["specify_inputs"]
		# create a Node object, calling configure_node() to specify arguments
		this_node = npe.Node(interface = node_function(), name = node_name)
		configure_node(software_key,node_name,this_node,node_inputs,is_first)
		return this_node

	def get_software_key(node_name):
		if params["global_software_specs"]["use_global_specs"]:
			# use key associated with global software spec
			software_key = params["global_software_specs"]["software"]
		else:
			# use key associated with local software spec
			software_key = params["params"][node_name]["local_software_spec"]
		return software_key


	def configure_node(software_spec,node_name,node,specify_inputs,is_first):
		"""
		Configure the parameters for each specific type of node.

		software_spec : global variable controlling which software
			to use for this node
		node_name : name of node (string); corresponds to key in params["params"]
		node : Node() object
		specify_inputs : if 1, grab input files from specified directory
			if 0 (default), input files will be taken from output of previous node
		is_first : if 1, input files will be grabbed before doing any processing
		"""
		def grab_data(software_spec,node_name,node):
			ds = npe.Node(interface=nio.DataGrabber(),
				name="datasource_"+node_name) # create data grabber node
			ds.inputs.base_directory = params["params"][node_name]["infile_dir"]
			ds.inputs.template = params["params"][node_name]["template"]
			# TODO: add field_template for multiple outfields case
			ds.inputs.infields = params["params"][node_name]["infields"]
			ds.inputs.outfields = params["params"][node_name]["outfields"]
			ds.inputs.sort_filelist = params["params"][node_name]["sort"]
			grabbed_info=dict()
			for x in params["params"][node_name]["outfields"]:
				for y in params["params"][node_name]["infields"]:
					grabbed_info[x]=[[y,"*"]] 
			ds.inputs.template_args=grabbed_info
			workflow.connect([(infosource,ds,[('subject_id','subject_id')])]) 
			# ex. connect 'subject_id' from infosource to 'subject_id' of data grabber
			# infosource handles the iteration over subject ids
			for x in params["params"][node_name]["outfields"]:
				workflow.connect([(ds, node, [(x,x)])]) 
			# ex. connect 'in_files' output field to 'in_files' input field
			# assumes that names in outfields are also correct names of inputs to the node
			# ds pipes the files it grabs into the node that will process them

		if is_first: # implement generic data grabbing
			if node_name == "specify_design":
				pass
			else:
				grab_data(software_spec,node_name,node)

		if node_name == 'dicom': # specify dicom files/folder 
			if software_spec == 'spm': 
				if specify_inputs:
					grab_data(software_spec,node_name,node)
				node.inputs.output_dir_struct = params["params"]["dicom"]["output_dir_struct"]
			elif software_spec == 'afni':
				node.inputs.in_folder = os.path.join(studydir,
					params["directories"]["dicom_subdir"])

		elif node_name == 'slicetime': # specify slice-timing correction parameters
			if software_spec == 'spm':
				if specify_inputs:
					grab_data(software_spec,node_name,node)
				node.inputs.num_slices = params["params"]["slicetime"]["num_slices"]
				node.inputs.ref_slice = params["params"]["slicetime"]["ref_slice"]
				node.inputs.slice_order = list(range(2,params["params"]["slicetime"]["num_slices"]+1,2)) + list(range(1,params["params"]["slicetime"]["num_slices"]+1,2))
				node.inputs.time_acquisition = params["params"]["slicetime"]["TR"]-(params["params"]["slicetime"]["TR"]/params["params"]["slicetime"]["num_slices"])
				node.inputs.time_repetition = params["params"]["slicetime"]["TR"]
			elif software_spec == 'afni': pass

		elif node_name == 'realign': # specify realignment parameters
			if software_spec == 'spm':
				if specify_inputs:
					grab_data(software_spec,node_name,node)
				node.inputs.fwhm = params["params"]["realign"]["fwhm"]
				node.inputs.quality = params["params"]["realign"]["quality"]
				node.inputs.register_to_mean = params["params"]["realign"]["register_to_mean"]
			elif software_spec == 'afni': pass

		elif node_name == 'reslice': # specify reslicing parameters
			if software_spec == 'spm':
				if specify_inputs:
					grab_data(software_spec,node_name,node)
				node.inputs.interp = params["params"]["reslice"]["interp"]
			elif software_spec == 'afni': pass

		elif node_name == 'coregister': # specify coregistration parameters
			if software_spec == 'spm':
				grab_data(software_spec,node_name,node) # always grab structural image

		elif node_name == 'normalize': # specify normalization parameters
			if software_spec == 'spm':
				node.inputs.apply_to_files = params["params"]["normalize"]["reference_template"]
			elif software_spec == 'afni': pass

		elif node_name == 'smooth': # specify smoothing parameters
			if software_spec == 'spm':
				node.inputs.fwhm = params["params"]["smooth"]["fwhm"]
			elif software_spec == 'afni': pass

		elif node_name == "skull_strip":
			if software_spec == 'fsl':
				node.inputs.frac = params["params"]["skull_strip"]["frac"]
				node.inputs.mask = params["params"]["skull_strip"]["mask"]
				node.inputs.out_file = params["params"]["skull_strip"]["out_file"]
			else:
				print("WARNING: You must use FSL to perform skull-stripping.")

		elif node_name == "gunzip":
			if software_spec == 'nipype':
				if specify_inputs:
					grab_data(software_spec,node_name,node)
			else:
				print("WARNING: You must set local_software_spec to nipype to use gunzip.")

		elif node_name == 'model':
			if software_spec == 'spm' : 
				print('WARNING: Use specify_design (not model or model_reml) to model with SPM.')			
			elif software_spec == 'afni' : pass # put in afni params here

		elif node_name == 'model_reml':
			if software_spec == 'spm' : 
				print('WARNING: Use specify_design (not model or model_reml) to model with SPM.')
			elif software_spec == 'afni' : pass # put in afni params here

		elif node_name == 'specify_design': # specify parameters for first-level design setup
			if software_spec == 'spm':
				if is_first or specify_inputs:
					# set up list of lists of functional runs via create_func_runs
					func_runs_node = npe.Node(nutil.Function(input_names=['params','subject_id','task_name'],
						output_names=['functional_runs'],
						function=create_func_runs),
						name='create_func_runs')
					func_runs_node.inputs.params = params
					workflow.connect([(infosource,func_runs_node,[('subject_id','subject_id'),
						('task_name','task_name')])])
					workflow.connect([(func_runs_node,node,[('functional_runs','functional_runs')])])
				# pipe subject information out of infosource node, using create_subj_info
				subj_info_node = npe.Node(nutil.Function(input_names=['params','subject_id','task_name'],
					output_names=['subject_info'],
					function=create_subj_info),
					name='create_subj_info')
				subj_info_node.inputs.params = params
				workflow.connect([(infosource,subj_info_node,[('subject_id','subject_id'),
						('task_name','task_name')])])
				workflow.connect([(subj_info_node,node,[('subject_info','subject_info')])])
				node.inputs.high_pass_filter_cutoff = params["params"]["specify_design"]["high_pass_filter_cutoff"]
				node.inputs.input_units = params["params"]["specify_design"]["input_units"]
				node.inputs.time_repetition = int(params["params"]["specify_design"]["time_repetition"])
			elif software_spec == 'afni': pass

		elif node_name == 'design': # specify parameters for first-level design
			if software_spec == 'spm':
				if not params["node_flags"]["specify_design"]:
					print("ERROR: You have not included the specify_design node in this workflow.")
				if specify_inputs:
					print("ERROR: Do not set specify_inputs = 1 for the design node.\nRun specify_design and design in the same workflow.")
				if params["node_flags"]["skull_strip"]: #if we have made a binary brain mask in this workflow
					workflow.connect([(skull_strip,node,[('mask_file','mask_image')])]) # FIX ME
				else:
					grab_data(software_spec,node_name,node)
					# NOTE: this will pipe the name of a skull-stripped mask file,
					# not the session information, which needs to be piped directly from a specify_design node
				node.inputs.bases = params["params"]["design"]["bases"]
				node.inputs.interscan_interval = params["params"]["design"]["interscan_interval"]
				node.inputs.timing_units = params["params"]["design"]["timing_units"]
			elif software_spec == 'afni': pass

		elif node_name == 'estimate': # specify parameters for model estimation
			if software_spec == 'spm':
				node.inputs.estimation_method = params["params"]["estimate"]["estimation_method"]
			elif software_spec == "afni" : pass

		elif node_name == 'onesample_T': # specify parameters for 1-sample T-test
			if software_spec == "spm":
				if specify_inputs:
					grab_data(software_spec,node_name,node)
				node.inputs.threshold_mask_none = params["params"]["onesample_T"]["threshold_mask_none"]
				node.inputs.global_calc_omit = params["params"]["onesample_T"]["global_calc_omit"]
				node.inputs.no_grand_mean_scaling = params["params"]["onesample_T"]["no_grand_mean_scaling"]
				node.inputs.use_implicit_threshold = params["params"]["onesample_T"]["use_implicit_threshold"]
			elif software_spec == 'afni': pass

		elif node_name == 'twosample_T': # specify parameters for 2-sample T-test
			if software_spec == 'spm':
				if specify_inputs:
					ds = nio.DataGrabber()
					ds.inputs.base_directory = params["params"]["twosample_T"]["infile_dir_1"]
					ds.inputs.template = params["params"]["twosample_T"]["infile_template_1"]
					node.inputs.group1_files = ds.run()
					ds = nio.DataGrabber()
					ds.inputs.base_directory = params["params"]["twosample_T"]["infile_dir_2"]
					ds.inputs.template = params["params"]["twosample_T"]["infile_template_2"]
					node.inputs.group2_files = ds.run()
				node.inputs.threshold_mask_none = params["params"]["twosample_T"]["threshold_mask_none"]
				node.inputs.global_calc_omit = params["params"]["twosample_T"]["global_calc_omit"]
				node.inputs.no_grand_mean_scaling = params["params"]["twosample_T"]["no_grand_mean_scaling"]
				node.inputs.use_implicit_threshold = params["params"]["twosample_T"]["use_implicit_threshold"]
				node.inputs.unequal_variance = params["params"]["twosample_T"]["unequal_variance"]	

		elif node_name == 'contrast': # specify parameters for T/F contrasts
			if software_spec == 'spm':
				if specify_inputs:
					ds = nio.DataGrabber()
					ds.inputs.base_directory = params["params"]["contrast"]["infile_dir"]
					ds.inputs.template = 'beta*.nii'
					node.inputs.beta_images = ds.run()
					ds.inputs.template = 'SPM.mat'
					node.inputs.spm_mat_file = ds.run()
					ds.inputs.template = 'ResI*.nii'
					node.inputs.residual_image = ds.run()
				# build list of tuples for T-contrasts
				con_info = params["params"]["contrast"]["contrasts"]
				node.inputs.contrasts = [tuple(con_info[i].values()) for i in con_info]
				if params["params"]["contrast"]["contrast_type"] == 'F': # list of T contrasts
					node.inputs.contrasts = [(params["params"]["contrast"]["Fcontrast_name"],'F',node.inputs.contrasts)]

		elif node_name == 'cluster_correct': # specify cluster correction parameters
			if software_spec == 'spm':
				if specify_inputs:
					ds = nio.DataGrabber()
					ds.inputs.base_directory = params["params"]["cluster_correct"]["infile_dir"]
					ds.inputs.template = 'SPM.mat'
					ds.inputs.spm_mat_file = ds.run()
					ds.inputs.template = params["params"]["cluster_correct"]["template"]
					ds.inputs.stat_image = ds.run()
				node.inputs.contrast_index = params["params"]["cluster_correct"]["contrast_index"]
				node.inputs.extent_fdr_p_threshold = params["params"]["cluster_correct"]["cluster_p_thresh"]
				node.inputs.extent_threshold = params["params"]["cluster_correct"]["cluster_k_extent"]
				node.inputs.height_threshold = params["params"]["cluster_correct"]["voxel_p_thresh"]
				node.inputs.use_fwe_correction = params["params"]["cluster_correct"]["use_fwe_correction"]
			elif software_spec == 'afni': pass

		else:
			warnings.warn('Unrecognized node name!')

	##### CREATE, CONFIGURE, & CONNECT NODES #####

	# Create infosource node to handle subject/task iteration
	infosource = npe.Node(interface=nutil.IdentityInterface(fields=['subject_id','task_name']),
		name='infosource')
	infosource.iterables = [('subject_id',params["experiment_details"]["subject_ids"]),
	('task_name',params["experiment_details"]["task_names"])]


	# Check the node flags and create nodes
	print('Checking flags...')
	is_first = 1
	for flagname, flag in params["node_flags"].items(): # iterate through flags
		if flag:
			node_name = flagname
			print('Creating node %s' % node_name)
			new_node = add_node(node_name,is_first) # create the node
			if not is_first: # don't auto-connect the first node!
				if ~params["params"][node_name]["specify_inputs"]: # default: join node to previous node
					print('Connecting {} to {}'.format(old_node_name,node_name))
					software_key = get_software_key(node_name)
					print(software_key)
					if type(software_dict[software_key][node_name]["inp"])==str:
						software_dict[software_key][node_name]["inp"]=[software_dict[software_key][node_name]["inp"]]
					print(old_software_key)
					if type(software_dict[old_software_key][old_node_name]["output"])==str:
						software_dict[old_software_key][old_node_name]["output"]=[software_dict[old_software_key][old_node_name]["output"]]
					num_inputs = len(software_dict[software_key][node_name]["inp"])
					# create a tuple to match old outputs to new inputs
					connectors = [(software_dict[old_software_key][old_node_name]["output"][i],
						software_dict[software_key][node_name]["inp"][i]) for i in range(num_inputs)]
					workflow.connect([(old_node, new_node, connectors)]) 
					# connect input of this node to output of immediate previous node
					# note that this connects nodes serially, in the order they appear in params["node_flags"]
					# to change the node order, change the order of the flags in your parameter file
					# to chain different outputs/inputs, modify the associated fields in your software_dict file
				else: # just add node to workflow, don't join it to previous node
					print('Adding node {} without connecting'.format(node_name))
					workflow.add_nodes([new_node])
			else: # if it's the first/only node, chain nodes
				start_node = new_node
				is_first=0
				# workflow.add_nodes([new_node])
			old_node_name = node_name # this node now becomes the 'old node'
			old_node = new_node
			old_software_key = get_software_key(node_name)

	##### SET UP SUBJECTS/TASKS/RUNS LOOPING #####
	print('Implementing loops...')
	# Implement subject looping for entire workflow by default
	# start_node.iterables = ('subject_id',params["experiment_details"]["subject_ids"])
	# Implement any other iterations that appear in the parameter file
	for i in range(len(params["iterate"]["node_names"])): # for each iterable node
		# task looping not natively supported, so must specify
		if params["iterate"]["iterate_over"][i][0] == 'task_name':
			this_node_name = params["iterate"]["node_names"][i] # name of node to iterate
			if this_node_name == 'specify_design' : pass # task looping is already set in configure_node
			else:
				this_node = eval(this_node_name) # pointer to node
				this_iter_over = params["iterate"]["iterate_over"][i][1] # name of input files variable to iterate
				these_inputs = [] # list to hold lists of input files
				for j in range(len(params["experiment_details"]["task_names"])): # for each task
					search_template = params["iterate"]["iterate_values"][i][j] # regular expression matching
					ds = nio.DataGrabber()
					ds.inputs.base_directory = params["params"][this_node_name]["infile_dir"]
					ds.inputs.template = search_template # search for files with this type of name
					these_inputs.append(ds.run()) # add the list of grabbed files to the list
				this_node.iterables = (this_iter_over,these_inputs)  
		else: # iterate the regular nipype way
			eval(params["iterate"]["node_names"][i]).iterables= (
				params["iterate"]["iterate_over"][i],
				params["iterate"]["iterate_values"][i]
				)
			# Syntax: thisnode.iterables = (variable_to_iterate, values_to_iterate)


	##### FINISHING #####
	if not os.path.exists(os.path.join(studydir,params["directories"]["workflow_name"],'code')):
		os.mkdir(os.path.join(studydir,params["directories"]["workflow_name"],'code'))
	# Copy parameter file into /code subdir of workflow dir
	# shutil.copy(yl_nipype_params_file,
	# 	os.path.join(studydir,params["directories"]["workflow_name"],'code',yl_nipype_params_file))
	# # Copy software_dict file into /code subdir as well
	# shutil.copy(software_file,
	# 	os.path.join(studydir,params["directories"]["workflow_name"],'code',yl_nipype_params_file))

	# Run the workflow
	print('Running workflow...')
	workflow.write_graph()
	workflow.run()
	print('Done.\nWorkflow folder: %s' % os.path.join(studydir,params["directories"]["workflow_name"]))



if __name__ == "__main__":
	yl_nipype_MASTER(sys.argv[1:])
