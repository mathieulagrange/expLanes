function expProbe(config)

if ispc
    null = 'NUL';
else
    null = '/dev/null 2>/dev/null';
end

sysPath = getenv('PATH');
commands = {'pdflatex', 'rsync', 'ssh', 'screen'};


if ~config.probe || config.probe == 1
    disp('**** Probing tools...');
    disp(['SYSTEM PATH: ' sysPath]);
    for k=1:length(commands)
        
        switch commands{k}
            case {'pdflatex', 'rsync'}
                status = system([commands{k} ' --help > ' null]);
            case 'ssh'
                [ status, message] = system([commands{k} ' -V > ' null]);
                if status, ssh=0;else ssh=1;end
            case 'screen'
                [status, message] = system([commands{k} ' -v']);
                if strfind(message, 'Screen'), status = 0; end
        end
        if status
            fprintf(2, '%s not found.\n', commands{k});
        else
            disp(['Found ' commands{k} '.']);
        end
    end
    disp(' ');
end
if ~config.probe || config.probe == 1
    disp('**** Probing paths (some paths will be created if needed)')
    disp(' ');
    fieldNames=fieldnames(config);
    for k=1:length(fieldNames)
        if ~isempty(strfind(fieldNames{k}, 'Path')) && all(~strcmp(fieldNames{k}, {'matlabPath', 'toolPath'}))
            field = config.(fieldNames{k});
            
            if exist(field, 'dir')
                disp([fieldNames{k} ' found : ' field]);
            else
                fprintf(2, '%s not found : %s\n', fieldNames{k}, field);
            end
        end
    end
    disp(' ');
end
if ~config.probe || config.probe == 3
    if ssh
        disp('**** Probing hosts (ssh login with empty passphrase needed. Hosts shall be in your ssh known hosts.)')
        disp(' ');
        for k=1:length(config.machineNames)
            if ~iscell(config.machineNames{k})
                config.machineNames{k} = config.machineNames(k); %  {config.machineNames{k}};
            end
            for m=1:length(config.machineNames{k})
                status = system(['ssh ' config.machineNames{k}{m}  ' exit ']);
                if status
                    fprintf(2, 'Host %s not found.\n', config.machineNames{k}{m});
                else
                    disp(['Host ' config.machineNames{k}{m}  ' found.']);
                end
            end
        end
    else
        disp('Not probing hosts as ssh is not available');
    end
end