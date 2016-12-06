function try_preproc_pleiades(inp)

cd /home/younglw/scripts;
study='DIS_MVPA';
tname='DIS';
subj_nums=[3:20 22:24 27:35 36:42 44:47]; 
subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
end


	for i=1:length(inp)
		ind=find(subj_nums==inp(i));
		% try
			younglab_preproc_spatial_spm8(study,subjs{ind},3);
		% catch
		% 	diary('/home/younglw/server/englewood/DIS_MVPA/DIS_MVPA/try_itemwise_pleiades.txt');
		% 	disp(['Unable to model subject ' subjs{thissub} ' : ' char(datetime('now','Format','HH:mm MM/dd/yyyy'))]);
		% 	diary off;
		% 	continue;
		% end %end try
	end %end subjs loop
end % end function