def grabDicom(rtdir,subs):
	import os, shutil
	os.mkdir(os.path.join(rtdir,'extra_dicoms'))
	for s in subs:
		thissub='SAX_DIS_' + str(s).zfill(2)
		dcm_list=os.listdir(os.path.join(rtdir,thissub,'dicom'))
		shutil.copyfile(os.path.join(rtdir,thissub,'dicom',dcm_list[0]),
			os.path.join(rtdir,'extra_dicoms',thissub+'.dcm'))
