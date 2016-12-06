% function [] = mni2tal(x, y, z)
%
% written by Scott D. Slotnick
%
% if you find a bug, report it to sd.slotnick@bc.edu
%
% this function converts from MNI coordinates (i.e. SPM analysis output) 
% to Talairach coordinates
%
% function [] = mni2tal(x, y, z)
%
% example, mni2tal(40, -16, -30)
function [] = mni2tal(x, y, z)
if z >= 0
  xp = round(.99*x);
  yp = round(.9688*y + .0460*z);
  zp = round(-.0485*y + .9189*z);
else
  xp = round(.99*x);
  yp = round(.9688*y + .0420*z);
  zp = round(-.0485*y + .8390*z);
end
[xp yp zp]
