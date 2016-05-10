function group_roi(root_dir,study,res_dir,subj,init_coords,sph,roiname)

    

    spheresize=(2*sph)-1;
	%notice that the number of voxels in your sphere increases exponentially with sphere size.
	%for example, sph=2 corresponds to 7 shifts. sph=3 : 81 shifts. sph=4 : 275 shifts. sph=5 : 637 shifts.
	%reminder to be conservative about choosing sphere size
	move_coords=(6*(spheresize-2)^2)+(spheresize-2)^3; %the number of unique shift combinations to obtain coordinates w/in sphere
	v=-(sph-2):(sph-2);
	vindices_1=combinator(length(v),3,'p','r');
	vindices_2=combinator(length(v),2,'p','r');
	c1=v(vindices_1); c2=v(vindices_2);
	edge=repmat(sph-1,length(c2),1); %vector of repeated edge number
	coords=[c1; [edge c2]; [-edge c2]; [c2 edge]; [c2 -edge]; [c2(:,1) edge c2(:,2)]; [c2(:,1) -edge c2(:,2)]];
    
    sphere=repmat(init_coords,length(coords),1) + coords;
    

    res_dir=fullfile(root_dir,study.sprintf('SAX_DIS_%02d',subj),'results',res_dir);
    cd(res_dir);
    template_img=dir('beta_item*nii');template_img=template_img(1).name;
    roi_img=spm_vol(template_img);
    [Y,XYZ]   = spm_read_vols(roi_img);
    roi_mask=zeros(size(Y));
    
    for i=1:length(sphere)
        ind=find((XYZ(1,:)==sphere(i,1))&(XYZ(1,:)==sphere(i,2))...
            &(XYZ(3,:)==sphere(i,3)));
        ind2=find(Y==ind);
        roi_mask(ind2,:)=[1 1 1];
    end
    
    cd('../../../ROI');
    roi_img.fname=fullfile(pwd,['ROI_' roiname '_GROUP_' date '.img']);
    spm_write_vol(roi_img,roi_mask);
        

end % end function