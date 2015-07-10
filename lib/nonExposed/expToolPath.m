function expToolPath(config)

if ispc
    separator = ';';
else
    separator = ':';
end

sysPath = getenv('PATH');
if ~iscell(config.toolPath) % FIX ME failing in server mod
    config.toolPath  = {config.toolPath};
end

for k=1:length(config.toolPath)
    if isempty(strfind(sysPath, config.toolPath{k}))
        setenv('PATH', [sysPath separator config.toolPath{k}]);
    end
end

