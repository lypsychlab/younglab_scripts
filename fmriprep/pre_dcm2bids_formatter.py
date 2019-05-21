"""
Kevin Jiang
5/3/19
copies functionality of pre_dcm2bids_formatter.csh into python script
maintains use of cp -an for safe copy that will not overwrite files
recommended to specify source/dest as named parameters when calling function
Can be run using pbs script to process subjects in parallel!
"""

import os, subprocess, sys, argparse

def pre_dcm2bids_formatter(source, dest, subj_nums):
    """
    copy dicoms into pre-dcm2bids format 
    for use on sirius cluster only
    :param source: str
    :param dest: str
    :param subj_nums: list (ints)
    :return:
    """
    path_to_parent = "/data/younglw/lab"
    
    print(os.getcwd())
    print(os.path.abspath(os.getcwd()))
    print("The dir contains: {}".format(os.listdir(path_to_parent)))

    #note: os.mkdir will throw error if folder already exists
    try:
        os.mkdir(os.path.join(path_to_parent,dest,"mydicoms"))
    except FileExistsError:
        print("Warning, FileExistsError (continuing w/o creating directory): {}".format(os.path.join(path_to_parent,dest,"mydicoms")))
    
    for n in subj_nums:
        subj_name = "YOU_{}_{:02d}".format(source, n)  # assumes subject's study name maintained from source

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

        # calling a safe copy (-n PREVENTS CLOBBERING!)
        print('copying: {} -> {}'.format(zfrom, zto))
        subprocess.check_output(["cp", "-an", zfrom, zto])
        

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Pre dcm2bids formatter (copies dicom files)')

    parser.add_argument('--source', default='',
                        help='source study directory')

    parser.add_argument('--dest', default='',
                        help='destination study directory (make sure this is empty!)')

    parser.add_argument('--subnum', default=[],
                        help='subject number to copy')

    parser.add_argument('--sublist', default=[],
                        help="Not yet implemented: list of subject numbers to copy (e.g., '[1,2,4]' <-- note single quotes surrounding list!)")

    # Parse command line arguments
    args = parser.parse_args()
    source = args.source
    dest = args.dest
    subnum = int(args.subnum)

    pre_dcm2bids_formatter(source=source, dest=dest, subj_nums=[subnum])

if __name__ == '__main__':
    main()




