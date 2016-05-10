% utility that creates a bet mask and returns the volume
%
% Oliver Hinds <ohinds@mit.edu> 2009-06-03
function mas = art_betmask(filestrs)

  % consolodate filenames
  files = {};
%  if(numel(filestrs) == 1 && ~isempty(strfind(filestrs,',')))
%    singlefile = true;
%    comma_ind = strfind(filestrs,',');
%    files = filestrs(1:comma_ind-1);
%    tp = str2num(filestrs(comma_ind+1:end));
%  else
    singlefile = false;
    for(f=1:numel(filestrs))    
      filestr = filestrs{f};
      for(r=1:size(filestr,1))
	str = filestr(r,:);
	comma_ind = strfind(str,',');
	if(isempty(comma_ind))
	  files{end+1} = str;
	else
	  files{end+1} = str(1:comma_ind-1);
	end
      end
    end
    files = unique(files);
%  end

  if(numel(files) > 1)
    merged = tempname;

    % build fslmerge command
    cmd = ['fslmerge -t ' merged];
    for(f=1:numel(files))
      cmd = [cmd ' ' files{f}];
    end
    disp(cmd);
    stat = system(cmd);
    if(stat)
      error(['fslmerge failed, check fsl settings. command was: ' cmd]);
    end
    bet_infile = merged;
    to_delete = {bet_infile};
%  elseif(singlefile)
%    splitdir = [tempdir tempname];
%    
%    % build split command
%    cmd = ['fslsplit ' files ' ' splitdir '/split'];
%    disp(cmd);
%    stat = system(cmd);
%    if(stat)
%      error(['fslsplit failed, check fsl settings. command was\n' cmd]);
%    end    
%    
%    bet_infile = [splitdir '/split' tp];
%    to_delete = {splitdir};
  else
    to_delete = {};
    bet_infile = files{1};
  end

  % bet command
  cmd = ['bet ' bet_infile ' BETArtifactMask -m -n'];
  disp(cmd);
  stat = system(cmd);
  if(stat)
    error(['bet failed, check fsl settings. command was\n' cmd]);
  end
  
  % move it
  system('rename -f "s/BETArtifactMask_mask/BETArtifactMask/" BETArtifactMask*');

  % load it
  maskname = 'BETArtifactMask';
  [stat type] = system('echo $FSLOUTPUTTYPE');
  type(end)= [];
  
  if(strcmp(type,'NIFTI'))
    maskname = [maskname '.nii'];
  elseif(strcmp(type,'NIFTI_GZ'))
    maskname = [maskname '.nii.gz'];
  else
    error(['unsupported $FSLOUTPUTTYPE: ' type ', try NIFTI or NIFTI_GZ']);
  end
  
  disp(['Generated mask image is written to file ' maskname])

  mask  = load_nifti(maskname);
  mas = mask.vol;
 keyboard
  % delete temp files and dirs
  for(f=1:numel(to_delete))
    [p s e] = fileparts(to_delete{f});
    if(isempty(s)) % dir
      system(['rm ' p '*']);
      system(['rmdir ' p]);
    else % file
      system(['rm ' p '/' s '*']);
    end
  end
  
return


