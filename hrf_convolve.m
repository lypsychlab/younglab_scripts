
function output = hrf_convolve(varargin)
% convolves a user-regressor (or any vector) with an HRF response. edit for
% more details.
%
% if running a subject with a TR ~=2, use optional flag to specify a
% correct SPM.mat file!

%start with input user regressor
input = varargin{1};

if nargin==1
    % HRF taken from current studies, hard-coded in saxelab_model_bch_spm8.
    HRF = [0 0.0054 0.0234 0.0241 0.0135  0.0048  0.0001 -0.0019 -0.0023 -0.0019 -0.0013 -0.0007 -0.0004  -0.0002 -0.0001 0 0]';
else
    % if there is a flag, let them specify an SPM.mat file from which to
    % grab the HRF response
    spmfile = spm_select(1,'mat','Choose an example SPM.mat file to load an HRF function','','/home/younglw/','.*',1);
    load(spmfile);
    HRF = SPM.xBF.bf(1:SPM.xBF.T:end);
end

% convolve with HRF
output = conv(input, HRF);

% Crop to length of input (convolution will sometimes lengthen the vector)
output = output(1:length(input));

end