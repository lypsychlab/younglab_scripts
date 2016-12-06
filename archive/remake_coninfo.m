con_names={'K_v_R' 'R_v_K' 'K_v_S' 'S_v_K' 'R_v_S'...
    'S_v_R' 'KR_v_S' 'S_v_KR' 'RS_v_K' 'K_v_RS'};
con_vals={[1 -1 0] [-1 1 0] [1 0 -1] [-1 0 1] [0 1 -1] ...
    [0 -1 1] [0.5 0.5 -1] [-0.5 -0.5 1] [-1 0.5 0.5] [1 -0.5 -0.5]};
for i=1:length(con_names)
        con_info(i).name={con_names{i}};
        con_info(i).vals=con_vals{i};
end
% order:K R S

cd('/home/younglw/VERBS/behavioural');
d=dir('*DIS_verbs*mat');
for b = 1:length(d)
    save(d(b).name,'con_info','-append');
end

