function make_new_spminputs2(subnums);

rootdir='/home/younglw';
study='VERBS';
cd(fullfile(rootdir,study,'behavioural'));

for thissub=1:length(subnums)
    try
    disp(['Subject ' num2str(subnums(thissub))]);
    d=dir(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '*DIS_verbs*mat']);
    for thisd=1:length(d)
        load(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbint1.' num2str(thisd) '.mat'],'spm_inputs');
        
        copyfile(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbint1.' num2str(thisd) '.mat'],['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbint2.' num2str(thisd) '.mat']);
    
        ctr=1;
        nms={'Knew' 'Realize' 'Saw'};
        for i=10:12
            if numel(spm_inputs(i).dur) > 0
                spm_inputs(i).name={[nms{ctr} '_INTJUD']};
                spm_inputs(i).dur=spm_inputs(i).dur+2;
            end
        end

        
        save(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbint1.' num2str(thisd) '.mat'],'spm_inputs','-append');
    end %end run loop
    catch
        disp(['Did nothing for subject ' num2str(subnums(thissub))]);
        continue
    end
end %end sub loop

end %end function