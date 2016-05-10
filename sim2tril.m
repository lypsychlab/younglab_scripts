function trilm = sim2tril(simmat)
% trilm  = sim2tril:
% - transforms a similarity matrix into a vector.
simmat(simmat==0)=9999;
temp  = tril(simmat,-1);
trilm = temp(temp~=0);
trilm(trilm==9999)=0;
end