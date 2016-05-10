function percRetained = freqAnalyze_ieh(study, subj, task, filter, useDir)

% freqAnalyze produces statistics and plots of your experiment based on your
% frequency cutoff threshold for the high-pass filter. 
%
% INPUTS:
%		study		=> the folder name that contains the study (i.e., 'SAD')
%		subj		=> the subject name (i.e., SAX_sad_01)
%		task		=> task name (i.e., 'sad'). 
%		filter		=> the filtering frequency, in terms of secs / period.
%					   If not specified, will default to 128 secs / period. 
%		useDir		=> the directory to which results should be saved. This
%					   is an optional input, if included, it will cause the
%					   script will save the resulting figures to the
%					   directory specified and will not prompt you for new
%					   frequency thresholds, instead it will exit
%					   immediately.
%
% OUTPUTS:
%		Two plots are output per condition. The first is the frequency
%		spectogram, which returns the absolute power of the signal at a 
%		given frequency. The portion of this plot that is greyed out is
%		the signal that is attenuated by the high-pass filter. The second
%		plot is the amount of signal preserved as a function of filtering
%		frequency. Filtering frequency is the the x-axis, while the y-axis
%		is the amount of signal included. Again, the greyed portion  of the
%		graph indicates the high-pass filter.
%
%		The function also outputs a statistic indicating what percent of
%		the signal is still present after attenuation by the high-pass
%		filter. It is equivalent to the value of the line in the second
%		plot at the point where it is crossed by the grey vertical line
%		(which indicates the value of the high pass filter threshold). It
%		will prompt you to enter in new values for the filtering threshold
%		if you wish to see how your signal inclusion changes with more
%		conservative or liberal frequencies. Typing 'exit' (with no quotes)
%		into the prompt will cause the script to terminate. 
%
%		NPD 11/26/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is ripped from spm_fMRI_design_show.m, and is (in general) called by
% spm_DesRep. spm_fMRI_design_show is called with the following inputs: 
%
% - an SPM file
% - i, indicating the condition in question
% - s, indicating the session (run) in question
% 
%		Notes on the structures used:
%
%			- Sess.row		: indicies for each time-point / scan
%			- Sess.col		: indicies for each effect (i.e., condition)
%			- SPM.xX.X		: the design matrix
%			- SPM.xY.RT		: 
%			- Sess.Fc.i		: indicies for effect of interest (like
%							  Sess.col, but this must deal with some kind
%						      of edge case I'm not familiar with)
%			- sX			: function-specific parameter, consisting of 
%							  only the effect regressors (unecessary, since
%							  the code can only handle one-session and
%							  one-condition at a time).
%			- rX			: function-specific parameter, consisting of
%							  just the regressor of interest.  
%
% ********** Finding the frequency range
%		The discrete fourier transform can only interpolate signals whose
%		period is less than or equal to the length of the sampling time,
%		because any longer and you can't be certain when a given signal 
%		will complete a period. Further, it can't interpolate signals whose
%		period is less than the time between samples, for obvious reasons.
%		Therefore, it can get at signals whose period is between (num
%		samples)*(time between samples) and (time between samples). FFT
%		therefore returns a range of values equally spaced between those
%		two time points. The number of values between-and-including each
%		point is equal to the total number of samples (I'm not sure that
%		this is a mathematical restriction, but it appears to be). I'm also
%		not sure why it includes "zero" in the frequency domain. Maybe it
%		assigns all unknown power to the "zero" time point. Therefore, the
%		value at Hz(n) in this example corresponds to "The frequency of
%		signal that completed (n-1) cycles in (total samples) * (time
%		between samples). 
%
% ********** Finding the frequency range
%		The fourier transforms are for some reason spatially symmetric.
%		Therefore, you really only care about the low-frequency stuff
%		(which makes logical sense, considering how much longer our blocks
%		are than the 2-second TR). The value of "zero" is also omitted. I'm
%		still unclear as to why, presumably because it's value corresponds
%		to all frequencies < Hz(2) instead of a signal having an infinitely
%		long period. 

close all force;
if ~exist('filter','var')
    filter = 128;
end
% set variables. 
coF		= filter; 
curD	= pwd;
expDir	= '/younglab/studies/';
withSPM = 1;
SPM.RT = 2;
SPM.xBF.T = 128;
SPM.xBF.T0 = 1;
SPM.xBF.name = 'hrf';
SPM.xBF.UNITS = 'scans';
SPM.xBF.Volterra  = 1;
SPM.xBF.dt        = SPM.RT/SPM.xBF.T;
[xBF] = spm_get_bf(SPM.xBF);
% obtain behavioural files
cd([expDir study '/duration60secs_behavioral/']);
tT		= dir([subj '.' task '.*']);
[T{1:length(tT)}] = deal(tT(1:end).name);
load(T{1},'ips','spm_inputs');
SPM.nscan(1:length(T)) = ips;
for cond=1:length(spm_inputs)
    for run=1:length(T)
        cnd{cond}(run,1:ips) = zeros(1,ips);
		cndN{cond} = spm_inputs(cond).name;
    end
end

clear ips spm_inputs

% grab data 
for run=1:length(T)
    load(T{run},'spm_inputs');
    for cond=1:length(spm_inputs)    

        for inst=1:length(spm_inputs(cond).ons)
            cnd{cond}(run,spm_inputs(cond).ons(inst):spm_inputs(cond).ons(inst)+spm_inputs(cond).dur(inst)) = 1;
        end

		SPM.Sess(run).U(cond).ons    = spm_inputs(cond).ons - 1;  % onsets in scans. 
		SPM.Sess(run).U(cond).name   = {spm_inputs(cond).name};   % string from spm_inputs.name
		SPM.Sess(run).U(cond).dur    = spm_inputs(cond).dur;      % duration in scans from spm_inputs.dur
		SPM.Sess(run).U(cond).P.name = 'none';                    % 'none' | 'time' | 'other'
	end
	SPM.Sess(run).U= spm_get_ons(SPM,run);
	[SPM.R(run).X, SPM.R(run).Xname, SPM.R(run).Fc] = spm_Volterra(SPM.Sess(run).U,xBF.bf,SPM.xBF.Volterra);
    clear spm_inputs
end    

for k=1:length(cnd)
	for run=1:length(T)
		cndS(k).vals(run,:) = SPM.R(run).X(:,k);
	end
end

percRetained = [];
% perform fast fourier transform
for k=1:length(cnd)
	cndS(k).name = cndN{k};
	for run=1:length(T)
		gnX(run,:) = abs(fft(cndS(k).vals(run,:))).^2;
    end
    [gnXrow gnXcol] = size(gnX);
    if gnXrow > 1
        gX = sum(gnX);
    else
        gX = gnX;
    end
	gX = gX*diag(1./sum(gX)); 
	%temp = (abs(fft(detrend(cndS(k).vals).*hanning(size(cndS(k).vals,1))')));%,10*length(cndS(k).vals))).^2);
	%gX = temp(1:end/2)/(sum(abs(temp(1:end/2))));gX(1)=nan;
	q = length(gX);
	Hz = [0:(q-1)]/(SPM.nscan(1)*SPM.RT);
	q = 2:fix(q/(2*q/SPM.nscan(1)));
	cndS(k).Hz = Hz(q);
	cndS(k).gX = gX(q);
	qT = cumsum(cndS(k).gX(end:-1:1));
	rqT = 100*qT(end:-1:1)/sum(cndS(k).gX);
	cndS(k).rcS = rqT;					% rcS is the reverse cumulative sum. rcS(n) = signal power included if using a HPF of frequency n / (samples * sample time)
	%cndS(k).atR = sum(cndS(k).gX(cndS(k).Hz > (1 / coF)))/sum(cndS(k).gX)*100;					% percent of signal included at a given frequency.  
	cndS(k).atR = interp1(cndS(k).Hz, cndS(k).rcS, (1/coF));	% use linear interpolation instead. 
	percRetained = [percRetained cndS(k).atR];
end 

while 1
	for j=1:length(cnd)
        %cndS(j).atR = sum(cndS(j).gX(cndS(j).Hz > (1 / coF)))/sum(cndS(j).gX)*100;
		cndS(j).atR = interp1(cndS(j).Hz, cndS(j).rcS, (1/coF));
		if exist('useDir','var')
            set(0,'DefaultFigureVisible','off'); 
			figure(((j-1)*2)+1);
		else
			% calculate the size of the subplot if needed
			x = ceil(sqrt(length(cnd)));
			y = ceil(((length(cnd)*2)/ceil(sqrt(length(cnd))))/2)*2;
			subplot(x,y,(j*2)-1);
        end
        plot(cndS(j).Hz, cndS(j).gX);
        %semilogx(cndS(j).Hz, cndS(j).gX);
		xlabel('Frequency (Hz)')
		ylabel('relative spectral density')
		axis tight
		grid on
		h=title(sprintf('Frequency domain of subject %s,\ncondition %s, filter %3.0f,\nsignal retained at filter freq %.2f',strrep(subj,'_','\_'),strrep(cndS(j).name,'_','\_'),coF,cndS(j).atR));
        patch([0 1 1 0]/coF,[0 0 1 1]*max(max(cndS(j).gX)),[1 1 1]*.9,'facealpha',.5);
        if exist('useDir','var')
			figure(((j-1)*2)+2);
        else
			subplot(x,y,(j*2));
        end
        plot(cndS(j).Hz, cndS(j).rcS);
		%semilogx(cndS(j).Hz, cndS(j).rcS);
		xlabel('Frequency of High Pass Filter')
		ylabel('Percent of Signal Included')
		axis tight
		grid on
		h=title(sprintf('Signal attenuation profile subject %s,\ncondition %s, filter %3.0f,\nsignal retained at filter freq %.2f',strrep(subj,'_','\_'),strrep(cndS(j).name,'_','\_'),coF,cndS(j).atR));
		patch([0 1 1 0]/coF,[0 0 1 1]*100,[1 1 1]*.9,'facealpha',.5);
		fprintf('Percent of signal included subject %10s, condition %10s, given filter of %3.0f:\t%.2f\n',subj,cndS(j).name,coF,cndS(j).atR);
        if exist('useDir','var')
			backup = pwd; 
			cd(useDir);
			eval(['saveas(((j-1)*2)+1,' sprintf('''freq_dist_subj_%s_cond_%s.png'');',subj,cndS(j).name)]);
            eval(['saveas(((j-1)*2)+2,' sprintf('''freq_powersum_subj_%s_cond_%s.png'');',subj,cndS(j).name)]);
			cd(backup);
			close all force
		end
    end
	if exist('useDir','var')
		break;
	else
		coFt = input(sprintf('\nEnter a new filter frequency (type exit to exit):\t'),'s');
		if strcmp(coFt,'exit')
            close all force;
			break;
		else
			eval(sprintf('coF = %s;',coFt));
		end
	end
end
set(0,'DefaultFigureVisible','on');
cd(curD);
end