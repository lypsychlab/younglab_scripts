# Usage (terminal): 
# >> module load anaconda/wasserem
# >> python test_yl_nipype_MASTER NameOfTestCase

import unittest, sys
import os.path as pth
# import networkx as nx
import nipype.interfaces.io as nio 
import nipype.interfaces.utility as nutil
import nipype.interfaces.spm as nspm
import nipype.interfaces.afni as nafni
import nipype.interfaces.fsl as nfsl
import nipype.algorithms.modelgen as ngen
import nipype.pipeline.engine as npe 
import json, os, shutil, sys
from collections import OrderedDict
default_studydir = '/home/younglw/lab/scripts'
default_params_file = 'yl_nipype_params_MASTER.json'
default_software_file = 'yl_nipype_software_dict.json'
default_params_file = pth.join(default_studydir,default_params_file)
with open(default_params_file,'r') as jsonfile:
	default_params = json.load(jsonfile, object_pairs_hook=OrderedDict)



# All other test cases inherit from this
class BasicTestCase(unittest.TestCase):
	def setUp(self):
		pass
		# Every test will import libraries & load parameter file
		# import nipype.interfaces.io as nio 
		# import nipype.interfaces.utility as nutil
		# import nipype.interfaces.spm as nspm
		# import nipype.interfaces.afni as nafni
		# import nipype.interfaces.fsl as nfsl
		# import nipype.algorithms.modelgen as ngen
		# import nipype.pipeline.engine as npe 
		# import json, os, shutil, sys
		# from collections import OrderedDict
		# default_params_file = 'yl_nipype_params_MASTER.json'
		# default_params_file = pth.join(default_studydir,default_params_file)
		# with open(default_params_file,'r') as jsonfile:
		# 	default_params = json.load(jsonfile, object_pairs_hook=OrderedDict)
	# def tearDown(self):

# Use for testing code that requires workflows, nodes, etc.
class BasicEngineTestCase(BasicTestCase):
	def setUp(self):
		super().setUp()
		self.default_interfaces = [nspm.utils.DicomImport(),nspm.preprocess.Realign()]
		self.default_nodenames = ['dicomnode','realignnode']
		self.default_connectors = [('out_files','in_files')]
		self.default_wfname = 'myworkflow'
		self.default_fields = ['subject_id','task_name']

# testing basic nipype functionality w/toy nodes

# test case: bare-bones node & workflow creation
class NipypeTestCase(BasicEngineTestCase):
	def test_node_creation(self):
		new_node = npe.Node(name=self.default_nodenames[0],interface=self.default_interfaces[0])
		new_node_2 = npe.Node(name=self.default_nodenames[1],interface=self.default_interfaces[1])
		self.assertIsInstance(new_node,npe.Node)
		self.assertIsInstance(new_node_2,npe.Node)
	def test_workflow_creation(self):
		new_wf = npe.Workflow(name=self.default_wfname)
		self.assertIsInstance(new_wf,npe.Workflow)
	def test_node_connect(self):
		new_node = npe.Node(name=self.default_nodenames[0],interface=self.default_interfaces[0])
		new_node_2 = npe.Node(name=self.default_nodenames[1],interface=self.default_interfaces[1])
		new_wf = npe.Workflow(name=self.default_wfname)
		new_wf.connect([(new_node,new_node_2,self.default_connectors)])
		self.assertTrue(new_wf._has_node(new_node))
		self.assertTrue(new_wf._has_node(new_node_2))
		self.assertTrue(new_wf._graph.get_edge_data(new_node,new_node_2,default=False))
		# 'default=0' above specifies that if no connection is found, return False
		# assertTrue checks that this is NOT the case, after connecting nodes


# testing the yl_nipype script functions (realistic environment, actual code/data)

