function [ out ] = expandHomePath(in)
%EXPPATH Summary of this function goes here
%   Detailed explanation goes here

if ischar(in)
    out =  stringPath (in);
else
  out = cellfun(@stringPath, in, 'UniformOutput', 0);
end

function out =  stringPath (in)

in = strrep(in, '\', '/');

if ~isempty(in) && strcmp(in(1), '~')
   if ispc; 
       homePath= getenv('USERPROFILE'); 
   else
       homePath= getenv('HOME');
   end
   out = strrep(in, '~', homePath);
else    
    out = in;
end
