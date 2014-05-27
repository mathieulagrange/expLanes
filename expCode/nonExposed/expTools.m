function expTools(config)

sysPath = getenv('PATH');
if ~iscell(config.toolPath) % FIX ME failing in server mode
    config.toolPath  = {config.toolPath};
end
for k=1:length(config.toolPath)
    if isempty(strfind(sysPath, config.toolPath{k}))
        setenv('PATH', [sysPath ':' config.toolPath{k}]);
    end
end
sysPath = getenv('PATH');
commands = {'pdflatex', 'rsync', 'ssh'};

% config.toolPath

if config.probe
    disp('**** Probing tools...');
    disp(['SYSTEM PATH: ' sysPath]);
    
    for k=1:length(commands)
        if any(k==[1 2])
            status = system([commands{k} ' --help >/dev/null 2>/dev/null']);
        else
            [ status message] = system([commands{k} ' -V >/dev/null 2>/dev/null']);
            if status, ssh=0;else ssh=1;end
        end
        if status
            disp([commands{k} ' not found.']);
        else
            disp(['Found ' commands{k} '.']);
        end
    end
    disp(' ');
    disp('**** Probing paths (some paths will be created if needed)')
    disp(' ');
    fieldNames=fieldnames(config);
    for k=1:length(fieldNames)
        if ~isempty(strfind(fieldNames{k}, 'Path')) && all(~strcmp(fieldNames{k}, {'matlabPath', 'toolPath'}))
            field = config.(fieldNames{k});
            
            if exist(field, 'dir')
                disp([fieldNames{k} ' found : ' field]);
            else
                disp([ fieldNames{k} ' not found : ' field]);
            end
        end
    end
    disp(' ');
    if ssh
        disp('**** Probing hosts (ssh login with empty passphrase needed)')
        disp(' ');
        for k=1:length(config.machineNames)
            if ~iscell(config.machineNames{k})
                config.machineNames{k} = {config.machineNames{k}};
            end
            for m=1:length(config.machineNames{k})
                status = system(['ssh ' config.machineNames{k}{m}  ' exit ']);
                if status
                    disp(['Host ' config.machineNames{k}{m}  ' not found.']);
                else
                    disp(['Host ' config.machineNames{k}{m}  ' found.']);
                end
            end
        end
    else
        disp('Not probing hosts as ssh is not available');
    end
    
    
end