# test case: loading and preprocessing JSON files
class JSONDictionariesTestCase(BasicTestCase):
	def test_loading_software_dict(self):
		with open(pth.join(default_studydir,default_software_file),'r') as jsonfile:
			default_software_dict = json.load(jsonfile, object_pairs_hook=OrderedDict)
		# assert that dict isn't empty
		self.assertTrue(bool(default_software_dict))
	def test_loading_params_dict(self):
		# assert that dict isn't empty
		self.assertTrue(bool(default_params))
	def test_convert_functions(self):
		with open(default_software_file,'r') as jsonfile:
			default_software_dict = json.load(jsonfile, object_pairs_hook=OrderedDict)
		for k in default_software_dict: # for each software type
			for k2 in default_software_dict[k]: # for each node type
				for k3 in default_software_dict[k][k2]: # for each parameter pair
					if k3 == 'func':
						default_software_dict[k][k2][k3] = eval(default_software_dict[k][k2][k3]) # point to the function object
						self.assertTrue(callable(default_software_dict[k][k2][k3]))

# test case: creating & connecting infosource/datasource nodes
class InfosourceTestCase(BasicEngineTestCase):
	def test_create_infosource(self):
		new_wf = npe.Workflow(name=default_wfname)
		infosource = npe.Node()
		infosource.interface = nutil.IdentityInterface(fields=default_fields)
		infosource.name = 'infosource'
		infosource.iterables = [('subject_id',params["experiment_details"]["subject_ids"]),
		('task_name',params["experiment_details"]["task_names"])]
		data_grabber = npe.Node(nio.DataGrabber(infields = default_fields),name='datasource')
		data_grabber.inputs.base_directory = default_studydir
		data_grabber.inputs.template = '/%s/%s/*'
		new_wf.connect([(infosource,data_grabber,[(default_fields[0],default_fields[0]),(default_fields[1],default_fields[1])])])
		# assert that an edge exists between these two nodes:
		assertTrue(new_wf._graph.get_edge_data(infosource,data_grabber,default=False))


# test case: subject_info (inherit fixtures from above)
# test method: creating subject info
class SubjectInfoTestCase(BasicTestCase):
	def setUp(self):
		super().setUp()
		from nipype.interfaces.base import Bunch
		default_subj = 'YOU_RACA_01'
		default_taskname = 'RACA'
	def test_create_subj_info(self):
		output = []
		for this_run in range(len(params['experiment_details']['spm_inputs'][taskname][subj]['dur'])):
			on = params['experiment_details']['spm_inputs'][taskname][subj]['ons'][this_run]
			du = params['experiment_details']['spm_inputs'][taskname][subj]['dur'][this_run]
			cn = params['experiment_details']['design'][taskname][subj]['condition'][this_run]
			# example with 2 conditions, 3 trials/condition, for a single run:
			# on = [[1,10,20],[5,15,25]]
			# du = [[3,3,3],[3,3,3]]
			# cn = ['condition1','condition2']
			output.insert(Bunch(conditions = cn, onsets=on, durations = du))
		# test that the output is of the right length
		assertEqual(len(output),len(params['experiment_details']['spm_inputs'][taskname][subj]['dur']))
		# test that the data actually was transferred
		for i in range(len(output)):
			assertEqual(output[i].on,params['experiment_details']['spm_inputs'][taskname][subj]['ons'][i])
			assertEqual(output[i].du,params['experiment_details']['spm_inputs'][taskname][subj]['dur'][i])
			assertEqual(output[i].cn,params['experiment_details']['spm_inputs'][taskname][subj]['condition'][i])

# test case frame: make a Node() from every node flag 
# fixture: set all node flags to 1
# fixture: vary the software flag
# fixture: source subject info from an old chunk of dataset set aside for testing (.../lab/test_data)
# fixture: source data from testing dataset (.../lab/test_data)
# test method: add_node()
# test method: configure_node()

# testing as if you are a user (realistic, running actual workflows)

# test case: preprocessing multiple subjects (spm)
# fixture: use dicom files, in .../testing_dataset/dicom

# test case: modeling data (spm)
# fixture: use previously preprocessed data, in .../testing_dataset/model

# test case: contrasts (spm)
# fixture: use previously modeled data, in /testing_dataset/preproc

if __name__ == '__main__':
	suite = unittest.TestLoader().loadTestsFromTestCase(eval(sys.argv[1]))
	unittest.TextTestRunner(verbosity=2).run(suite)


