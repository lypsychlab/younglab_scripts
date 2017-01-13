function test_rework_behavioral()
    srch='/Users/wass/Documents/code/DIS/behavioral/*DIS.test.mat';
    conds={'key','RT'};
    condcodes = {'cov','cov'};
    addpath(genpath('/Users/wass/Documents/code/matlab'));
    rework_behavioral(srch,conds,condcodes);
end