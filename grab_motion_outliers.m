function grab_motion_outliers(study, subjs, runs)

% Grabs motion outliers from 'art_regression_outliers*.mat' files in bold folders, and organizes them into a single table that can be
% used for later data scrubbing of PSC data.

% Parameters:
% - study: name of the study folder, 'TPS'
% - subjs: cell array of subject numbers
% - runs: cell array of arrays of run numbers used to reference 'bold' folders where outlier files are located. e.g. {[11 13 15 17], [13 15 19 21]}



savename = 'motion_outliers_';

all_sub_info=[];
all_outlier_info = [];
all_img_nums = [];
for thissub=1:length(subjs)
  disp(['Processing subject ' subjs{thissub}]);
      sub_info = [];
      outlier_info = [];
      img_nums = [];
      for thisrun = 1:length(runs{thissub})
        cd(fullfile('/data/younglw/lab/',study,subjs{thissub},'bold/',sprintf('%03d',runs{thissub}(thisrun))));
        out_mat = dir('art_regression_outliers_swraf*.mat');
        out_mat = load(out_mat(1).name);
        out_array = out_mat.R; %Load 2-D array of movement outlier info

        %Builds a single vector with all the outlier info
        col_num = 1;
        out_col = [];
        for i = 1:size(out_array,1) %number of images in each run
               try
                 if out_array(i,col_num)==1 %if outlier
                    out_col(i)=1;
                    col_num = col_num + 1;
                 else
                    out_col(i)=0;
                 end
               catch
                  disp('no more outlier images in this run');
                  num_zeros = size(out_array,1)-(i-1);
                  end_zeros = zeros([1 num_zeros]);
                  out_col = [out_col, end_zeros];
                  break
                end
        end
        out_col = out_col'; %make horizontal array vertical
        outlier_info = [outlier_info;out_col];
        if thisrun > 1
          new_imgs=img_nums(end) + [1:length(out_col)];
          new_imgs=new_imgs';
        else
          new_imgs = [1:length(out_col)];
          new_imgs=new_imgs';
        end
        img_nums = [img_nums; new_imgs];
        subj_run=[repmat([subjs{thissub}],length(out_col),1)];
        sub_info = [sub_info;subj_run];
        disp(['Finished with run ' thisrun])

      end %end runs loop

      all_sub_info = [all_sub_info;sub_info];
      all_outlier_info = [all_outlier_info;outlier_info];
      all_img_nums = [all_img_nums;img_nums];
      disp(['Finished with subject ' subjs{thissub}])

end%end subject loop

cd(fullfile('/data/younglw/lab/',study,'results'));
outliers = table(all_sub_info, all_img_nums,all_outlier_info);
save([savename study '.mat'],'outliers','all_sub_info','all_img_nums','all_outlier_info');
