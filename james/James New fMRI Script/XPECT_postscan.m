                                             
function XPECT_postscan(subjID)
% E.G., DIS_behav('SAX_DIS_01')
%
% items      = 1x60 vector of items (1 through 60) across 6 runs
% design     = 1x60 vector of conditions (1:3) used in across 6 runs
% exp        = 1x60 1's and 2's. 1=expected, 2=unexpected
% RT         = 1x60 vector of reaction times for each
% key        = 1x60 vector of user responses. 1=not wrong, 4=very wrong

%% Init info
rootdir   = fileparts(which(mfilename));
behavDir  = fullfile(rootdir,'behavioral');
wrap      = 55;%  new line after this many big characters
wrap_sm   = 70;%  new line after this many small characters
big       = 35;%  big font size
small     = 25;%  small font size

cd(behavDir);

load([subjID '.XPECT.1.mat'],'design','items','exp');

RT         = zeros(60,1);
key        = zeros(60,1);

load(fullfile(rootdir,'stimuli.mat'));% creates instructions, question, and stimuli variables

%% PTB Stuff
% Identify attached keyboard devices:
devices=PsychHID('devices');
[dev_names{1:length(devices)}]=deal(devices.usageName);
kbd_devs = find(ismember(dev_names, 'Keyboard')==1);

HideCursor;
displays   = Screen('screens');
screenRect = Screen('rect', displays(end)); %
[x0,y0]    = RectCenter(screenRect); %sets Center for screenRect (x,y)
s          = Screen('OpenWindow', displays(end),[0 0 0], screenRect, 32);

%% Instruction Screen
Screen(s,'TextSize',big);

DrawFormattedText(s, 'Now, please go through the stories you just read, and rate how EXPECTED each story was.\n\n Press any key to continue.', 'center', 'center', 255,wrap);

Screen('Flip',s);

KbWait;Screen('Flip',s);

%% Main Experiment
Screen(s,'TextSize',small);

t0 = GetSecs; % used to time duration of experiment

for trial = 1:length(items)
    
    % present each part of the story
    Screen('FillRect',s,[0 0 0], screenRect);
    DrawFormattedText(s,...
        [stimuli(items(trial)).part{1} ' ' ...
         stimuli(items(trial)).part{2} ' ' ...
         '\n\n' stimuli(items(trial)).part{2+exp(trial)}] ,'center',y0-230 ,255,wrap_sm);
    
    DrawFormattedText(s,'How Expected?\n\n 1               2               3               4 \n not at all                                  very','center', y0+215, [0 255 0],wrap);
    
    Screen('Flip',s);
    
    readStart = GetSecs;
    
    while GetSecs-readStart<1;
end
    
    %collect responses
    KbWait;
    [keyIsDown,secs,keyCode] = KbCheck;
    
    [button number]          = intersect(30:38, find(keyCode));
    %[button number]          = intersect(89:92, find(keyCode));
    
    if RT(trial)   == 0 & number > 0
        RT(trial)  = GetSecs - readStart;
        key(trial) = number;
    end
    
    %take question off screen
    Screen('Flip',s);
    
    save([subjID '.XPECT_behav.mat'],'RT','key','design','items','exp','subjID');
    
end

experimentDur = GetSecs - t0;

cd(behavDir); save([subjID '.XPECT_behav.mat'],'RT','key','design','items','exp', 'experimentDur','subjID');

ShowCursor; Screen('CloseAll');

clear all;
end % main function