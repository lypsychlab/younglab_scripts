root_dir='/younglab/studies/DIS_MVPA/';
subj_nums=[3:15 17 19 22:24 29 31 34];
subjs={};
roinames={'PC','LTPJ','DMPFC','RTPJ'};
for s=1:length(subj_nums)
    subj=['SAX_DIS_' sprintf('%02d',subj_nums(s))];
    cd(fullfile(root_dir,subj));
%     mkdir('uniqueROI');
%     try
%         movefile('roi/extra_rtpjs/ROI_RTPJ*Jul-2015_xyz.hdr',fullfile(pwd,'uniqueROI/'));
%     catch
%         movefile('roi/extra_rtpjs/ROI_RTPJ*.hdr',fullfile(pwd,'uniqueROI/'));
%     end

%     rdir=dir(fullfile(pwd,'roi','ROI_RTPJ*.hdr'));
%     if length(rdir)==0
%         rdir2=dir(fullfile(pwd,'roi','extra_rtpjs','ROI_RTPJ*.hdr'));
%         movefile(fullfile(pwd,'roi','extra_rtpjs',rdir2(1).name),fullfile(pwd,'uniqueROI/'))
%     else
%         movefile(fullfile(pwd,'roi',rdir(1).name),fullfile(pwd,'uniqueROI/'))
%     end
      for roi=1:length(roinames)
        
        rdir=dir(fullfile(pwd,'roi',['ROI_' roinames{roi} '*.img']));
        movefile(fullfile(pwd,'roi',rdir(1).name),fullfile(pwd,'uniqueROI/'))
          
      end
    

%       if exist(fullfile(pwd,'uniqueROI'))==7
%           cd(fullfile(pwd,'uniqueROI'));
%           movefile('ROI_RTPJ*',fullfile(root_dir,subj,'roi'));
%             
%       end
end
