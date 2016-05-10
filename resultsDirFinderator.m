function sSubjs = resultsDirFinderator()
    expRoot		= '/younglab/studies/';
    studyName	= 'BKIDS';%input(sprintf('Study name:\t\t'),'s');
    taskName    = 'mnm';%input(sprintf('Task name:\t\t'),'s');
    resultName	= 'mnm';%input(sprintf('Results folder name:\t'),'s');

    studyDir	= [expRoot studyName '/'];

    curDir = pwd;
    cd(studyDir)

    [a subjs] = system(sprintf('ls *%s*/results/*%s* -dm',taskName,resultName));
    subjs = regexp(subjs,', *','split');
    [s,v] = listdlg('PromptString',sprintf('Please select your result directories (ctrl+click selects multiple)'),'ListString',subjs,'ListSize',[500 600]);
    for i=1:length(subjs)
        sSubjs{i} = [studyDir subjs{i} '/SPM.mat'];
    end
end

function subjects = listBoxMake(subjs)
    colormat   = [220 220 224]/255; labelcolor = [154 154 217]/255; listboxC = [204 204 222]/255; 
    fig = figure('Units','normalized','Position',[.1 .1 .30 .8],...
        'NumberTitle','off','menubar','non','Color',colormat);
    set(fig,'DefaultUicontrolUnits','Normalized');
    set(fig,'DefaultUicontrolHorizontalAlignment','Center');
    set(fig,'DefaultUicontrolfontsize',15);
    uicontrol(fig,'Style','text', 'String',sprintf('Choose your directories\nctrl+click to select more than one...'), ...
        'Position',[0 .95 1 .05],'BackgroundColor',labelcolor);
    subjects = uicontrol(fig,'Style','listbox','String',sprintf('%s|',subjs{:}),'Position',[0 .05 1 .90],'Min',1,'Max',10000,'BackgroundColor',listboxC);
    uicontrol(fig,'Style','pushbutton','String','OK','Position',[0 0 1 .05],'Callback',FUCKINGCALLBACK(subjects));
end



