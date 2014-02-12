function syncDependencies(config, serverConfig)

fprintf('Performing DEPENDENCIES sync \n');

if config.localDependencies == 2
    if serverConfig.host < 2
        rmdir([serverConfig.codePath 'dependencies']);
    else
        system(['ssh ' serverConfig.hostName ' ''rm -r ' serverConfig.codePath 'dependencies 2>/dev/null ''']);
    end
end

% TODO fix this using storage of info
if serverConfig.host < 2
    [status, dep] = system(['ls ' serverConfig.codePath 'dependencies']);
else
    [status, dep] = system(['ssh ' serverConfig.hostName ' '' ls ' serverConfig.codePath 'dependencies ''']);
end
if status == 0
    dep = regexp(dep, '\n', 'split');
else
    dep = {};
end

for k=1:length(config.dependencies)
    %     if ~isempty(config.dependencies{k}) && (config.dependencies{k}(1) == '\' || config.dependencies{k}(1) == '/' || config.dependencies{k}(1) == '~')
    if any(strcmp({'/', '\'}, config.dependencies{k}(end)))
        dependency = config.dependencies{k}(1:end-1);
    else
        dependency = config.dependencies{k};
    end
    if ~any(strcmp({'/', '\'}, dependency(1)))
        dependency = [config.codePath filesep dependency];
    end
    [p n]=fileparts(dependency);
    dep(strcmp(n, dep))=[];
    if serverConfig.host < 2
        syncString = 'rsync -arC --delete-after --exclude=.git ';
        command = [syncString strrep(dependency, ' ', '\ ') ' '  serverConfig.codePath 'dependencies'];
    else
        syncString = 'rsync -arC   -e ssh --delete-after --exclude=.git ';
        command = [syncString strrep(dependency, ' ', '\ ') ' ' serverConfig.hostName ':' serverConfig.codePath 'dependencies'];
    end
    system(command);
    %     end
end

% remove old dependencies
for k=1:length(dep)
    if ~isempty(dep{k})
        if serverConfig.host < 2
            rmdir([serverConfig.codePath 'dependencies' filesep dep{k}]);
        else
            system(['ssh ' serverConfig.hostName ' ''rm -r ' serverConfig.codePath 'dependencies' filesep dep{k} ' 2>/dev/null ''']);
        end
    end
end
