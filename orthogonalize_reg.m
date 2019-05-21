function [out_matrix] = orthogonalize_reg(reg_matrix)
% orthogonalize_reg: orthogonalizes all regressors in a model w/r/t each other
	out_matrix=zeros(size(reg_matrix));
	for i = 1:size(reg_matrix,2)
		this_reg = reg_matrix(:,i);
		other_regs = [reg_matrix(:,1:i-1) reg_matrix(:,i+1:end)];
		[b,bint,r]=regress(this_reg,other_regs);
		out_matrix(:,i)=r;
	end
end % end function