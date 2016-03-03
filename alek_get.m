% Usage: outfiles = alek_get('groups/saxelab/CUES2/SAX_cues2_29','*.dcm')
% returns a call list of files.
function [out] = alek_get(root,filefilt)

file_struct = dir([root '/' filefilt]);

out = cell(length(file_struct),1);

for i=1:length(file_struct)
    out{i} = [root '/' file_struct(i).name];
end

out=char(out);

end