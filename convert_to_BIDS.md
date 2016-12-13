# convert\_to\_BIDS.py

### Dependencies

Python 3 installation  
(Python) json, os, sys, shutil, fnmatch, csv, mat4py  
(Matlab) dicm2nii.m, run\_dicm2nii.m (custom script), process\_dcmHeaders.m (custom script)

### Arguments
```python3.5 convert_to_BIDS.py [flag] [dirPath]```

flag:

- auto (for attempt at automatic BIDS conversion without extra user input)

- inter (for interactive version; will prompt user to continue at each stage of conversion)

dirPath: the full path to your study directory

### Usage example

From the terminal:
```python3.5 convert_to_BIDS.py inter /home/younglw/lab/PSYCH-PHYS```

### Details

convert\_to\_BIDS is a Python 3 script that will attempt to convert a Younglab-style dataset into BIDS format (1.1).
This is necessary before uploading a dataset to OpenFMRI.

Steps involved in the conversion include:

1. Creating JSON/TSV files to hold experiment/participant information (dataset\_description.json, participants.tsv)
2. Creating new directories that match the BIDS file structure specification, under a /bids subdir within the study dir
3. Converting DICOMS to zipped NIFTI (.nii.gz) format, and dcmHeaders.mat to JSON
4. Renaming and moving NIFTI files
5. Converting behavioral .mat files to JSON files
6. Running checks on the final dataset
7. Deleting unnecessary files

When running the script with the inter flag, the user will be prompted to give y/n approval at checkpoints in the script.
If the user types 'n', the script will skip that step.
This is useful if you need to run the script multiple times on a dataset, e.g., if you have successfully converted your DICOM files
but have encountered errors with the behavioral file conversion.

Blocks associated with checkpoints include:

1. DICOM to NIFTI file conversion
2. dcmHeaders.mat file conversion
3. Moving/renaming of .nii.gz files
4. Behavioral .mat to JSON file conversion
5. Moving functional files (again)
6. Deleting extra files

DICOM file conversion is easily the most time-intensive step.
If DICOM file conversion has already been accomplished, future runs of the script should be run interactively, and the user should 
respond 'n' when asked to convert the DICOM files, in order to skip this step.

convert\_to\_BIDS relies on some standard Python libraries, as well as mat4py, which is third-party.
It also requires dicm2nii, another third-party program, and two custom Younglab Matlab scripts.
This environment should already be set up on Pleiades. mat4py and dicm2nii are easily downloadable from the Internet.
