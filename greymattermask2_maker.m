% Generates a variable called greymattermask2, which contains the 
% indices of every voxel in a 53 x 63 x 46 brain.
% These dimensions match the PSYCH-PHYS data. It is unclear whether it 
% will work for other datasets.


dimensions = [53 63 46];% full dimensions of the image. A 2-voxel buffer will be used automatically

voxel_order2 = zeros(length((dimensions(1)-4)...
                           *(dimensions(2)-4)...
                           *(dimensions(3)-4)),3);
i=1;
for x=3:dimensions(1)-2
    for y=3:dimensions(2)-2
        for z=3:dimensions(3)-2
            voxel_order2(i,:) = [x y z]; i=i+1;
        end
    end
end

save('/younglab/scripts/voxel_order2.mat','voxel_order2');
% make the grey matter mask image

load voxel_order2
template   = spm_vol('/younglab/greymattermask2.img,1');
[tY,tXYZ]  = spm_read_vols(template);

greymattermask2 = zeros(length(voxel_order2),1);
i=1;
for x=3:dimensions(1)-2
    for y=3:dimensions(2)-2
        for z=3:dimensions(3)-2
            if tY(x,y,z)>0
                greymattermask2(i)=1;
            end
            i=i+1;
        end
    end
end

greymattermask2 = find(greymattermask2 > 0);
save greymattermask2 greymattermask2
