imgfiles = spm_select(inf,'image','Choose an .img file','',pwd,'.*',1);
choice   = questdlg('Do you want to delete the .img files after creating the .mat files?');

for i=1:size(imgfiles,1)

    img             = spm_vol(imgfiles(i,:));
    
    [dir, namepart] = fileparts(imgfiles(i,:));
    
    [Y,XYZ]         = spm_read_vols(img);
    
    roi_xyz         = XYZ(:,Y>0);
    
    roi_xyz         = roi_xyz';
    save([namepart '.mat'],'roi_xyz')

    if strcmp(choice,'Yes') == 1
        delete([namepart '.img']);
        delete([namepart '.hdr']);
    end
end