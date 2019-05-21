parameters.rootdir  = '/home/younglw/lab';
parameters.study  = 'TRAG';
parameters.subjects = [3 4 5 6 7 8 9 10 11 12 13 14 15 16 19 20 21 22 23 24 25 26 27 28 29];
parameters.prefix = 'YOU_TRAG';
parameters.tagnames = {'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006'};
parameters.imagetype  = 'img';
parameters.resdir = 'FPMLocal_CombinedDOA_results_normed';
parameters.imageprefix = '';
parameters.numiterations = 5000;
parameters.sign = 1;
parameters.voxthresh = .001;
parameters.cluthresh  = .05;
parameters.threshtype = 2;

save('params_snpm_jordan.mat', 'parameters')