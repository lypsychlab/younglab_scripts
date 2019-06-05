"""
Kevin Jiang
last updated: 6/4/19
copies functionality of pre_dcm2bids_formatter.csh into python script
maintains use of cp -an for safe copy that won't overwrite files
recommended to specify source/dest as named parameters when calling function
Can be run using pbs script to process subjects in parallel!
"""

import os, subprocess, sys, argparse

def pre_dcm2bids_formatter(source, dest, study_name, subnums):
    """
    copy dicoms into pre-dcm2bids format 
    for use on sirius cluster only
    :param source: str
    :param dest: str
    :param study_name: list (ints)
    :param subnums: list (ints)
    :return:
    """
    path_to_parent = "/data/younglw/lab"
    
    print(os.getcwd())
    print(os.path.abspath(os.getcwd()))
    print("The dir contains: {}".format(os.listdir(path_to_parent)))

    #note: os.mkdir will throw error if folder already exists
    try:
        os.mkdir(os.path.join(path_to_parent,dest))
    except FileExistsError:
        print("Warning, FileExistsError, continuing w/o creating directory: {}".format(os.path.join(path_to_parent,dest)))

    try:
        os.mkdir(os.path.join(path_to_parent,dest,"mydicoms"))
    except FileExistsError:
        print("Warning, FileExistsError, continuing w/o creating directory: {}".format(os.path.join(path_to_parent,dest,"mydicoms")))
    
    for n in subnums:
        subj_name = "YOU_{}_{:02d}".format(study_name, n)

        try:
            os.mkdir(os.path.join(path_to_parent,dest,"mydicoms", subj_name))
        except FileExistsError:
            print("Warning, FileExistsError (continuing w/o creating directory): {}".format(os.path.join(path_to_parent,dest,"mydicoms", subj_name)))
        try:
            os.mkdir(os.path.join(path_to_parent,dest,"mydicoms", subj_name, "dicom"))
        except FileExistsError:
            print("Warning, FileExistsError (continuing w/o creating directory): {}".format(os.path.join(path_to_parent,dest,"mydicoms", subj_name, "dicom")))

        zfrom = os.path.join(path_to_parent, source, subj_name, "dicom")
        zto = os.path.join(path_to_parent, dest, "mydicoms", subj_name)

        # calling a safe copy (using unix cp -n: which PREVENTS CLOBBERING!)
        print('copying: {} -> {}'.format(zfrom, zto))
        subprocess.check_output(["cp", "-an", zfrom, zto])

def create_sub_dirs_w_results(study_folder, study_name, subnums):
    '''
    :param study_folder: string
        (e.g, 'FT_FMRIPREP')
    :param study_name: string
        (e.g., 'FIRSTTHIRD')
    :param subnums: list (int)
        (e.g., list(range(1,20))
    :return:
    '''

    path_to_parent = os.path.join('/data/younglw/lab', study_folder)

    #note: os.mkdir will throw error if folder already exists
    try:
        os.mkdir(os.path.join(path_to_parent))  # create study folder if doesn't already exist
    except FileExistsError:
        print("Warning, FileExistsError, continuing w/o creating study folder: {}".format(os.path.join(path_to_parent)))

    sub_dirs = ['YOU_{}_{:02d}'.format(study_name,x) for x in subnums]
    
    print(os.getcwd())
    print(os.path.abspath(os.getcwd()))
    print("The dir contains: {}".format(os.listdir(path_to_parent)))
    
    for s in sub_dirs:
        sub_dir = os.path.join(path_to_parent, s)
        sub_results_dir = os.path.join(sub_dir, 'results') 
        sub_roi_dir = os.path.join(sub_dir, 'roi') 
        try_mkdir(sub_dir)
        try_mkdir(sub_results_dir)
        try_mkdir(sub_roi_dir)

def try_mkdir(direc):
    '''
    tries to use os.mkdir to create direc
    except FileExistsError, prints out warning and does nothing
    '''
    try:
        os.mkdir(direc)
        print('created directory: {}'.format(direc))
    except FileExistsError:
        print('Warning, FileExistsError: {}, no directory created'.format(direc))

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Pre dcm2bids formatter (copies dicom files)')

    parser.add_argument('--source', default='',
                        help='source study directory')

    parser.add_argument('--dest', default='',
                        help='destination study directory (make sure this is empty!)')

    parser.add_argument('--subnum', default=[],
                        help='subject number to copy')

    parser.add_argument('--studyname', default='',
                        help="study acronym used to name subjects e.g., 'TPS' from YOU_TPS_04")

    parser.add_argument('--sublist', default=[],
                        help="Not yet implemented: list of subject numbers to copy (e.g., '[1,2,4]' <-- note single quotes surrounding list!)")

    # Parse command line arguments
    args = parser.parse_args()
    source = args.source
    dest = args.dest
    studyname = args.studyname
    subnum = int(args.subnum)

    # creates folder w/ results and roi directory for modeling (necessary later)
    create_sub_dirs_w_results(study_folder=dest, study_name=studyname, subnums=[subnum])

    # copies dicom into pre_dcm2bids format
    pre_dcm2bids_formatter(source=source, dest=dest, study_name=studyname, subnums=[subnum])

if __name__ == '__main__':
    main()
