addpath('/home/younglw/scripts');

subjs={};sessions={};
snums=[41];
subj_nums=[];
% for s=snums
%     if ~ismember(s,[21 25 26 36 37 43])
%         subj_nums=[subj_nums s];
%         subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
%         if ismember(s,[5 9 16])
%             sessions{end+1}=[10 12 14 20 22 24];
%         elseif ismember(s,[7 14 24])
%             sessions{end+1}=[12 14 16 22 24 26];
%         elseif ismember(s,[37 44])
%             sessions{end+1}=[6 8 10 16 18 20];
%         elseif ismember(s,[38 39 40 42 45 46 47])
%             sessions{end+1}=[4 6 8 14 16 18];
%         else
%             sessions{end+1}=[8 10 12 18 20 22];
%         end
%     end
% end
sessions=[4 8 10 16 18 20];
% for i=1:length(subj_nums)
    try
        thissess=sessions;
        thissub_name='SAX_DIS_41';
        thissub=41;
        disp(['Modeling subject ' thissub_name ' sessions ' num2str(thissess)]);
        model_alek_verbs(thissub,thissess);
    catch
        disp(['Could not model subject ' thissub_name '.']);
        continue
    end
% end


