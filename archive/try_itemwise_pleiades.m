function try_itemwise_pleiades(inp)

cd /home/younglw/scripts;
study='DIS_MVPA';
tname='DIS';
subj_nums=[3:20 22:24 27:35 36:42 44:47]; 

subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
    if ismember(s,[5 9 16 19])
        sessions{end+1}=[10 12 14 20 22 24];
    elseif ismember(s,[7 14 24])
        sessions{end+1}=[12 14 16 22 24 26];
    elseif ismember(s,[37 44])
        sessions{end+1}=[6 8 10 16 18 20];
    elseif ismember(s,[38 39 40 42 45 46 47])
        sessions{end+1}=[4 6 8 14 16 18];
    elseif ismember(s,[17])
    	sessions{end+1}=[8 12 14 20 22 24];
    elseif ismember(s,[41])
    	sessions{end+1}=[4 8 10 16 18 20];
    elseif ismember(s,[32])
    	sessions{end+1}=[8 10 12 20 22 24];
    else
        sessions{end+1}=[8 10 12 18 20 22];
    end
end

% test on one subject:
if inp==0
	younglab_model_spm8_itemwise_unsmooth_pleiades(study,subjs{1},tname,sessions{1},'clobber');
else if inp==1
	for thissub=1:length(subjs)
		try
			younglab_model_spm8_itemwise_unsmooth_pleiades(study,subjs{thissub},tname,sessions{thissub})
		catch
			diary('/home/younglw/server/englewood/DIS_MVPA/DIS_MVPA/try_itemwise_pleiades.txt');
			disp(['Unable to model subject ' subjs{thissub} ' : ' char(datetime('now','Format','HH:mm MM/dd/yyyy'))]);
			diary off;
			continue;
		end % end try
	end % end subjs loop
else
	for i=1:length(inp)
		ind=find(subj_nums==inp(i));
		% try
			younglab_model_spm8_itemwise_unsmooth_pleiades(study,subjs{ind},tname,sessions{ind})
		% catch
		% 	diary('/home/younglw/server/englewood/DIS_MVPA/DIS_MVPA/try_itemwise_pleiades.txt');
		% 	disp(['Unable to model subject ' subjs{thissub} ' : ' char(datetime('now','Format','HH:mm MM/dd/yyyy'))]);
		% 	diary off;
		% 	continue;
		% end %end try
	end %end subjs loop
end
end % end function