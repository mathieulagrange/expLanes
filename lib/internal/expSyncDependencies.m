function expSyncDependencies(config, serverConfig)

fprintf('Performing DEPENDENCIES sync \n');

if config.localDependencies == 2
    if config.host == serverConfig.host
        if exist([serverConfig.codePath 'dependencies'], 'dir')
            rmdir([serverConfig.codePath 'dependencies']);
        end
    else
        system(['ssh ' serverConfig.hostName ' ''rm -r ' serverConfig.codePath 'dependencies 2>/dev/null ''']);
    end
end

% TODO fix this using storage of info
if serverConfig.host == config.host
    [status, dep] = system(['ls -1 ' serverConfig.codePath 'dependencies']);
else
    [status, dep] = system(['ssh ' serverConfig.hostName ' '' ls -1 ' serverConfig.codePath 'dependencies ''']);
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
    if ~any(strcmp({'/', '\', '~'}, dependency(1)))
        dependency = [config.codePath filesep dependency];
    end
    [p, n, e]=fileparts(dependency);
    dep(strcmp([n e], dep))=[];
    if serverConfig.host  == config.host
        syncString = 'rsync -arC --delete-after --exclude=.git ';
        command = [syncString strrep(dependency, ' ', '\ ') ' '  serverConfig.codePath 'dependencies'];
    else
        syncString = 'rsync -arC   -e ssh --delete-after --exclude=.git '; % --exclude=*.mex* '; % FIXME really needed ?
        command = [syncString strrep(dependency, ' ', '\ ') ' ' serverConfig.hostName ':' serverConfig.codePath 'dependencies'];
    end
    
    if ispc % FIXME will not work on the other side
        command= strrep(command, 'C:', '/cygdrive/c'); % FIXME build regexp to fix
        command= strrep(command, '\', '/'); % FIXME build regexp to fix
    end
    
    system(command);
    %     end
end

% remove old dependencies
for k=1:length(dep)
    if ~isempty(dep{k})
        if serverConfig.host == config.host
            rmdir([serverConfig.codePath 'dependencies' filesep dep{k}]);
        else
            system(['ssh ' serverConfig.hostName ' ''rm -r ' serverConfig.codePath 'dependencies' filesep dep{k} ' 2>/dev/null ''']);
        end
    end
end
