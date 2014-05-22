function expTools(config)

for k=1:length(config.toolPath)
    sysPath = getenv('PATH');
    if isempty(strfind(sysPath, config.toolPath{k}))
        setenv('PATH', [sysPath ':' config.toolPath{k}]);
    end
end

commands = {'pdflatex', 'rsync', 'ssh'};

if config.probe
    for k=1:length(commands)
        system([commands{k} ' --help'])
    end
end