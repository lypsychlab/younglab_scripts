function XPECT(subjID,acq,cond)
% E.G., XPECT('YOU_XPECT_01',1,0)
%
%
% cond       = crossbalancing operator (0 or 1); 1 = inverted expectancy outcomes 
% items      = 1x60 vector of items (1 through 60) across 5 runs
% items_run  = 1x12 vector of items for THIS run
% design     = 1x60 vector of conditions (1:3) used in across 5 runs
% design_run = 1x3 vector of conditions (1:3) used for THIS run
% RT         = 1x12 vector of reaction times for each run
% key        = 1x12 vector of user responses. 1=first choice, 4=last choice

%% Init info
rootdir   = fileparts(which(mfilename)); % code directory path
behavDir  = fullfile(rootdir,'behavioral');

wrap      = 55;  %  new line of big font after this many characters
wrap_sm   = 70;  %  new line of small font after this many characters
big       = 35;  %  big font size
small     = 25;  %  small font size
trialtime = 28;  %  seconds
ips       = 229; %  scans in each run

rand('twister',GetSecs);% generate a new psuedorandom sequence

cd(behavDir);

try % after first run, load the same sequence
    load([subjID '.XPECT.1.mat'],'design','items','exp','jitter');
catch % first run
    order(1,:) = shuffle(1:5);
    % order(2,:) = shuffle(1:5);
    
    % 1 = non-social
    % 2 = behavioral
    % 3 = social
    c_designs = [1 2 3 1 2 3 3 2 1 3 2 1; 2 2 1 1 3 3 3 3 1 1 2 2; 1 3 2 3 2 1 1 2 3 2 3 1; ...
                 1 3 3 2 1 2 2 1 2 3 3 1; 3 3 1 2 2 1 1 2 2 1 3 3];
    
    % expected = 1, unexpected = 2
    
    e_designs = [1 2 2 1 2 2 1 1 2 1 1 2; 2 1 2 1 2 1 2 1 2 1 2 1; 1 1 1 2 2 2 1 1 1 2 2 2; ...
                 1 1 2 1 2 2 1 1 2 1 2 2; 1 2 2 1 1 2 1 2 2 1 1 2];
    
    % crossbalancing operator: inverts expected v. unexpected conditions
    if  cond == 1;
         e_designs = (e_designs/2).^(-1);
    end     
    
    design = []; exp = [];
    
    for i=1:5
        design = [design c_designs(order(1,i),:)];
        exp    = [exp    e_designs(order(1,i),:)];
    end
    
    % replace all 1's with shuffled 1:20, 2's with 21:40, etc.
    items = zeros(1,60);

    items(find(design == 3)) = shuffle(41:60); % social
    items(find(design == 2)) = shuffle(21:40); % behavioral
    items(find(design == 1)) = shuffle(1:20);  % non-social  
    
    % jitter - assumes there are 12 stories per run and 5 runs in total; adjust accordingly
    jitter = [shuffle([repmat(2,5,12) repmat(4,5,12) repmat(6,5,12)]')' repmat(12,5,1)];
    
    
    save([subjID '.XPECT.' num2str(acq) '.mat'],'design','items','exp','jitter');
end

RT         =  zeros(12,1);
key        =  zeros(12,1);

% sorts items into designed runs
items_run  = items((acq*12)-11:(acq*12));
design_run = design((acq*12)-11:(acq*12));
exp_run    = exp((acq*12)-11:(acq*12));
jitter_run = jitter(acq,:);

load(fullfile(rootdir,'stimuli.mat'));% creates instructions, question, and stimuli variables

%% PTB Stuff

% Uncomment the keyboard you are using
%   deviceString = 'Macally iKeySlim'; % name of lab desktop keyboard
  deviceString = 'Apple Internal Keyboard / Trackpad'; % name of MacBook Pro keyboard    
%  deviceString = 'Teensy Keyboard/Mouse'; % name of the scanner trigger box
    
    [id name] = GetKeyboardIndices; % get a list of all devices connected
    device = 0;
    for dev=1:length(name) % for each possible device
        if strcmp(name{dev},deviceString) % compare the name to the name you want
            device=id(dev); % grab the correct id and exit loop
            break;
        end
    end
    
    if device == 0 % error checking
        error('\nIs the trigger box connected? Try quitting out of MATLAB, connecting the trigger box, and restarting MATLAB IN THAT ORDER.');
    end
    
HideCursor;
displays   = Screen('screens');
screenRect = Screen('rect', displays(end)); %
[x0,y0]    = RectCenter(screenRect); %sets Center for screenRect (x,y)
s          = Screen('OpenWindow', displays(end),[0 0 0], screenRect, 32);

%% Instructions and Trigger
Screen(s,'TextSize',small);

DrawFormattedText(s,instructions,'center','center',255,wrap);Screen('Flip',s);

while 1  % wait for the 1st trigger pulse
    FlushEvents;
    trig = GetChar;
    if trig == '+'
        break
    end
end
Screen('Flip',s);

%% Main Experiment
t0 = GetSecs; % used to time duration of experiment

j=1; % jitter index
for trial = 1:12
    
    trialStart = GetSecs; % start of trial
    
    
    % present story
    Screen('FillRect',s,[0 0 0], screenRect);
    Screen(s,'TextSize',small);
    onsets_story(trial) = GetSecs - t0;
    DrawFormattedText(s,stimuli(items_run(trial)).part{1},'center','center',255,wrap_sm); 
    Screen('Flip',s);
    pause(12);
    
    
    Screen('Flip',s); 
    pause(jitter_run(j)); j=j+1;
    
    % present question and multi-choice answers    
    onsets_question(trial) = GetSecs - t0;
    DrawFormattedText(s,[stimuli(items_run(trial)).part{2}],'center','center',255,wrap_sm); 
    Screen('Flip',s); 
    response_t = GetSecs;
    
    % collect responses - gives 8 seconds to respond
    while GetSecs - response_t < 8;
       [keyIsDown,secs,keyCode] = KbCheck;
       
       % 30:33 (right hand: index, middle, ring, pinky)
       % 46 is trigger
       % to find out what value corresponds to what key, type this on the
       % command window:
       % WaitSecs(0.1); [a b] = KbWait; find(b==1)
       
        [button number]         = intersect(30:33, find(keyCode));
        if RT(trial)   == 0 & number > 0
            RT(trial) = GetSecs - response_t;
%             RT(trial)  = GetSecs - readStart;
            key(trial) = number;
        end
    end;
    
    %This is to prevent the continuous trigger at MIT from messing up
    %button press collection
    olddisabledkeys = DisableKeysForKbCheck(['+'])

    
    Screen('Flip',s);
    pause(jitter_run(j)); j=j+1;
    
    % present answer
    onsets_outcome(trial) = GetSecs - t0;
    DrawFormattedText(s,[stimuli(items_run(trial)).part{2+(exp_run(trial))}],'center','center',255,wrap_sm); 
    Screen('Flip',s); 
    pause(6); 
    
    % take question off screen
    Screen('Flip',s);
    
    % collect trial duration
    trial_dur(trial) = GetSecs - trialStart;
    
    pause(jitter_run(j)); j=j+1
    
    save([subjID '.XPECT.' num2str(acq) '.mat'],'ips','RT','key','design','design_run','items','items_run','exp','exp_run','jitter','jitter_run',...
        'onsets_story','onsets_question','onsets_outcome','trial_dur','acq','subjID');
    
    while GetSecs - trialStart < trialtime;end
    
end

experimentDur = GetSecs - t0;

%% Analysis Info


% 3 x 2 Analysis:
% Expected Nonsocial (A_EN)	Expected Behavioral (B_EB)	Expected Social(C_ES)
% Unexpect Nonsocial (D_UN)	Unexpect Behavioral (E_UB)	Unexpect Social(F_US)
	
condnames = {'A_EN','B_EB','C_ES',...
	         'D_UN','E_UB','F_US'};

% define contrasts for later

con_info(1).name  = 'social vs nonsocial';
con_info(1).vals  = [-1 0 1 -1 0 1];
con_info(2).name  = 'social vs behavior';
con_info(2).vals  = [0 -1 1 0 -1 1];
con_info(3).name  = 'nonsocial vs behavioral';
con_info(3).vals  = [1 -1 0 1 -1 0];
con_info(4).name  = 'nonsocial vs social';
con_info(4).vals  = [1 0 -1 1 0 -1];
con_info(5).name  = 'behavioral vs social';
con_info(5).vals  = [0 1 -1 0 1 -1];
con_info(6).name  = 'behavioral vs nonsocial';
con_info(6).vals  = [-1 1 0 -1 1 0];


% design_run: 1=nonsocial  2=behavioral  3=social
% exp_run:    1=expected   2=unexpected


entirety_run = zeros(1,12);
a = find(exp_run==1);
b = find(exp_run==2);
entirety_run(a) = design_run(a);
entirety_run(b) = design_run(b) + exp_run(b) + 1; 

for index = 1:6;    
    spm_inputs(index).name = condnames{index};
    spm_inputs(index).ons  = onsets_story(find(entirety_run==index));
    spm_inputs(index).dur  = repmat(12,length(spm_inputs(index).ons),1);  % total time a stimulus is on the screen, for one trial, in scans
end

%% Saves data

cd(behavDir);

% first, saves spm_inputs for stories
save([subjID '.XPECT.story.' num2str(acq) '.mat'],'onsets_story','condnames','entirety_run','con_info','acq','RT','key','design','design_run','items',...
'items_run','exp','exp_run','ips','jitter','jitter_run','trial_dur','experimentDur','subjID','spm_inputs'); %saves stories in new file

clear spm_inputs;

% next, saves spm_inputs for questions
for index = 1:6;    
    spm_inputs(index).name = condnames{index};
    spm_inputs(index).ons  = onsets_question(find(entirety_run==index));
    spm_inputs(index).dur  = repmat(8,length(spm_inputs(index).ons),1);  % total time a stimulus is on the screen, for one trial, in scans
end     

save([subjID '.XPECT.question.' num2str(acq) '.mat'],'onsets_question','condnames','entirety_run','con_info','acq','RT','key','design','design_run','items',...
'items_run','exp','exp_run','ips','jitter','jitter_run','trial_dur','experimentDur','subjID','spm_inputs'); %saves questions in new file

clear spm_inputs;

% finally, saves spm_inputs for outcomes
for index = 1:6;    
    spm_inputs(index).name = condnames{index};
    spm_inputs(index).ons  = onsets_outcome(find(entirety_run==index));
    spm_inputs(index).dur  = repmat(6,length(spm_inputs(index).ons),1);  % total time a stimulus is on the screen, for one trial, in scans
end     

save([subjID '.XPECT.outcome.' num2str(acq) '.mat'],'onsets_outcome','condnames','con_info','entirety_run','acq','RT','key','design','design_run','items',...
'items_run','exp','exp_run','ips','jitter','jitter_run','trial_dur','experimentDur','subjID','spm_inputs'); %saves outcomes in new file

cd ..

ShowCursor; Screen('CloseAll');

clear all;

end %ends main function
