function new_2mm_DIS
    subjects = [10 11 12 13 14 27 28 32 34 38 40 41 42 43 45 46]; %subjects to copy
%     cd('/younglab/studies');
%     mkdir('DIS_2mm');
%     cd('DIS_2mm');
%     mkdir('behavioural');
%     copyfile('/younglab/studies/DIS/behavioural','/younglab/studies/DIS_2mm/behavioural');
    for subj = 1:length(subjects)
        if subjects(subj)<10
            mkdir(['/younglab/studies/DIS_2mm/SAX_DIS_0' num2str(subjects(subj))],'results_fornonpara');
            mkdir(['/younglab/studies/DIS_2mm/SAX_DIS_0' num2str(subjects(subj)) '/results_fornonpara'],'DIS.domain_results_smoothed_normed');
            mkdir(['/younglab/studies/DIS_2mm/SAX_DIS_0' num2str(subjects(subj)) '/results_fornonpara'],'DIS.domint_results_smoothed_normed');
            copyfile(['/younglab/studies/DIS_2mm/SAX_DIS_0', num2str(subjects(subj)), '/results/DIS.domain_results_smoothed_normed'],['/younglab/studies/DIS_2mm/SAX_DIS_0' num2str(subjects(subj)) '/results_fornonpara/DIS.domain_results_smoothed_normed']);
            copyfile(['/younglab/studies/DIS_2mm/SAX_DIS_0', num2str(subjects(subj)), '/results/DIS.domint_results_smoothed_normed'],['/younglab/studies/DIS_2mm/SAX_DIS_0' num2str(subjects(subj)) '/results_fornonpara/DIS.domint_results_smoothed_normed']);
        else 
            mkdir(['/younglab/studies/DIS_2mm/SAX_DIS_' num2str(subjects(subj))],'results_fornonpara');
            mkdir(['/younglab/studies/DIS_2mm/SAX_DIS_' num2str(subjects(subj)) 'results_fornonpara'],'DIS.domain_results_smoothed_normed');
            mkdir(['/younglab/studies/DIS_2mm/SAX_DIS_' num2str(subjects(subj)) 'results_fornonpara'],'DIS.domint_results_smoothed_normed');
            copyfile(['/younglab/studies/DIS_2mm/SAX_DIS_', num2str(subjects(subj)), '/results/DIS.domain_results_smoothed_normed'],['/younglab/studies/DIS_2mm/SAX_DIS_' num2str(subjects(subj)) 'results_fornonpara/DIS.domain_results_smoothed_normed']);
            copyfile(['/younglab/studies/DIS_2mm/SAX_DIS_', num2str(subjects(subj)), '/results/DIS.domint_results_smoothed_normed'],['/younglab/studies/DIS_2mm/SAX_DIS_' num2str(subjects(subj)) 'results_fornonpara/DIS.domint_results_smoothed_normed']);
        end
    end
end