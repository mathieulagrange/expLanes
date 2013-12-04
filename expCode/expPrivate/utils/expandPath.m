function [ out ] = expandPath(in)
%EXPPATH Summary of this function goes here
%   Detailed explanation goes here

if ischar(in)
    out =  stringPath (in);
else
  out = cellfun(@stringPath, in, 'UniformOutput', 0);
end

end

function out =  stringPath (in)

if strcmp(in(1), '~')
    [null, homePath] = system('echo $HOME');
    out = strrep(in, '~', homePath(1:end-1));
else
    out = in;
end

end

