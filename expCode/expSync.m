function expSync(config, syncMode, syncDestination, syncDirection, detach, delete)
% expSync(syncMode, syncDestination, syncDirection, detach, delete, config)
%   perform code and data synchronization between host and servers
%
%   syncMode: ['c', 'd', 'i', step_numeric_id] aka code, dependencies, input,
%       steps as specified by their numeric ids optionally append with s (store) or d (display)
%   syncDestination: host numeric id
%   syncDirection: ['up', 'down'], from host to server and vice versa
%   detach: [0,1], default 0, sync in background mode
%   delete: [0,1], default 0, delete non existing files (with backup)
%
% if ~exist('config', 'var'), config = expConfig(); end

if exist('syncMode', 'var')
    if isnumeric(syncMode)
    config.syncMode = sprintf('%d', syncMode);
    else
        config.syncMode = syncMode; 
    end
end

if ~isfield(config, 'syncMode') || strcmp(config.syncMode(1), '0')
    if strcmp(config.syncMode(1), '0') && length(config.syncMode)==2
        dType = config.syncMode(2);
        config.syncMode =[];
        for k=1:length(config.stepName)
            config.syncMode = [config.syncMode sprintf('%d%s ', k, dType)];
        end
    else
    config.syncMode = sprintf('%d ', 1:length(config.stepName));
    end
end

if ~exist('delete', 'var'), delete = 0; end

if ~exist('syncDestination', 'var'),
        syncDestination = 2;
end

if isstruct(syncDestination)
    serverConfig = syncDestination;
    syncDestination = serverConfig.host;
else
    serverConfig = expConfig(config.codePath, config.shortProjectName, {'host', syncDestination});
end

if syncDestination==-1
    % bundle mode
    config.syncDirection = 'up';
    if ~exist([config.bundlePath config.projectName], 'dir')
        mkdir([config.bundlePath config.projectName]);
    end
    fieldNames=fieldnames(serverConfig);
    for k=1:length(fieldNames)
        if any(~cellfun(@isempty, strfind({'dataPath', 'inputPath'}, fieldNames{k}))) % && isempty(strfind(fieldNames{k}, 'data'))
            serverConfig.(fieldNames{k}) =  [config.bundlePath config.projectName filesep fieldNames{k}(1:end-4) filesep]; 
        end
    end
    serverConfig.codePath = [config.bundlePath config.projectName filesep];
end

% TODO what if some directories are unset ?
% TODO put options for detach verbosity, update...

tokens = regexp(config.syncMode, ' ', 'split');

for k=1:length(tokens)
    if exist('syncDirection', 'var'),
        if isempty(syncDirection), syncDirection = 'down'; end
        config.syncDirection = syncDirection;
    else
        if ~isfield(config, 'syncDirection'),
            if isletter(tokens{k})
                config.syncDirection = 'up';
            else
                config.syncDirection = 'down';
            end
        end
    end
    
    if ~exist('detach', 'var'),
        if tokens{k}=='i',
            detach = 1;
        else
            detach = 0;
        end
    end   
    
    if isletter(tokens{k})
        switch tokens{k}
            case 'd'
                syncDependencies(config, serverConfig);
            case 'c'
                syncDirectory(config, serverConfig, 'code', delete, detach);
            case 'i'
                dataBaseVariantIndex = find(strcmp(config.variantSpecifications.names, 'dataBase'));
                if ~isempty(dataBaseVariantIndex)
                    dataBases = config.variantValues{dataBaseVariantIndex};
                    for k=1:length(dataBases)
                        syncDirectory(config, serverConfig, 'input', delete, detach, dataBases{k});
                    end
                else
                    syncDirectory(config, serverConfig, 'input', delete, detach);
                end
            otherwise
                disp('Wrong request');
        end
    elseif ~isempty(tokens{k})
        if isletter(tokens{k}(end))
            selector = tokens{k}(end);
            tokens{k} =  tokens{k}(1:end-1);
        else
            selector = [];
        end
        syncDirectory(config, serverConfig, config.stepName{str2double(tokens{k})}, delete, detach, '', selector);
    end
end

if syncDestination==-1
    % moving config files
    saveConfigDir = [serverConfig.codePath 'config/savedConfigFiles'];
    if ~exist(saveConfigDir, 'dir')
        mkdir(saveConfigDir);
    end
    files = dir([serverConfig.codePath 'config/*Config*.txt']);
    for k=1:length(files)
       movefile([serverConfig.codePath 'config/' files(k).name], [serverConfig.codePath 'config/savedConfigFiles']); 
    end
    %  create bundle config
    bundleConfig = expBundleConfig(config.configFileName);
    expConfigStringSave(bundleConfig, [serverConfig.codePath '/config/' serverConfig.projectName 'ConfigDefault.txt']);
    
    
    bundleName = [config.projectName '_' num2str(config.versionName) '_' date() '.tgz' ];
    system(['cd ' config.bundlePath ' && tar czf '  bundleName ' ' config.projectName]);  
    warning off;
    rmdir([config.bundlePath config.projectName], 's');
    warning on;
end





