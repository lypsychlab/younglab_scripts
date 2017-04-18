function make_new_spminputs(subnums);

rootdir='/home/younglw';
study='VERBS';
cd(fullfile(rootdir,study,'behavioural'));

for thissub=1:length(subnums)
    % try
    d=dir(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '*DIS_verbs*mat']);
    for thisd=1:length(d)
        load(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbs.' num2str(thisd) '.mat'],'spm_inputs');
        
        copyfile(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbs.' num2str(thisd) '.mat'],['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbint1.' num2str(thisd) '.mat']);
    
        for i=4:12
            spm_inputs(i).name=spm_inputs(i-3).name;
            spm_inputs(i).ons=spm_inputs(i-3).ons;
            spm_inputs(i).dur=spm_inputs(i-3).dur;
        end

        tgs={'_BG' '_ACT' '_OUT' '_INT'};
        minusdur=[8 9 9 9];
        counter=0;
        counter2=1;
        for i=1:12
            counter=counter+1;
            spm_inputs(i).name={[spm_inputs(i).name{1} tgs{counter2}]};
            spm_inputs(i).dur=spm_inputs(i).dur-minusdur(counter2);
            if counter==3
                counter=0;
                counter2=counter2+1;
            end
        end

        for i=4:12
            if numel(spm_inputs(i-3).dur) > 0
                spm_inputs(i).ons=spm_inputs(i-3).ons+spm_inputs(i-3).dur(1);
            end
        end
        
        save(['SAX_DIS_' sprintf('%02d',subnums(thissub)) '.DIS_verbint1.' num2str(thisd) '.mat'],'spm_inputs','-append');
    end %end run loop
    % catch
    %     disp(['Did nothing for subject ' num2str(subnums(thissub))]);
    %     continue
    % end
end %end sub loop

end %end function