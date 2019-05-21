# -*- coding: utf-8 -*-
# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:
from __future__ import print_function, division, unicode_literals, absolute_import

import os
import numpy as np

from nipype.utils.filemanip import split_filename, fname_presuffix, filename_to_list, list_to_filename
from nipype.interfaces.base import TraitedSpec, isdefined, File, traits, OutputMultiPath, InputMultiPath
from nipype.interfaces.spm.base import SPMCommandInputSpec, SPMCommand, scans_for_fnames, scans_for_fname

class ResliceToFirstInputSpec(SPMCommandInputSpec):
    in_file = File(exists=True, mandatory=True,
                   desc='file to apply transform to, (only updates header)')
    interp = traits.Range(low=0, high=7, usedefault=True,
                          desc='degree of b-spline used for interpolation'
                          '0 is nearest neighbor (default)')

    out_file = File(desc='Optional file to save resliced volume')


class ResliceToFirstOutputSpec(TraitedSpec):
    out_file = File(exists=True, desc='resliced volume')

class ResliceToFirst(SPMCommand):
    """ uses  spm_reslice to resample in_file into space of first file in in_file"""

    input_spec = ResliceToFirstInputSpec
    output_spec = ResliceToFirstOutputSpec

    def _make_matlab_command(self, _):
        """ generates script"""
        if not isdefined(self.inputs.out_file):
            self.inputs.out_file = fname_presuffix(self.inputs.in_file,
                                                   prefix='r')
        script = """
        flags.mean = 0;
        flags.which = 1;
        flags.mask = 0;
        flags.interp = %d;
        infiles = strvcat(\'%s\');
        invols = spm_vol(infiles);
        spm_reslice(invols, flags);
        """ % (self.inputs.interp,
               self.inputs.in_file)
        return script

    def _list_outputs(self):
        outputs = self._outputs().get()
        outputs['out_file'] = os.path.abspath(self.inputs.out_file)
        return outputs
