#!/usr/bin/python

import sys
import getopt
import nibabel as nib
import numpy
import scipy

# params is the dictionary holding all needed parameters for the script
# think about adding an -m option for introducing a mask
params = {
    'nii_filename': "",
    'start_slice': 0,
    'end_slice': None,
    'alternate_slice': 1,
    'plane': "ax",
    'output_prefix': "img",
    'format': "png",
    'verbose': False
}


def parse_params(argv, params):
    if not argv:
        print_help()
        sys.exit(0)

    try:
        short_opts = "s:e:a:p:o:f:vh"
        long_opts = ["start_slice=", "end_slice=", "alternate_slice=", "plane=", "output_prefix=", "format=", "verbose", "help"]
        opts, args = getopt.getopt(argv, short_opts, long_opts)
        if len(args) == 1:
            params['nii_filename'] = args[0]
        elif len(args) > 1:
            raise

    except:
        print "Error! Invalid option(s)."
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-s", "--start_slice"):
            params['start_slice'] = int(arg)
        elif opt in ("-e", "--end_slice"):
            params['end_slice'] = int(arg)
        elif opt in ("-a", "--alternate_slice"):
            params['alternate_slice'] = int(arg)
        elif opt in ("-p", "--plane'"):
            params['plane'] = arg
        elif opt in ("-o", "--output_prefix"):
            params['output_prefix'] = arg
        elif opt in ("-v", "--verbose"):
            params['verbose'] = True
        elif opt in ("-f", "--format"):
            params['format'] = arg
        elif opt in ("-h", "--help"):
            print_help()
            sys.exit(0)


def print_help():
    print ""
    print "nii2img.py [OPTION] [NIFTI_INPUT_FILE]"
    print "The NIFTI_INPUT_FILE must be in LAS orientation!"
    print "Available command line options:"
    print "-s, --start_slice"
    print "-e, --end_slice"
    print "-a, --alternate_slice"
    print "-p, --plane : extract images in axial (ax), coronar (cor) or sagittal (sag) plane"
    print "-o, --output_prefix"
    print "-f, --format : output format (png by default); png, jpg, bmp"
    print "-v, --verbose"
    print "-h, --help"
    print ""


# load nifti file according to parameters above
def load_nii(params):
    if not params['nii_filename']:
        print "Error! Missing NIFTI input file."
        sys.exit(2)

    if params['verbose']:
        print "Loading NIfTI file"

    img = nib.load(params['nii_filename'])
    data = img.get_data()
    return data


# normalize the color value range in the original nii image
def normalize_nii(params, data):
    if params['verbose']:
        print "Normalizing intensities"


# extract the images from the file you wish to continue with, alternation, start and end slice
def extract_img(params, data):
    if params['verbose']:
        print "Extracting images"

    image_counter = 0
    slice_counter = 0
    start_slice = params['start_slice'] or 0
    start_slice = start_slice - 1 if start_slice > 0 else start_slice
    end_slice = params['end_slice'] or data.shape[2]
    for i in range(start_slice, end_slice):
        if (slice_counter % params['alternate_slice']) == 0:
            if params['plane'] == "ax":
                slice = data[:, :, i]
            elif params['plane'] == "cor":
                slice = data[:, i, :]
            elif params['plane'] == "sag":
                slice = data[i, :, :]

            slice = numpy.rot90(slice)

            image_name = params['output_prefix'] + str(image_counter) + "." + params['format']
            scipy.misc.imsave(image_name, slice)
            image_counter += 1
            if params['verbose']:
                sys.stdout.write(".")
                sys.stdout.flush()
        slice_counter += 1

    if params['verbose']:
        print ""


if __name__ == '__main__':
    parse_params(sys.argv[1:], params)
    data = load_nii(params)
    normalize_nii(params, data)
    extract_img(params, data)
    if params['verbose']:
        print "Finished"