function expPath()

p = fileparts(mfilename('fullpath'));
addpath(p);
addpath(genpath([p '/expPrivate']));
