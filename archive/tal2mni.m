% function [] = tal2mni(x, y, z)
%
% This script was written by Lauren R. Moo and is intended for free use by the neuroimaging community
%
% Modified 1/08/05, for updated version see http://www.wjh.harvard.edu/~slotnick/scripts.htm
%
% This script should not be used, in full or part, for financial gain
%
% Use at your own risk
%
% If you find a bug, please e-mail lmoo@partners.org
%
%
% This function converts from Talairach coordinates to MNI coordinates
%
% function [] = tal2mni(x, y, z)
%
% For example, tal2mni(40, -17, -24)
function [] = tal2mni(x, y, z)
a=0.99;
b=0.9688;
c=0.0460;
d=-0.0485;
e=0.9189;
f=0.0420;
g=0.8390;

if (z-d*y)/e >= 0
  xm = round(x/a);
  ym = round((e*y)/(b*e-c*d) - (c*z)/(b*e-c*d));
  zm = round((z/e) - (d/e)*((e*y-c*z)/(b*e-c*d)));
else
  xm = round(x/a);
  ym = round((e*y)/(b*e-f*d) - (f*z)/(b*e-f*d));
  zm = round((z/g) - (d/g)*((e*y-c*z)/(b*e-c*d)));
end
[xm ym zm]
