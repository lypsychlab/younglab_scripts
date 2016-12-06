
addpath(genpath('/home/younglw/scripts'));
ROOT='/home/younglw/server/englewood/mnt/englewood/data';
STUDY='PSYCH-PHYS';
SUBJTAG='SAX_DIS';
RESDIR='DIS_results_itemwise_normed';
SUBNUMS=[3];
CONDS=[1:48];
SPH=3;
BIN={'hother_scale' 'hself_scale'};
OUTTAG='_maiseyTest';

searchlight_all_regress_training_finished(ROOT,STUDY,SUBJTAG,RESDIR,SUBNUMS,CONDS,SPH,BIN,OUTTAG)