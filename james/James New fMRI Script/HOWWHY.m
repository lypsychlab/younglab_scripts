function HOWWHY(subjID,acq,cond)
% E.G., HOWWHY('YOU_HOWWHY_01',1,0)
%
%
% cond       = 0 = HOW, 1 = WHY 
% NOTE TO EXPERIMENTERS: 
% Balance how vs why by showing runs in sets of 2, then reversing in the middle of the experiment
% So, across all 16 runs, the full vector of how vs why will either look like:
% 001100110011 110011001100; or
% 110011001100 001100110011

% items      = 1x70 vector of items (1 through 60) across 5 runs
% items_run  = 1x10 vector of items for THIS run
% design     = 1x70 vector of conditions (1:3) used in across 5 runs
% design_run = 1x3 vector of conditions (1:3) used for THIS run
% RT         = 1x10 vector of reaction times for each run
% key        = 1x10 vector of user responses. 1=first choice, 4=last choice

%% Init info
rootdir   = fileparts(which(mfilename)); % code directory path
behavDir  = fullfile(rootdir,'behavioral');

wrap      = 55;  %  new line of big font after this many characters
wrap_sm   = 70;  %  new line of small font after this many characters
big       = 35;  %  big font size
small     = 25;  %  small font size
trialtime = 28;  %  does not include jitter times
%BG: 12s
%INSTRUCT: 6s
%INTENT: 4s
%JUDG: 4s

% TOTAL: 26 s
ips       = 158;%FIX THIS

rand('twister',GetSecs);% generate a new psuedorandom sequence

cd(behavDir);

try % after first run, load the same sequence
    load([subjID '.HOWWHY.1.mat'],'design','items','int','jitter');
catch % first run
    order(1,:) = Shuffle(1:7); 
    order(2,:) = Shuffle(1:7);
    % run order
    
    % 1= physical, 2=psychological, 3=incest, 4=pathogen, 5=neutral
    % MAKE: 10 x 7 array (columns = runs, rows = trials, as below)
    c_designs = [1 2 3 4 5 5 4 3 2 1; 2 5 4 1 3 3 1 4 5 2; 4 3 2 5 1 1 5 2 3 4; ...
                 1 3 5 4 2 2 4 5 3 1; 3 1 5 2 4 4 2 5 1 3; 5 3 2 4 1 1 4 2 3 5;
                 4 3 2 1 5 5 1 2 3 4];
    
    % accidental = 1, intentional = 2
    i_designs = [1 2 2 1 2 1 2 1 1 2; 2 1 2 1 2 1 2 1 2 1; 1 1 1 2 2 1 1 2 2 2; ...
                 2 1 2 1 2 1 2 1 2 1; 1 2 2 1 1 2 2 1 1 2; 2 2 1 1 2 1 2 2 1 1; ...
                 1 1 2 2 1 2 1 1 2 2];

    
    design = []; int = [];
    
    for i=1:7
        design = [design c_designs(order(1,i),:)];
        int    = [int    i_designs(order(2,i),:)];
    end
    
    % replace with indices into vector of items
    items = zeros(1,70);
    items(find(design == 5))   = Shuffle(57:70);% neutral
    items(find(design == 4))   = Shuffle(43:56);% pathogen
    items(find(design == 3))   = Shuffle(29:42);% incest
    items(find(design == 2))   = Shuffle(15:28);% psych harm
    items(find(design == 1))   = Shuffle(1:14);%  physical harm 
    
    jitter=[];
    for j=1:14
    jit = Shuffle([repmat(2,1,3) repmat(4,1,3) repmat(6,1,3)]);
    jitter=[jitter;jit];
    end
    
    %double the experiment; second half will have why/how blocking reversed
    items=repmat(items,1,2);
    design=repmat(design,1,2);
    int=repmat(int,1,2);

    
    save([subjID '.HOWWHY.' num2str(acq) '.mat'],'design','items','int','jitter');
end

