import sys, os, shutil, mat4py

def clean_behaviorals(*argu):
	"""
	Short script for cleaning behavioral directory in advance of running analyses. Removes .mat files 
	corresponding to any behavioral runs that are missing an spm_input field. Before deleting these files,
	script creates a new directory labelled "behavioral_archive" into which all original behavioral files are copied. 


	Arguments:
	[1]: Full path to study directory 

	"""
	argu=argu[0]


	#Move to study directory
	os.chdir(argu[1])

	#rename behavioral folder "behavioral archive". From here on out, we will not touch this folder, except to copy files out of
	#it and into a new behavioral folder.
	os.rename('behavioral', 'behavioral_archive')

	#create folder labelled "behavioral_archive"

	os.mkdir('behavioral')

	#Copy files from behavioral_archive folder, move copied files into new behavioral folder
	for behavfiles in os.listdir(os.path.join(argu[1], 'behavioral_archive')):
		print(behavfiles)
		shutil.copy(os.path.join('behavioral_archive', behavfiles), os.path.join(argu[1], 'behavioral'))
		
	for behavfiles in os.listdir(os.path.join(argu[1],'behavioral')):
		#check if each matfile contains spm_inputs field
		matfile = mat4py.loadmat(os.path.join('behavioral', behavfiles))
		if 'spm_inputs' not in matfile.keys(): 
			print("removing file: " + behavfiles)
			os.remove(os.path.join('behavioral', behavfiles))


if __name__ == "__main__":
	clean_behaviorals(sys.argv)



