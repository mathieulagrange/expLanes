function expTools(config)

if ispc
    null = 'NUL';
    separator = ';';
else
    null = '/dev/null 2>/dev/null';
    separator = ':';
end

sysPath = getenv('PATH');
if ~iscell(config.toolPath) % FIX ME failing in server mode
    config.toolPath  = {config.toolPath};
end

for k=1:length(config.toolPath)
    if isempty(strfind(sysPath, config.toolPath{k}))
        setenv('PATH', [sysPath separator config.toolPath{k}]);
    end
end
sysPath = getenv('PATH');
commands = {'pdflatex', 'rsync', 'ssh', 'screen'};

% config.toolPath

if config.probe
    disp('**** Probing tools...');
    disp(['SYSTEM PATH: ' sysPath]);
    
    for k=1:length(commands)
        
        switch commands{k}
            case {'pdflatex', 'rsync'}
            status = system([commands{k} ' --help > ' null]);
            case 'ssh'
            [ status message] = system([commands{k} ' -V > ' null]);
            if status, ssh=0;else ssh=1;end
            case 'screen'
                [status message] = system([commands{k} ' -v']);
                if strfind(message, 'Screen'), status = 0; end
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
        disp('**** Probing hosts (ssh login with empty passphrase needed. Hosts shall be in your ssh known hosts.)')
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