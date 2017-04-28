function so_localizer(subjID,confed,acq,state_type,cond_iter)
% E.G., so_localizer('YOU_FIRSTTHIRD_01','grace',1,'either',0)
% 
% subjID: string indicating subject ID code
% confed: string indicating the name of the confederate
% acq: acquisition number
% state_type: type of stimuli to present 
% cond_iter: the number of previous acquisitions of this state type
% 
% Self-other localization task based on Jenkins & Mitchell (2011)
% Stimuli courtesy of Adrianna Jenkins
% 
% Stimuli consist of (i) mental-state words ('state')
% and (ii) words that can describe either a state or trait ('either')
% 
% Assumes directory structure:
% /so_localizer
%   so_localizer.m
%   so_localizer_stimuli.mat
%   /images
%       /confederates
%           confed_image.png
%       /participants
%           partic_image.png
%   /behavioral
% 
% 
% First written Emily Wasserman (April 2017)
% Last edited Emily Wasserman (April 2017)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if you are just testing on your laptop with no external monitor, uncomment:
Screen('Preference', 'SkipSyncTests', 1);
%% Init info
rootdir   = fileparts(which(mfilename)); % code directory path
behavDir  = fullfile(rootdir,'behavioral');

wrap      = 55;  %  new line of big font after this many characters
wrap_sm   = 70;  %  new line of small font after this many characters
big       = 35;  %  big font size
small     = 25;  %  small font size
trialtime = 14;  %  does not include jitter times

% WORD: 4s
% ISI: 2s
% END OF RUN: 10s
% EXPERIMENT DURATION: 6s x 40 trials + 10s = 250s
trial_length = 4;
ips       = ((trial_length+2)*40)/2 + 5; % 125

rand('twister',GetSecs);% generate a new pseudorandom sequence

cd(behavDir);

try % after first run, load the same sequence
    load([subjID '.so_localizer.1.mat'],'design_randomization','condition_randomization');
catch % first run
    design_randomization = []; condition_randomization = zeros(4,40);
    for j=1:4
        des_rand = Shuffle([1:40]);
        design_randomization=[design_randomization;des_rand];
    end
    for j=[1 3] % ensure that words are shown once in each condition to the participant
        cond_rand = Shuffle([repmat(1,1,20) repmat(2,1,20)]);
        condition_randomization(j,:)=cond_rand;
        x=zeros(1,40);
        x(cond_rand==1)=2;
        x(cond_rand==2)=1;
        condition_randomization(j+1,:)=x;
    end
end
save([subjID '.so_localizer.' num2str(acq) '.mat'],'design_randomization','condition_randomization');

