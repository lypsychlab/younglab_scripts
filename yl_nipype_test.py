import unittest

# test fixture: import statements, loading parameter files
def BasicTestCase(unittest.TestCase):
	def setUp():
		import nipype.interfaces.spm as nspm
		import nipype.interfaces.afni as nafni
		import nipype.interfaces.fsl as nfsl
		import nipype.algorithms.modelgen as ngen
		import nipype.pipeline.engine as npe 
		import json, os, shutil, sys
		from collections import OrderedDict

# testing basic nipype functionality

# test case: bare-bones node & workflow creation
# fixture: implement some default node/workflow names and interfaces
# assert: nodes and workflow exist
# assert: can connect the nodes

# testing the yl_nipype script functions (realistic environment,)

# test case: convert all functions in software_dict to function pointers

# test case: subject_info (inherit fixtures from above)
# test method: creating subject info

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




