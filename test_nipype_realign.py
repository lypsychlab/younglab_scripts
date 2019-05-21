import os.path as pth
# import networkx as nx
import nipype.interfaces.io as nio 
import nipype.interfaces.utility as nutil
import nipype.interfaces.spm as nspm
import nipype.interfaces.afni as nafni
import nipype.interfaces.fsl as nfsl
import nipype.algorithms.modelgen as ngen
import nipype.pipeline.engine as npe 
import json, os, shutil, sys, time
from collections import OrderedDict

starttime=time.time()
print('Beginning workflow creation...')
wf = npe.Workflow(name='test_nipype_realign')
wf.base_dir = '/home/younglw/lab/nipype_test_data'
try:
	os.makedirs(pth.join('/home/younglw/lab/nipype_test_data','test_nipype_realign'))
except FileExistsError: pass
# grab data
ds = npe.Node(interface=nio.DataGrabber(),
				name="datasource") # create data grabber node
ds.inputs.base_directory = '/home/younglw/lab/nipype_test_data/'
ds.inputs.template = 'preproc/_subject_id_YOU_HOWWHY_03_task_name_HOWWHY/slicetime/af%s.nii'
ds.inputs.outfields=['grabbed_files']
ds.inputs.sort_filelist=True
grabbed_info=dict()
grabbed_info['grabbed_files']=[['*']]
ds.inputs.template_args=grabbed_info

# make realignment node

realign = npe.Node(name='realign',interface=nspm.Realign(),fwhm=5,quality=0.9,register_to_mean=False)

wf.connect([(ds,realign,[('grabbed_files','in_files')])])
wf.write_graph()
midtime = time.time()
print('%s seconds elapsed. About to run workflow...' % (midtime-starttime))
wf.run()
endtime=time.time()
print('Done. %s seconds elapsed in total.' % (endtime-starttime))