import os, shutil, sys, re

def move_dicoms(*argu):
	# get the command-line arguments
	argu=argu[0]
	rootdir = argu[1]
	subj = argu[2]
	os.chdir(os.path.join(rootdir,subj))
	# create the dicom directory under the subj directory
	if not os.path.exists('dicom'):
		os.mkdir('dicom')
	drs = os.listdir('.')
	# get the dirs starting with YOUNG_
	nested = list([x for x in drs if re.match('YOUNG_',x)])
	# if there is one, go into it
	if len(nested)==1:
		os.chdir(nested[0])
		subdirs = os.listdir('.')
		for s in subdirs:
			try:
				os.chdir(s) # go into the subdir
				for dr, subdr, files in os.walk('.',topdown=False):
					for thisfile in files:
					# move the files upward
						shutil.move(thisfile,'..')
					os.chdir('..') # go back up
					os.rmdir(s) # remove the empty subdir
			except: pass


if __name__ == "__main__":
	move_dicoms(sys.argv)
