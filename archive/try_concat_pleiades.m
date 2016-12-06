function try_concat_pleiades(inp,subs)

    cd /home/younglw/scripts;
    study='VERBS';
    tname='DIS_verbint1';
    subj_nums=[3:20 22:24 27:47]; 

    subjs={};sessions={};
    for s=subj_nums
        subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
        if ismember(s,[5 9 16 19])
            sessions{end+1}=[10 12 14 20 22 24];
        elseif ismember(s,[7 14 24])
            sessions{end+1}=[12 14 16 22 24 26];
        elseif ismember(s,[37 44])
            sessions{end+1}=[6 8 10 16 18 20];
        elseif ismember(s,[38 39 40 42 45 47])
            sessions{end+1}=[4 6 8 14 16 18];
        elseif ismember(s,[17])
        	sessions{end+1}=[8 12 14 20 22 24];
        elseif ismember(s,[41])
        	sessions{end+1}=[4 8 10 16 18 20];
        elseif ismember(s,[32])
        	sessions{end+1}=[8 10 12 20 22 24];
        elseif ismember(s,[43])
        	sessions{end+1}=[4 6 8 10 18];
        elseif ismember(s,[46])
        	sessions{end+1}=[4 6 8 14 16];
        else
            sessions{end+1}=[8 10 12 18 20 22];
        end
    end

% test on one subject:
    if inp==0
    	younglab_model_spm12_concat_itemwise_pleiades(study,subjs{1},tname,sessions{1},'no_art','clobber');
    else 
        ind = find(subj_nums==subs(1));
        ind2 = find(subj_nums==subs(2));
    	for thissub=ind:ind2
    		try
    			younglab_model_spm12_concat_itemwise_pleiades(study,subjs{thissub},tname,sessions{thissub},'no_art','clobber');
    		catch
    			disp(['Unable to model subject ' subjs{thissub} ' : ' char(datetime('now','Format','HH:mm MM/dd/yyyy'))]);
    			continue;
    		end % end try
    	end % end subjs loop
    end %end if

end %end function