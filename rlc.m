function last = rlc()
    % returns the last command
    last = '';
    fid = fopen([prefdir, '/history.m'], 'rt');
    while fid > 0
      linein = fgetl(fid);
      if ~ischar(linein); break; else last = linein; end
    end
    if fid > 0; fclose(fid); end
end