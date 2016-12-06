% fix_user_regressors:
cd('/home/younglw/VERBS/behavioural');
for thissub=1:47
	for runnum=1:6
		try
			load(['SAX_DIS_' sprintf('%02d',thissub) '.DIS_verbs.' num2str(runnum) '.mat'],'user_regressors');
			if size(user_regressors(1).ons,2)==1 %already fixed
				clear user_regressors;
				continue
			end

			cols=[];
			for thisreg=1:6
				cols=[cols size(user_regressors(thisreg).ons,2)];
			end
			thatreg=find(cols==6);thatreg=thatreg(1);

			reg=user_regressors(thatreg).ons;
			for thisreg=1:6
				user_regressors(thisreg).ons=reg(:,thisreg);
			end
			save(['SAX_DIS_' sprintf('%02d',thissub) '.DIS_verbs.' num2str(runnum) '.mat'],'user_regressors','-append');
		catch
			disp(['Could not process ' num2str(thissub) ' run ' num2str(runnum)]);
		end
	end
end