RT         =  zeros(40,1); %RT for judgment
key        =  zeros(40,1); %keypress for judgment
onsets     =  zeros(40,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD STIMULI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STIMULUS FILE CONTAINS:
% instructions (cell): 2x1 cell of instructions (for self and other)
% words (cell): 40 x 2 cell of state words
load(fullfile(rootdir,'so_localizer_stimuli.mat')); 

% choose the vector of randomized values
design_run = design_randomization(acq,:);
if strcmp(state_type,'state')
    statecol=1;
else if strcmp(state_type,'either')
    statecol=2;
else
    disp('Please type ''either'' or ''state'' as the 4th parameter. Quitting.');
    return
end
end
cond_run = condition_randomization(statecol+cond_iter,:);

words_run=cell(40,1);
for i = 1:40
    words_run{i}=words{i,statecol};
end

words_run=words_run(design_run); % randomize the words
target_image = cell(2,1);
target_image{1}=fullfile(rootdir,'images','participants',[subjID '.png']); % self image
target_image{2}=fullfile(rootdir,'images','confederates',[confed '.png']); % other image
target_image{1}=imread(target_image{1},'BackgroundColor',[0 0 0]);
target_image{2}=imread(target_image{2},'BackgroundColor',[0 0 0]);

save([subjID '.so_localizer.' num2str(acq) '.mat'],'ips','design_run','words_run',...
        'acq','subjID','state_type','cond_run','-append');

% make sure these are 600x400
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PTB Stuff

devices=PsychHID('devices');   
[dev_names{1:length(devices)}]=deal(devices.usageName);
kbd_devs = find(ismember(dev_names, 'Keyboard')==1);

HideCursor;
displays   = Screen('screens');
screenRect = Screen('rect', displays(end)); %
[x0,y0]    = RectCenter(screenRect); %sets Center for screenRect (x,y)
    
[s sRect]      = Screen('OpenWindow', displays(end),[0 0 0], screenRect, 32);
[x0 y0]     = RectCenter(sRect);
%% Instructions and Trigger
Screen(s,'TextSize',big);

DrawFormattedText(s,instructions{1},'center','center',255,wrap);
Screen('Flip',s);

while 1  % wait for the 1st trigger pulse
    FlushEvents;
    trig = GetChar;
    if trig == '+'
        break
    end
end
Screen('Flip',s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0 = GetSecs; % used to time duration of experiment

for trial = 1:40
    
    trialStart = GetSecs; % start of trial
    
     %This is to prevent the continuous trigger at MIT from messing up
    %button press collection
    olddisabledkeys = DisableKeysForKbCheck(['+']);

    % present word/picture and get judgment:
    Screen(s,'TextSize',80);
    Screen('FillRect',s,[0 0 0], screenRect);
    DrawFormattedText(s,[words_run{trial} '?'],'center',y0+450,255,wrap); 
    im_draw=Screen('MakeTexture',s, ...
        target_image{cond_run(trial)});
    Screen('DrawTexture',s,im_draw);
    onsets(trial) = GetSecs - t0;
    Screen('Flip',s); 
    response_t = GetSecs;
    
    % collect responses - gives 4 seconds to respond
    while (GetSecs - response_t) < 4;
        [keyIsDown timeSecs keyCode] = KbCheck(-1);       
       % 30:33 (right hand: index, middle, ring, pinky)
       % 46 is trigger
       % to find out what value corresponds to what key, type this on the
       % command window:
       % WaitSecs(0.1); [a b] = KbWait; find(b==1)
        [button number]         = intersect(30:33, find(keyCode));
        if RT(trial)   == 0 & number > 0
            RT(trial) = GetSecs - response_t;
            key(trial) = number;
        end
    end
    
   % % take question off screen:
    Screen('Flip',s);

   %  % collect trial duration
    trial_dur(trial) = GetSecs - trialStart;
    
    %post-trial jitter:
    if trial<40
        pause(2);    
    else
        DrawFormattedText(s,'+','center','center',255,wrap_sm);
        Screen('Flip',s);
        pause(10);
    end
    
    save([subjID '.so_localizer.' num2str(acq) '.mat'],'RT','key',...
        'onsets','trial_dur','-append');
    
    % while GetSecs - trialStart < trialtime;end
    
end

experimentDur = GetSecs - t0;

%% Analysis Info

condnames={'self' 'other'};

con_info(1).name='self > other';
con_info(1).vals=[1 -1];
con_info(2).name='other > self';
con_info(2).vals=[-1 1];

%set up spm_inputs 
for design_ind = 1:2;    
    spm_inputs(design_ind).name = condnames{design_ind};
    try
      spm_inputs(design_ind).ons  = onsets(find(cond_run==design_ind));
      spm_inputs(design_ind).dur  = repmat(trial_length,length(spm_inputs(design_ind).ons),1);
    catch
      spm_inputs(design_ind).ons = NaN;
      spm_inputs(design_ind).dur  = NaN;
    end
    % total time a stimulus is on the screen, for one trial, in scans
end

%% Saves data

cd(behavDir);

%saves full set of variables in behavioral dir 
save([subjID '.so_localizer.' num2str(acq) '.mat'],'spm_inputs','experimentDur','con_info','-append'); 

clear spm_inputs;

cd ..

ShowCursor; Screen('CloseAll');

clear all;

end %ends main function
