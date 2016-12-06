rois={'RTPJ' 'DMPFC' 'LSTS' 'RSTS' 'LTPJ' 'MPFC' 'PC'};
ieh_itemwise_data_imcalc(rois,1);

rois={'Parahipp_R_Andrews' 'Parahipp_L' 'Hipp_R' 'Hipp_L' 'pIPL_L' 'pIPL_R' 'vMPFC_Andrews' 'Retrosplenial_R' 'Retrosplenial_L' 'TPJ_R' 'TPJ_L' 'conjVMPFC'}
ieh_itemwise_data_imcalc(rois,0);

% full list of rois:
% {'RTPJ' 'DMPFC' 'LSTS' 'RSTS' 'LTPJ' 'MPFC' 'PC' 'Parahipp_R_Andrews' 'Parahipp_L' 'Hipp_R' 'Hipp_L' 'pIPL_L' 'pIPL_R' 'vMPFC_Andrews' 'Retrosplenial_R' 'Retrosplenial_L' 'TPJ_R' 'TPJ_L' 'conjVMPFC'};

% sanity check:
% rois={'Parahipp_L'};
% ieh_itemwise_data_imcalc(rois,1);