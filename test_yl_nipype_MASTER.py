import unittest
import os.path as pth

default_studydir = '/home/younglw/lab/test_data'

# test fixture: import statements, loading parameter files
class BasicTestCase(unittest.TestCase):
	def setUp(self):
		import nipype.interfaces.spm as nspm
		import nipype.interfaces.afni as nafni
		import nipype.interfaces.fsl as nfsl
		import nipype.algorithms.modelgen as ngen
		import nipype.pipeline.engine as npe 
		import json, os, shutil, sys
		from collections import OrderedDict
		
	def tearDown(self):

# testing basic nipype functionality

# test case: bare-bones node & workflow creation
class NipypeTestCase(BasicTestCase):
	def setUp(self):
		# fixture: implement some default node/workflow names and interfaces
		super().setUp()
		default_interfaces = [nspm.utils.DicomImport(),nspm.utils.Realign()]
		default_nodenames = ['dicomnode','realignnode']
		default_connectors = ('out_files','in_files')
		default_wfname = 'myworkflow'
	def test_node_creation(self):
		new_node = npe.Node(name=default_nodenames[0],interface=default_interfaces[0])
		new_node_2 = npe.Node(name=default_nodename[1],interface=default_interface[1])
		assertIsInstance(new_node,npe.Node)
		assertIsInstance(new_node_2,npe.Node)
	def test_workflow_creation(self):
		new_wf = npe.Workflow(name=default_wfname)
		assertIsInstance(new_wf,npe.Workflow)
	def test_node_connect(self):
		new_node = npe.Node(name=default_nodenames[0],interface=default_interfaces[0])
		new_node_2 = npe.Node(name=default_nodename[1],interface=default_interface[1])
		new_wf = npe.Workflow(name=default_wfname)
		new_wf.connect([(new_node,new_node_2,default_connectors)])
		assertTrue(new_wf._has_node(new_node))
		assertTrue(new_wf._has_node(new_node_2))
		assertTrue(new_wf._graph.get_edge_data(new_node,new_node_2,default=0))
		# 'default=0' above specifies that if no connection is found, return 0
		# assertTrue checks that this is NOT the case, after connecting nodes


# testing the yl_nipype script functions (realistic environment,)

# test case: loading and preprocessing JSON files
class JSONDictionariesTestCase(BasicTestCase):
	def test_loading_software_dict(self):
		# load the dict
		with open(default_software_file,'r') as jsonfile:
			default_software_dict = json.load(jsonfile, object_pairs_hook=OrderedDict)
		assertTrue(bool(default_software_dict))
	def test_loading_params_dict(self):
		with open(default_params_file,'r') as jsonfile:
			default_params = json.load(jsonfile, object_pairs_hook=OrderedDict)
		assertTrue(bool(default_params_dict))
	def test_convert_functions(self):
		with open(default_software_file,'r') as jsonfile:
			default_software_dict = json.load(jsonfile, object_pairs_hook=OrderedDict)
		for k in default_software_dict: # for each software type
			for k2 in default_software_dict[k]: # for each node type
				for k3 in default_software_dict[k][k2]: # for each parameter pair
					if k3 == 'func':
						default_software_dict[k][k2][k3] = eval(default_software_dict[k][k2][k3]) # point to the function object
						assertTrue(callable(default_software_dict[k][k2][k3]))

class InfosourceTestCase(BasicTestCase):
	def setUp(self):
		super().setUp()
		default_params_file = 'yl_nipype_params_MASTER.json'
		default_params_file = pth.join()
		with open(default_params_file,'r') as jsonfile:
			default_params = json.load(jsonfile, object_pairs_hook=OrderedDict)
		# load parameter file
	def test_create_infosource(self):

# test case: subject_info (inherit fixtures from above)
# test method: creating subject info
class SubjectInfoTestCase(BasicTestCase):
	def setUp(self):
		super().setUp()
		from nipype.interfaces.base import Bunch
		default_subj = 'subject01'
		default taskname = 'task'
	def test_create_subj_info(self):
	def test_subj_info_node(self):

# test case frame: make a Node() from every node flag 
# fixture: set all node flags to 1
# fixture: vary the software flag
# fixture: source subject info from an old chunk of dataset set aside for testing
# fixture: source data from testing dataset
# test method: add_node()
# test method: configure_node()

# testing as if you are a user (realistic, running actual workflows)

# test case: preprocessing multiple subjects (spm)
# fixture: use dicom files, in .../testing_dataset/dicom

# test case: modeling data (spm)
# fixture: use previously preprocessed data, in .../testing_dataset/model

# test case: contrasts (spm)
# fixture: use previously modeled data, in /testing_dataset/preproc




