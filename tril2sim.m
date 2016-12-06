function simmat = tril2sim(trilm)



i=1; j=1;

while j ~= length(trilm)

    j = ((i*i)-i)/2;

    i = i+1;

end

simsize = i-1;

simmat = ones(simsize);



list = 1:simsize;



simmat(2:simsize,1) = trilm(1:simsize-1);

simmat(1,2:simsize) = trilm(1:simsize-1);

for i=2:simsize

    simmat(i+1:simsize,i) =trilm((simsize*(i-1))-sum(list(1:i-1))+1:(simsize*i)-sum(list(1:i)));

    simmat(i,i+1:simsize) =trilm((simsize*(i-1))-sum(list(1:i-1))+1:(simsize*i)-sum(list(1:i)));

end



end

%recreating the original tril

%temp = tril(simmat,-1);

%trilmat = temp(temp~=0);