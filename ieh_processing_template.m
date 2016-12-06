younglab_dicom_convert_7('IEHTMSFMRI','YOU_IEHTMSFMRI_104');
younglab_preproc_temporal_spm12('IEHTMSFMRI','YOU_IEHTMSFMRI_104');
younglab_preproc_spatial_spm12('IEHTMSFMRI','YOU_IEHTMSFMRI_104');%add 5 for unnormed
younglab_model_spm8_ieh_MAISEY('IEHTMSFMRI','YOU_IEHTMSFMRI_101','tom_localizer',[9 11],'unnormed','clobber'); %add 'unnormed' for unnormed