import sys

def convert_to_BIDS(argv):
	"""convert_to_BIDS(argv):
	Convert a Younglab-style study to BIDS format (1.0.0rc2).

	Usage (terminal):
	>> python convert_to_BIDS.py [auto/inter] /path/to/study/dir

	Parameters:
	- argv: a list.
		- argv[1]: flag 'auto' or 'inter', to determine automatic vs interactive mode
		- argv[2]: full path to study directory (NO TRAILING SLASH)

	Returns:
	- None

	Python dependencies: json, os, fnmatch, sys, shutil, mat4py, csv
	MATLAB script dependencies: dicm2nii.m, run_dicm2nii.m, process_dcmHeaders.m
	 """
	import json, os, fnmatch, sys, shutil, mat4py, csv

	# convert_to_BIDS: convert a younglab-style study to BIDS format
	# Written for Python 2.7 
	# (c) Emily Wasserman, Sept 2016
	# 
	# How to run:
	# Open up a terminal on Pleiades and type:
	# module load python/2.7.10
	# python convert_to_BIDS.py auto /path/to/study/dir
	# or, for interactive format:
	# python convert_to_BIDS.py inter /path/to/study/dir
	# 
	# Flag options: 'auto', to automatically open a JSON file and convert to BIDS that way,
	# or 'inter', to run it interactively and then save a JSON file of the interactive inputs.
	# Auto mode will NOT help you create the experiment description file.
	# The path should be the FULL path to the study directory, e.g. /home/younglw/lab/IEHFMRI,
	# with NO trailing slash.
	# 
	# The final file structure will look like:
	# 
	# Younglab study folder/
	# 	bids_params.json
	# 	bids/
	# 		dataset_description.json
	# 		participants.tsv
	# 		sub-01/
	# 			anat/
	# 				sub-01_T1w.nii.gz
	# 				sub-01_T1w.json
	# 			func/
	# 				sub-01_task-TASKNAME_run-01.nii.gz
	# 				sub-01_task-TASKNAME_run-01.json	
	# 				sub-01_task-TASKNAME_run-01_events.tsv
	# 			
	# 
	# MATLAB script dependencies: dicm2nii.m, run_dicm2nii.m, process_dcmHeaders.m

	# import json, os, fnmatch, sys, shutil, mat4py, csv

	# HELPER FUNCTIONS:
	def copyDir(src,dest):
		"""copy a file from src into dest folder"""
		try:
			shutil.copytree(src,dest)
		except shutil.Error as e:
			print('Directory copy failure! Error: %s' % e)
		except OSError as e:
			print('Directory copy failure! Error: %s' % e)

	def askConvert():
		"""take user input to begin DICOM file conversion in interactive mode"""
		convYes=raw_input('Are you ready to start converting your DICOM files? (y/n)')
		if convYes=='y':
			print('Beginning DICOM file conversion...')
			# cmd1='module load matlab/2015a'
			# os.system(cmd1)
			for s in range(len(new_subject_dirs)):
				print('Running subject %s...' % str(s+1))
				cmd = "matlab -nodisplay -nosplash -r 'run_dicm2nii '%s' '%s''" % (dirpath+'/'+subject_dirs[s]+'/dicom',
				dirpath+'/bids/'+new_subject_dirs[s]+'/func')
				print(cmd)
				try:
					os.system(cmd)
					print('Done with subject %s.' % str(s+1))
				except OSError as e:
					print('There was a problem with your conversion. Error: %s' % e)
					return 0
		elif convYes == 'n': # if no, then return nothing
			print('OK, skipping DICOM conversion.')
			return 0
		else: 
			print('Unrecognized input! Let\'s try again...')
			askConvert()

	def dicom2JSON(pth,tasknames):
		"""convert relevant DICOM header .mat files in pth to JSON files"""
		# find all the .mat files within the directory pth
		# load each using mat4py
		# grab the useful metadata from that part of the struct
		# save it in an appropriately named JSON file within pth
		fieldNames = [
			'RepetitionTime',
			'TaskName', # this will be filled in from tasknames
			'Manufacturer',
			'ManufacturerModelName',
			'MagneticFieldStrength',
			'HardcopyDeviceSoftwareVersion',
			'ReceiveCoilName',
			'GradientSetType',
			'MRTransmitCoilSequence',
			'ScanningSequence',
			'SequenceVariant',
			'ScanOptions',
			'MRAcquisitionType',
			'SequenceName',
			'EchoTime',
			'SliceTiming',
			'SliceEncodingDirection',
			'FlipAngle',
			'MultibandAccelerationFactor'
		]

		outdict = {}

		for t in tasknames: # grab all .mats associated with this task
			mfiles=[f for f in os.listdir(pth) if fnmatch.fnmatch(f,'*'+t+'*.mat')]
			for runnum in range(len(mfiles)):
				data = mat4py.loadmat(pth+mfiles[runnum])
				for thisfield in fieldNames:
					try: 
						outdict[thisfield]=data[thisfield]
					except KeyError: 
						continue
				outdict['TaskName']=t
				jsonName = mfiles[runnum].replace('.mat','.json',1)
				with open(pth+jsonName,'w') as jsonfile:
					json.dump(outdict,jsonfile)




	def behav2TSV(fname,outpath,outfile):
		"""convert behavioral .mat files into .tsv files"""
		def argsort(S):
			return sorted(range(len(S)),key=S.__getitem__)

		print("Converting behavioral files into .tsv files...")
		# load the behavioral .mat file
		bdata=mat4py.loadmat(fname)
		# check that all the necessary variables are in there/fill missing with None
		if not 'spm_inputs' in bdata:
			print('ERROR: No spm_inputs variable in behavioral files!')
			return
		
		Namecol=[]
		Onscol=[]
		Durcol=[]
		# elaborate your spm_inputs variable
		for i in range(len(bdata['spm_inputs']['ons'])): #for each condition
			try: 
				namecol=[bdata['spm_inputs']['name'][i]] * (1+len(bdata['spm_inputs']['ons'][i]))
				Namecol = Namecol + namecol
				Onscol = Onscol + bdata['spm_inputs']['ons'][i]
				Durcol = Durcol + bdata['spm_inputs']['dur'][i]
			except TypeError: #if it's an int, meaning it's length 1
				namecol=[bdata['spm_inputs']['name'][i]]
				Namecol = Namecol + namecol
				Onscol = Onscol + [bdata['spm_inputs']['ons'][i]]
				Durcol = Durcol + [bdata['spm_inputs']['dur'][i]]
		inds=argsort(Onscol)

		for k in ['items_run','key','RT']:
			if not k in bdata:
				bdata[k] = [0] * (len(inds)+1)

		# set up your column names
		fieldNames=['onset','duration','condition','item','key','RT']
		if eventVars[0]: fieldNames=fieldNames+eventVars
		print(fieldNames)
		# open up a TSV file for writing
		with open(outpath+'/'+outfile,'w') as tsvfile:
			writer=csv.DictWriter(tsvfile,delimiter='\t',fieldnames=fieldNames)
			writer.writeheader()
			for i in range(len(inds)):
				try:
					newrow={
						'onset': Onscol[inds[i]],
						'duration': Durcol[inds[i]][0],
						'condition': Namecol[inds[i]],
						'item': bdata['items_run'][i],
						'key': bdata['key'][i][0],
						'RT': round(bdata['RT'][i][0],3)}
				except:
					newrow={
						'onset': Onscol[inds[i]],
						'duration': Durcol[inds[i]],
						'condition': Namecol[inds[i]],
						'item': bdata['items_run'][i],
						'key': bdata['key'][i][0],
						'RT': round(bdata['RT'][i][0],3)}
				# IMPORTANT: eventVars must be a sequence, even if only 1 item
				# also, this assumes that whatever your eventVars are,
				# they are the same length as your spm_inputs variable
				# i.e., one entry per stimulus run
				
					if eventVars[0]:
						for j in range(len(eventVars)):
							try:
								newrow[eventVars[j]]=bdata[eventVars[j]][i]
							except KeyError: 
								print('Warning: no event variable named %s in file %s' % (eventVars[j],fname))
				writer.writerow(newrow)

	# convert_to_BIDS MAIN FUNCTION
	# #############################
	# take arguments from the command line
	flag = argv[1]
	dirpath = argv[2]

	# make a 'bids' directory to put the converted dataset in
	newflag=0
	os.chdir(dirpath)
	if not os.path.exists(dirpath+'/bids'):
		os.makedirs(dirpath+'/bids')
		# assume that if dir doesn't exist, experiment description file doesn't either:
		newflag=1
		
	# if interactive, prompt the user for input:
	if flag == 'inter':
		# if this is the first time you're setting up,
		# make an experiment description JSON file
		if newflag:
			print('Note: please do NOT put spaces after commas when entering multiple answers.')
			study = raw_input('Study name: ')
			authors = [x for x in raw_input('List of authors (separated by commas): ').split(',')]
			ack = raw_input('A sentence or two acknowledging other contributors: ')
			ackMe = raw_input('How you would like to be acknowledged: ')
			funders = [x for x in raw_input('List your funding sources: ').split(',')]
			refsNLinks = [x for x in raw_input('List any references/links, such as data papers: ').split(',')]
			doiInfo = raw_input('DOI for the dataset: ')

			exper_descrip = {
				'Name': study,
				'BIDSversion': '1.0.0rc2',
				'License': 'CC0',
				'Authors': authors,
				'Acknowledgements': ack,
				'HowToAcknowledge': ackMe,
				'Funding': funders,
				'ReferencesAndLinks': refsNLinks,
				'DatasetDOI': doiInfo
			}

			with open(dirpath+'/bids/dataset_description.json','w') as jsonfile:
			# write inputs to json format
				json.dump(exper_descrip,jsonfile)

		# set up parameters for the actual processing

		# take user input in interactive mode
		subj_tag=raw_input('Subject tag (e.g., SAX_DIS): ')
		sub_nums=[str(x) for x in raw_input('Include these subjects: ').split()]
		tsks=[x for x in raw_input('Include these tasks: ').split(',')]
		eventVars = [x for x in raw_input('Include these optional event variables (e.g., readyRT): ').split(',')]

		bids_params={
		'subj_tag': subj_tag,
		'sub_nums': sub_nums,
		'tasks': tsks,
		'eventVars': eventVars
		}
		with open(dirpath+'/bids_params.json','w') as jsonfile:
			json.dump(bids_params,jsonfile)

	# load up saved params
	with open(dirpath+'/bids_params.json','r') as jsonfile:
		bids_params=json.load(jsonfile)
	subj_tag=bids_params['subj_tag']
	sub_nums=bids_params['sub_nums']
	tsks=bids_params['tasks']
	eventVars=bids_params['eventVars']
	##############

	# SET UP NEW FILE STRUCTURE

	# get the subject directories
	# e.g. 'SAX_DIS_01'
	subject_dirs=[subj_tag+'_'+x.zfill(2) for x in sub_nums]
	# add the standard 'sub' prefix
	# e.g. 'sub-01'
	new_subject_dirs=['sub-'+x.zfill(2) for x in sub_nums]

	# make participants.tsv file
	if newflag:
		print('Creating participants.tsv file...')
		print('Edit this file manually to fill in age, gender, ASD, etc.')
		with open(dirpath+'/bids/participants.tsv','w') as tsvfile:
			writer=csv.DictWriter(tsvfile,delimiter='\t',fieldnames=['participant_id'])
			writer.writeheader()
			for i in range(len(new_subject_dirs)):
				newrow={'participant_id':new_subject_dirs[i]}
				writer.writerow(newrow)

	# populate the bids folder with empty subject directories
		for d in new_subject_dirs:
			if not os.path.exists(dirpath+'/bids/'+d):
				os.makedirs(dirpath+'/bids/'+d) # make the subject folder
				os.makedirs(dirpath+'/bids/'+d+'/anat') # make the anatomical folder
				os.makedirs(dirpath+'/bids/'+d+'/func') # make the functional folder

		for t in tsks:
			for s in range(len(subject_dirs)):
				# get list of all behavioral .mats for this subject/task
				srch=subject_dirs[s]+'.*'+t+'*.*.mat'
				tskfiles=[f for f in os.listdir(dirpath+'/behavioural') if fnmatch.fnmatch(f.lower(),srch.lower())]
				numruns = len(tskfiles)
				# populate subject folder with functional run folders
				for r in range(numruns):
					os.makedirs(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+new_subject_dirs[s]+'_task-'+t.lower()+'_run-'+str(r+1).zfill(2))

	# # copy DICOM files to the bids directory
	# # this is just to ensure we are operating on copies of the originals
	# # for each subject, they will be copied into: /studydir/bids/sub-01/dicom
	# for s in range(len(subject_dirs)):
	# 	if not os.path.exists(dirpath+'/bids/'+new_subject_dirs[s]+'/dicom'):
	# 		copyDir(dirpath+'/'+subject_dirs[s]+'/dicom',dirpath+'/bids/'+new_subject_dirs[s]+'/dicom')
	
	# convert everything to .nii.gz 
	if flag=='inter':
		convFlag=askConvert()
		# if convFlag == 0:
		# 	return # end convert_to_BIDS
	elif flag == 'auto':
		print('[AUTO MODE] Beginning DICOM file conversion...')
		cmd1='module load matlab/2015a'
		os.system(cmd1)
		for s in range(len(new_subject_dirs)):
			print('Running subject %s...' % str(s+1))
			cmd = "matlab -r -nodisplay 'run_dicm2nii '%s' '%s''" % (dirpath+'/'+subject_dirs[s]+'/dicom',
				dirpath+'/bids/'+new_subject_dirs[s]+'/func')
			# run_dicm2nii.m: essentially runs the below command, getting around issues w/passing data types
			# cmd = "matlab -r -nodisplay 'dicm2nii '%s' '%s' 1''" % (dirpath+'/bids/'+new_subject_dirs[s]+'/dicom',
			# 	dirpath+'/bids/'+new_subject_dirs[s]+'/func')
			# note: initially copies all nii.gz files to the /func subdirectory; 
			# anat files are moved later, and functional files separated into run subdirectories
			try:
				os.system(cmd)
				print('Done with subject %s.' % str(s+1))
			except OSError as e:
				print('There was a problem with your conversion. Error: %s' % e)
				return

	# remove some of the extra files
	print('Deleting unnecessary .nii.gz files (MoCo, RMS, AAScout)...')
	for s in range(len(new_subject_dirs)):
		moco=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,'*MoCo*.nii.gz')]
		rms=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,'*MEMPRAGE*RMS*.nii.gz')]
		aascout=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,'*AAScout*.nii.gz')]
		remove=moco+rms+aascout
		for f in remove:	
			print(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+f)
			os.remove(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+f)
	print('All unnecessary files removed.') 

	# move the anatomical files to anat directory
	print('Moving anatomical files to anat directory...')
	for s in range(len(new_subject_dirs)):
		if not os.path.exists(dirpath+'/bids/'+new_subject_dirs[s]+'/anat'):
			print('Creating anatomical subfolder...')
			os.makedirs(dirpath+'/bids/'+new_subject_dirs[s]+'/anat')
		anat=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,'*MPRAGE*.nii.gz')]
		if len(anat)==1: #there should only be one structural file
			shutil.move(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+anat[0],dirpath+'/bids/'+new_subject_dirs[s]+'/anat')
		elif len(anat)==0: print('Warning: No MEMPRAGE .nii.gz files found.')
		else:
			print('Too many MEMPRAGE files! Unable to move anatomical file. Quitting.') 
			return

	if flag=='inter':
		dcmYes=raw_input('Do you want to convert your dcmHeaders now? (y/n)')
		if dcmYes=='y':
			# grab metadata and put into JSON files
			print('Grabbing metadata from dcmHeaders.mat file...')
			for s in range(len(new_subject_dirs)):
				# elaborate the structure within dcmHeaders.mat into multiple files
				cmd = "matlab -nosplash -nodisplay -r 'process_dcmHeaders '%s''" % (dirpath+'/bids/'+new_subject_dirs[s]+'/func/')
				os.system(cmd)
				# convert the .mat files into JSON files
				dicom2JSON(dirpath+'/bids/'+new_subject_dirs[s]+'/func/',tsks+['MPRAGE'])

	if flag=='inter':
		moveYes=raw_input('Do you want to move your files now? (y/n)')
		if moveYes=='y':
	# rename files in accordance with BIDS standard
			print('Renaming files...')
			for s in range(len(new_subject_dirs)):
				anat=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/anat') if fnmatch.fnmatch(f,'*.nii.gz')]
				if len(anat)==1:
					newname=new_subject_dirs[s]+'_T1w.nii.gz'
					os.rename(dirpath+'/bids/'+new_subject_dirs[s]+'/anat/'+anat[0],dirpath+'/bids/'+new_subject_dirs[s]+'/anat/'+newname)
				elif len(anat)>1:
					print('Too many anatomical files! Skipping renaming.')
				anat=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,'*MPRAGE*.json')]
				if len(anat)==1:
					newname=new_subject_dirs[s]+'_T1w.json'
					shutil.move(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+anat[0],dirpath+'/bids/'+new_subject_dirs[s]+'/anat/'+newname)
				elif len(anat)>1:
					print('Too many anatomical files! Skipping renaming.')

				# rename each task
				for t in tsks:
					boldfiles=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,('*%s*.nii.gz' % t))]
					for i in range(len(boldfiles)):
						newname=new_subject_dirs[s]+'_task-'+t.lower()+'_run-'+str(i+1).zfill(2)+'_bold.nii.gz' # note t.lower()
						os.rename(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+boldfiles[i],dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+newname)
					boldjson=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,('*%s*.json' % t))]
					for i in range(len(boldjson)):
						newname=new_subject_dirs[s]+'_task-'+t.lower()+'_run-'+str(i+1).zfill(2)+'_bold.json'
						os.rename(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+boldjson[i],dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+newname)

			print('Moving functional files to func subdirectories...')
			for s in range(len(new_subject_dirs)):
				for t in tsks:
					# how many runs are there?
					# get list of all functional files for this task:
					func0=[x for x in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(x,'*'+t.lower()+'*_bold.nii.gz')]
					jfiles=[x for x in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(x,'*'+t.lower()+'*_bold.json')]
					numruns=len(func0)
					if len(func0)==0: 
						print('WARNING: No .nii.gz files exist for this task.')
					for f in range(numruns):
						thisfile=new_subject_dirs[s]+'_task-'+t.lower()+'_run-'+str(f+1).zfill(2)
						try:
							func=func0[f]
							jfile=jfiles[f]
							if not os.path.exists(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+thisfile):
								os.makedirs(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+thisfile)
							shutil.move(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+func,dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+thisfile)
							shutil.move(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+jfile,dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+thisfile)
						except: print('Some error occurred while moving functional files. Continuing...')
	# CONVERTING BEHAVIORAL DATA INTO TSV FILES

	# for each task, grab info from behavioral .mat files
	# these will be saved like so: sub-01_task-DIS_run-01_events.tsv
	# columns include by default: 'onset', 'duration', 'condition', 'item', 'key', 'RT'
	# each row corresponds to an event
	if flag=='inter':
		askBehav=raw_input('Do you want to convert your behavioral files? (y/n)')
		if askBehav=='y':
			for s in range(len(new_subject_dirs)):
				for t in tsks:
					srch=subject_dirs[s]+'.*'+t+'*.*.mat'
					tskfiles=[f for f in os.listdir(dirpath+'/behavioural') if fnmatch.fnmatch(f.lower(),srch.lower())]
					for f in range(len(tskfiles)):
						fname = new_subject_dirs[s]+'_task-'+t.lower()+'_run-'+str(f+1).zfill(2)
						behav2TSV(dirpath+'/behavioural/'+tskfiles[f],
							dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+fname,
							fname+'_events.tsv')
				# shutil.move(fname+'_events.tsv',dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+fname+'/'+fname+'_events.tsv')

	# CLEANLINESS CHECK 

	print('Running checks...')
	for s in range(len(new_subject_dirs)):
		anat_bad = 0
		func_bad = 0
		anatdir=dirpath+'/bids/'+new_subject_dirs[s]+'/anat/'
		if not os.path.isfile(anatdir+new_subject_dirs[s]+'_T1w.json') or not os.path.isfile(anatdir+new_subject_dirs[s]+'_T1w.nii.gz'):
			anat_bad=1
		funcdir=dirpath+'/bids/'+new_subject_dirs[s]+'/func/'
		for _,subdirs,_ in os.walk(funcdir):
			sub=subdirs #get list of subdirs one level down
			break
		for this_dir in range(len(sub)):
			if len(os.listdir(funcdir+sub[this_dir])) != 3:
				func_bad=1
		if anat_bad == 1:
			print(new_subject_dirs[s] + ': Problem with anatomical files.')
		elif func_bad == 1:
			print(new_subject_dirs[s] + ': Problem with functional files.')
		else:
			print(new_subject_dirs[s] + ': File check completed with no issues.')


	# CLEANING UP

	if flag == 'inter':
		rmExtra=raw_input('Are you ready to delete your extra files? (y/n)')
		if rmExtra=='y':
			print('Deleting unused files...')
			for s in range(len(new_subject_dirs)):
				oldfile=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,'*.*')]
				for n in oldfile:
					os.remove(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+n)
		elif rmExtra=='n':
			print('Retaining extra files.')
	elif flag == 'auto':
		print('[AUTO MODE] Deleting extra files...')
		for s in range(len(new_subject_dirs)):
			oldfile=[f for f in os.listdir(dirpath+'/bids/'+new_subject_dirs[s]+'/func') if fnmatch.fnmatch(f,'*.*')]
			for n in oldfile:
				os.remove(dirpath+'/bids/'+new_subject_dirs[s]+'/func/'+n)
		print('All unnecessary files deleted.')

	if flag=='inter':
		askMove=raw_input('Are you ready to move your functional files? (y/n)')
		if askMove=='y':
			print('Moving functional files upwards...')
			for s in range(len(new_subject_dirs)):
				for _,subdirs,_ in os.walk(os.path.join(dirpath,'bids',new_subject_dirs[s],'func')):
					sub=subdirs #get list of subdirs one level down
					break
				for s2 in sub:
					# list all files in each subdir under /func
					funcfiles=os.listdir(os.path.join(dirpath,'bids',new_subject_dirs[s],'func',s2))
					for fl in funcfiles: #move them one by one
						shutil.move(os.path.join(dirpath,'bids',new_subject_dirs[s],'func',s2,fl),
							os.path.join(dirpath,'bids',new_subject_dirs[s],'func',fl)) #move all func files upward
					os.rmdir(os.path.join(dirpath,'bids',new_subject_dirs[s],'func',s2)) #remove subfolders
	print('Done!')
	return
# end function convert_to_BIDS

# make it possible to run with the command-line syntax:
# python convert_to_BIDS.py auto /path/to/study/dir 
if __name__ == "__main__":
	convert_to_BIDS(sys.argv)

