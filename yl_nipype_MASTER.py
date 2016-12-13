# import statements here
import nipype.interfaces as nin
import nipype.algorithms as nal
import nipype.pipeline.engine as npe 
import json, os, shutil
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

	##### SETTING UP #####
	# Find parameter file & load
	with open(yl_nipype_params_file,'r') as jsonfile:
		params = json.load(jsonfile, object_pairs_hook=OrderedDict)

	# Navigate to study directory & set up directory/workflow name for nipype
	studydir = os.join(params["directories"]["root"],
		params["directories"]["study"])
	workflow = npe.Workflow(name=params["directories"]["workflow_name"])
	workflow.base_dir = studydir
	if not os.path.exists(os.join(studydir,params["directories"]["workflow_name"])):
		os.makedirs(os.join(studydir,params["directories"]["workflow_name"]))

	# Set up software dictionary mapping software names to interface functions
	if len(args): 
		software_file = args[0]
	else:
		software_file = '/home/younglw/lab/scripts/yl_nipype_software_dict_MASTER.json'
	with open(software_file,'r') as jsonfile:
		software_dict = json.load(jsonfile, object_pairs_hook=OrderedDict)

	# Convert the function name strings in the dict to function pointers
	for k in software_dict: # for each software type
		for k2 in software_dict[k]: # for each node type
			for k3 in k[k2]: # for each parameter pair
				if k3 == 'func':
					k2[k3] = eval(k2[k3])

	##### CREATE, CONFIGURE, & CONNECT NODES #####
	# Check the node flags and create nodes
	not_first = 0
	for flagname, flag in params["node_flags"].items():
		if flag:
			node_name = flagname
			new_node = add_node(node_name) # create the node
			if not_first:
				if ~params["params"][node_name]["specify_inputs"]: # default: join node to previous node
					num_inputs = len(software_dict[software_key][node_name][inp])
					# create a tuple to match old outputs to new inputs
					connectors = [(software_dict[old_software_key][old_node_name]["output"],
						software_dict[software_key][node_name]["inp"]) for i in range(num_inputs)]
					workflow.connect([(old_node, new_node, connectors)]) 
					# connect input of this node to output of immediate previous node
					# note that this connects nodes serially, in the order they appear in params["node_flags"]
					# to change the node order, change the order of the flags in your parameter file
					# to chain different outputs/inputs, modify the associated fields in your software_dict file
					else: # just add node to workflow, don't join it to previous node
						workflow.add_nodes([new_node])
			else: # if it's the first/only node, just add it
				start_node = new_node
				workflow.add_nodes([new_node])
			old_node_name = node_name # this node now becomes the 'old node'
			old_node = new_node
			old_software_key = software_key
			not_first = 1

	##### SET UP SUBJECTS/TASKS/RUNS LOOPING #####
	# Implement subject looping
	start_node.iterables = ('subject_id',params["experiment_details"]["subject_nums"])


	##### FINISHING #####
	# Copy parameter file into /code subdir of workflow dir
	shutil.copy(yl_nipype_params_file,
		os.join(studydir,params["directories"]["workflow_name"],'code'))
	# Copy software_dict file into /code subdir as well
	shutil.copy(software_file,
		os.join(studydir,params["directories"]["workflow_name"],'code'))

	# Run the workflow
	workflow.write_graph()
	workflow.run()

	# Function definitions

	def add_node(node_name):
		"""
		Add a generic node to the workflow.
		"""
		if params["global_software_specs"]["use_global_specs"]:
			# use key associated with global software spec
			global software_key = params["global_software_specs"]["software"]
		else:
			# use key associated with local software spec
			global software_key = params[node_name]["local_software_spec"]
		# grab the corresponding function defined in software_dict
		node_function = software_dict[software_key][node_name]["func"]
		# do you want to specify custom input files? 
		node_inputs = params["params"][node_name]["specify_inputs"]
		# create a Node object, calling configure_node() to specify arguments
		this_node = npe.Node(interface = node_function(), name = node_name)
		configure_node(software_key,node_name,this_node,node_inputs)
		return this_node


	def configure_node(software_spec,node_name,node,specify_inputs):
		"""
		Configure the parameters for each specific type of node.

		software_spec : global variable controlling which software
			to use for this node
		node_name : name of node (string); corresponds to key in params["params"]
		node : Node() object
		specify_inputs : if 1, grab input files from specified directory
			if 0 (default), input files will be taken from output of previous node
		"""
		if node_name == 'dicom': # specify dicom files/folder 
			if software_spec == 'spm':
				if specify_inputs:
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["dicom"]["infile_dir"]
					ds.inputs.template = '*.dcm'
					dicom_files = ds.run()
				else:
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = os.join(studydir,
						params["directories"]["dicom_subdir"])
					ds.inputs.template = '*.dcm'
					dicom_files = ds.run()
				node.inputs.in_files = dicom_files
				node.inputs.output_dir_struct = params["params"]["dicom"]["output_dir_struct"]
			elif software_spec == 'afni':
				node.inputs.in_folder = os.join(studydir,
					params["directories"]["dicom_subdir"])

		elif node_name == 'slicetime': # specify slice-timing correction parameters
			if software_spec == 'spm':
				if specify_inputs:
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["slicetime"]["infile_dir"]
					ds.inputs.template = '*.nii'
					node.inputs.in_files = ds.run()
				node.inputs.num_slices = params["params"]["slicetime"]["num_slices"]
				node.inputss.ref_slice = params["params"]["slicetime"]["ref_slice"]
				node.inputs.slice_order = list(range(2,params["params"]["slicetime"]["num_slices"]+1,2)) + list(range(1,params["params"]["slicetime"]["num_slices"]+1,2))
				node.inputs.time_acquisition = params["params"]["slicetime"]["TR"]-(params["params"]["slicetime"]["TR"]/params["params"]["slicetime"]["num_slices"])
				node.inputs.time_repetition = params["params"]["slicetime"]["TR"]
			elif software_spec == 'afni': pass

		elif node_name == 'realign': # specify realignment parameters
			if software_spec == 'spm':
				if specify_inputs:
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["realign"]["infile_dir"]
					ds.inputs.template = '*.nii'
					node.inputs.in_files = ds.run()
				node.inputs.fwhm = params["params"]["realign"]["fwhm"]
				node.inputs.quality = params["params"]["realign"]["quality"]
				node.inputs.register_to_mean = params["params"]["realign"]["register_to_mean"]
			elif software_spec == 'afni': pass

		elif node_name == 'reslice': # specify reslicing parameters
			if software_spec == 'spm':
				node.inputs.space_defining = node.inputs.in_files[0]
				node.inputs.interp = params["params"]["reslice"]["interp"]
			elif software_spec == 'afni': pass

		elif node_name == 'normalize': # specify normalization parameters
			if software_spec == 'spm':
				node.inputs.template = params["params"]["normalize"]["template"]
			elif software_spec == 'afni': pass

		elif node_name == 'smooth': # specify smoothing parameters
			if software_spec == 'spm':
				node.inputs.fwhm = params["params"]["smooth"]["fwhm"]
			elif software_spec == 'afni': pass

		elif node_name == 'model':
			if software_spec == 'spm' : pass #raise an error: use specify_design/design
			elif software_spec == 'afni' : pass # put in afni params here

		elif node_name == 'model_reml':
			if software_spec == 'spm' : pass #raise an error: use specify_design/design
			elif software_spec == 'afni' : pass # put in afni params here

		elif node_name == 'specify_design': # specify parameters for first-level design setup
			if software_spec == 'spm':
				node.inputs.high_pass_filter_cutoff = params["params"]["specify_design"]["high_pass_filter_cutoff"]
				node.inputs.input_units = params["params"]["specify_design"]["input_units"]
				node.inputs.time_repetition = params["params"]["specify_design"]["time_repetition"]
				node.inputs.subject_info # fill this in  - emily
			elif software_spec == 'afni': pass

		elif node_name == 'design': # specify parameters for first-level design
			if software_spec == 'spm':
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
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["onesample_T"]["infile_dir"]
					ds.inputs.template = '*.nii'
					node.inputs.in_files = ds.run()
				node.inputs.threshold_mask_none = params["params"]["onesample_T"]["threshold_mask_none"]
				node.inputs.global_calc_omit = params["params"]["onesample_T"]["global_calc_omit"]
				node.inputs.no_grand_mean_scaling = params["params"]["onesample_T"]["no_grand_mean_scaling"]
				node.inputs.use_implicit_threshold = params["params"]["onesample_T"]["use_implicit_threshold"]
			elif software_spec == 'afni': pass

		elif node_name == 'twosample_T': # specify parameters for 2-sample T-test
			if software_spec == 'spm':
				if specify_inputs:
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["twosample_T"]["infile_dir_1"]
					ds.inputs.template = '*.nii'
					node.inputs.group1_files = ds.run()
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["twosample_T"]["infile_dir_2"]
					ds.inputs.template = '*.nii'
					node.inputs.group2_files = ds.run()
				node.inputs.threshold_mask_none = params["params"]["twosample_T"]["threshold_mask_none"]
				node.inputs.global_calc_omit = params["params"]["twosample_T"]["global_calc_omit"]
				node.inputs.no_grand_mean_scaling = params["params"]["twosample_T"]["no_grand_mean_scaling"]
				node.inputs.use_implicit_threshold = params["params"]["twosample_T"]["use_implicit_threshold"]
				node.inputs.unequal_variance = params["params"]["twosample_T"]["unequal_variance"]	

		elif node_name == 'contrast': # specify parameters for T/F contrasts
			if software_spec == 'spm':
				if specify_inputs:
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["contrast"]["infile_dir"]
					ds.inputs.template = 'beta*.nii'
					node.inputs.beta_images = ds.run()
					ds.inputs.template = 'SPM.mat'
					node.inputs.spm_mat_file = ds.run()
					ds.inputs.template = 'ResI*.nii'
					node.inputs.residual_image = ds.run()
				# build list of tuples for T-contrasts
				node.inputs.contrasts = [tuple(i.values()) for i in params["params"]["contrast"]["contrasts"]]
				if params["params"]["contrast"]["contrast_type"] == 'F': # list of T contrasts
					node.inputs.contrasts = [(params["params"]["contrast"]["Fcontrast_name"],'F',node.inputs.contrasts)]
			elif software_spec == 'afni': pass

		elif node_name == 'cluster_correct': # specify cluster correction parameters
			if software_spec == 'spm':
				if specify_inputs:
					ds = nin.io.DataGrabber()
					ds.inputs.base_directory = params["params"]["contrast"]["infile_dir"]
					ds.inputs.template = 'SPM.mat'
					ds.inputs.spm_mat_file = ds.run()
					ds.inputs.template = 'spmT*.nii'
					ds.inputs.stat_image = ds.run()
				node.inputs.contrast_index = params["params"]["cluster_correct"]["contrast_index"]
				node.inputs.extent_fdr_p_threshold = params["params"]["cluster_correct"]["cluster_p_thresh"]
				node.inputs.extent_threshold = params["params"]["cluster_correct"]["cluster_k_extent"]
				node.inputs.height_threshold = params["params"]["cluster_correct"]["voxel_p_thresh"]
				node.inputs.use_fwe_correction = params["params"]["cluster_correct"]["use_fwe_correction"]
			elif software_spec == 'afni': pass

		else:
			warnings.warn('Unrecognized node name!')