RT         =  zeros(10,1); %RT for moral judgment
key        =  zeros(10,1); %keypress for moral judgment
readyRT   =  zeros(10,1); %RT for verification keypress (verify that you're ready to continue)

% sorts items into designed runs
% acq is the run number
items_run  = items((acq*10)-9:(acq*10));
design_run = design((acq*10)-9:(acq*10));
int_run    = int((acq*10)-9:(acq*10));
jitter_run = jitter(acq,:);

load(fullfile(rootdir,'HOWWHY_stimuli.mat'));% creates instructions, question, and stimuli variables
% CONTAINS:
% instructions (string)
% question (string)
% prompt (1 x 2 cell for how versus why prompts)
% stimuli (70 x 4 struct)
% stimuli(i).part{1}: scenario for stimulus i
% stimuli(i).part{2}: intent info for stimulus i

%% PTB Stuff

devices=PsychHID('devices');   
[dev_names{1:length(devices)}]=deal(devices.usageName);
kbd_devs = find(ismember(dev_names, 'Keyboard')==1);

HideCursor;
displays   = Screen('screens');
screenRect = Screen('rect', displays(end)); %
[x0,y0]    = RectCenter(screenRect); %sets Center for screenRect (x,y)
    
s          = Screen('OpenWindow', displays(end),[0 0 0], screenRect, 32);

%% Instructions and Trigger
Screen(s,'TextSize',small);

DrawFormattedText(s,instructions{1+cond},'center','center',255,wrap);Screen('Flip',s);

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

for trial = 1:10
    
    trialStart = GetSecs; % start of trial
    
     %This is to prevent the continuous trigger at MIT from messing up
    %button press collection
    olddisabledkeys = DisableKeysForKbCheck(['+'])
    
    % present BG
    Screen('FillRect',s,[0 0 0], screenRect);
    Screen(s,'TextSize',small);
    onsets(trial) = GetSecs - t0;
    DrawFormattedText(s,stimuli(items_run(trial)).part{1},'center','center',255,wrap_sm); 
    Screen('Flip',s);
    pause(12); %duration of BG 

    % present instructions/ask for button press
    DrawFormattedText(s,prompt{1+cond},'center','center',255,wrap_sm);
    % if cond == 0, they get HOW instructions
    % if cond == 1, they get WHY instructions
    Screen('Flip',s);
    ready_t = GetSecs;

    %get RT for verification button press:
    while (GetSecs - ready_t) < 6;
        [keyIsDown timeSecs keyCode] = KbCheck;       
       % 30:33 (right hand: index, middle, ring, pinky)
       % 46 is trigger
       % to find out what value corresponds to what key, type this on the
       % command window:
       % WaitSecs(0.1); [a b] = KbWait; find(b==1)
       
        [button number]         = intersect(30:33, find(keyCode));
        if readyRT(trial)   == 0 & number > 0
            readyRT(trial) = GetSecs - ready_t;
        end
    end

    %present intent:
    DrawFormattedText(s,stimuli(items_run(trial)).part{1+int_run(trial)},'center','center',255,wrap_sm); 
    Screen('Flip',s);
    pause(4);

    % get judgment:
    % present question and multi-choice answers    
    DrawFormattedText(s,stimuli(items_run(trial)).part{4},'center','center',255,wrap_sm); 
    Screen('Flip',s); 
    response_t = GetSecs;
    
    % collect responses - gives 4 seconds to respond
    while (GetSecs - response_t) < 4;
        [keyIsDown timeSecs keyCode] = KbCheck;       
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
    
   % take question off screen:
    Screen('Flip',s);

    % collect trial duration
    trial_dur(trial) = GetSecs - trialStart;
    
    %post-trial jitter:
    if trial<10
    pause(jitter_run(trial));    
    end

    if trial==10
        DrawFormattedText(s,'+','center','center',255,wrap_sm);
        Screen('Flip',s);
        pause(10);
    end
    
    save([subjID '.HOWWHY.' num2str(acq) '.mat'],'ips','RT','readyRT','key','design','design_run','items','items_run','int','int_run','jitter','jitter_run',...
        'onsets','trial_dur','acq','subjID','cond');
    
    while GetSecs - trialStart < trialtime;end
    
end



experimentDur = GetSecs - t0;

%% Analysis Info

%% Analysis Info
condnames = {'A_PHA','B_PSA','C_IA','D_PA','E_NA',...
'F_PHI','G_PSI','H_II','I_PI','J_NI'};

% define contrasts for later
con_info(1).name = 'all harm vs baseline';
con_info(1).vals = [1 1 0 0 0 1 1 0 0 0];
con_info(2).name = 'all disgust vs baseline';
con_info(2).vals = [0 0 1 1 0 0 0 1 1 0];
con_info(3).name = 'all harm vs all disgust';
con_info(3).vals = [1 1 -1 -1 0 1 1 -1 -1 0];
con_info(4).name = 'all disgust vs all harm';
con_info(4).vals = [-1 -1 1 1 0 -1 -1 1 1 0];
con_info(5).name = 'all intentional vs all accidental';
con_info(5).vals = [1 1 1 1 1 -1 -1 -1 -1 -1];
con_info(6).name = 'all accidental vs all intentional';
con_info(6).vals = [-1 -1 -1 -1 -1 1 1 1 1 1];
con_info(7).name = 'intentional harm vs intentional disgust';
con_info(7).vals = [0 0 0 0 0 1 1 -1 -1 0];
con_info(8).name = 'intentional disgust vs intentional harm';
con_info(8).vals = [0 0 0 0 0 -1 -1 1 1 0];
con_info(9).name = 'accidental harm vs accidental disgust';
con_info(9).vals = [1 1 -1 -1 0 0 0 0 0 0];
con_info(10).name = 'accidental disgust vs accidental harm';
con_info(10).vals = [-1 -1 1 1 0 0 0 0 0 0];
con_info(11).name = 'intentional harm vs accidental harm';
con_info(11).vals = [-1 -1 0 0 0 1 1 0 0 0];
con_info(12).name = 'accidental harm vs intentional harm';
con_info(12).vals = [1 1 0 0 0 -1 -1 0 0 0];
con_info(13).name = 'intentional disgust vs accidental disgust';
con_info(13).vals = [0 0 -1 -1 0 0 0 1 1 0];
con_info(14).name = 'accidental disgust vs intentional disgust';
con_info(14).vals = [0 0 1 1 0 0 0 -1 -1 0];
con_info(15).name = 'physical harm vs psychological harm';
con_info(15).vals = [1 -1 0 0 0 1 -1 0 0 0];
con_info(16).name = 'psychological harm vs physical harm';
con_info(16).vals = [-1 1 0 0 0 -1 1 0 0 0];
con_info(17).name = 'incest vs pathogen';
con_info(17).vals = [0 0 1 -1 0 0 0 1 -1 0];
con_info(18).name = 'pathogen vs incest';
con_info(18).vals = [0 0 -1 1 0 0 0 -1 1 0];
con_info(19).name = 'both harm vs incest';
con_info(19).vals = [.5 .5 -1 0 0 .5 .5 -1 0 0];
con_info(20).name = 'both harm vs pathogen';
con_info(20).vals = [.5 .5 0 -1 0 .5 .5 0 -1 0];
con_info(21).name = 'physical harm vs incest';
con_info(21).vals = [1 0 -1 0 0 1 0 -1 0 0];
con_info(22).name = 'physical harm vs pathogen';
con_info(22).vals = [1 0 0 -1 0 1 0 0 -1 0];
con_info(23).name = 'psychological harm vs incest';
con_info(23).vals = [0 1 -1 0 0 0 1 -1 0 0];
con_info(24).name = 'psychological harm vs pathogen';
con_info(24).vals = [0 1 0 -1 0 0 1 0 -1 0];
con_info(25).name = 'all moral vs neutral';
con_info(25).vals = [.25 .25 .25 .25 -1 .25 .25 .25 .25 -1];
con_info(26).name = 'physical harm vs neutral';
con_info(26).vals = [1 0 0 0 -1 1 0 0 0 -1];
con_info(27).name = 'psychological harm vs neutral';
con_info(27).vals = [0 1 0 0 -1 0 1 0 0 -1];
con_info(28).name = 'incest vs neutral';
con_info(28).vals = [0 0 1 0 -1 0 0 1 0 -1];
con_info(29).name = 'pathogen vs neutral';
con_info(29).vals = [0 0 0 1 -1 0 0 0 1 -1];

entirety_run = zeros(1,10);
a = find(int_run==1); %accidental trials
b = find(int_run==2); %intentional trials
entirety_run(a) = design_run(a);
entirety_run(b) = design_run(b) + 5; 
%for example:
% if condition was 4, and accidental -> entirety_run(index) = 4
% if condition was 4, and intentional -> entirety_run(index)=4+5 = 9

%set up spm_inputs 
for index = 1:10;    
    spm_inputs(index).name = condnames{index};
    spm_inputs(index).ons  = onsets(find(entirety_run==index));
    spm_inputs(index).dur  = repmat(26,length(spm_inputs(index).ons),1);  % total time a stimulus is on the screen, for one trial, in scans
end


%% Saves data

cd(behavDir);

%saves full set of variables in behavioral dir 
save([subjID '.HOWWHY.' num2str(acq) '.mat'],'onsets','condnames','entirety_run','con_info','acq','RT','readyRT','key','design','design_run','items',...
'items_run','int','int_run','ips','jitter','jitter_run','trial_dur','experimentDur','subjID','spm_inputs','cond','-append'); 

clear spm_inputs;

cd ..

ShowCursor; Screen('CloseAll');

clear all;

end %ends main function
