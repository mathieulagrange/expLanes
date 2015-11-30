function expSync(config, syncMode, syncDestination, syncDirection, detach, delete)
% expSync(syncMode, syncDestination, syncDirection, detach, delete, config)
%   perform code and data synchronization between host and servers
%
%   syncMode: ['c', 'd', 'i', step_numeric_id] aka code, dependencies, input,
%       steps as specified by their numeric ids optionally append with d (data) or o (observations)
%   syncDestination: host numeric id
%   syncDirection: ['up', 'down'], from host to server and vice versa
%   detach: [0,1], default 0, sync in background setting
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
    serverConfig = expConfig(config.codePath, config.experimentName, config.shortExperimentName, {'host', syncDestination, 'attachedMode', 0});
% serverConfig.host = config.host;
end

if syncDestination<0
    % bundle setting
    config.syncDirection = 'b';
    if ~exist([config.exportPath config.experimentName], 'dir')
        mkdir([config.exportPath config.experimentName]);
    end
    fieldNames=fieldnames(serverConfig);
    for k=1:length(fieldNames)
        if any(~cellfun(@isempty, strfind({'dataPath', 'inputPath'}, fieldNames{k}))) % && isempty(strfind(fieldNames{k}, 'data'))
            serverConfig.(fieldNames{k}) =  [config.exportPath config.experimentName '/' fieldNames{k}(1:end-4) '/'];
        end
    end
    serverConfig.codePath = [config.exportPath config.experimentName '/'];
    serverConfig.dataPath =   [serverConfig.codePath 'data/'];
    serverConfig.obsPath =   serverConfig.dataPath;
end

% TODO what if some directories are unset ?
% TODO put options for detach verbosity, update...

tokens = regexp(config.syncMode, ' ', 'split');
bundle = find(strcmp(tokens, 'z'));
if ~isempty(bundle)
   tokens(bundle) = []; 
end

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
                expSyncDependencies(config, serverConfig);
            case 'c'
                expSyncDirectory(config, serverConfig, 'code', delete, detach);
            case 'i'
                dataBaseSettingIndex = find(strcmp(config.factors.names, 'dataBase'));
                if ~isempty(dataBaseSettingIndex)
                    dataBases = config.factors.values{dataBaseSettingIndex};
                    for l=1:length(dataBases)
                        expSyncDirectory(config, serverConfig, 'input', delete, detach, dataBases{l});
                    end
                else
                    expSyncDirectory(config, serverConfig, 'input', delete, detach);
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
        if isempty(selector) || selector == 'd'
            expSyncDirectory(config, serverConfig, config.stepName{str2double(tokens{k})}, delete, detach, '', 'd');
        end
        if isempty(selector) || selector == 'o'
            expSyncDirectory(config, serverConfig, config.stepName{str2double(tokens{k})}, delete, detach, '', 'o');
        end
    end
end

if syncDestination<0
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
    exportConfig = expExportConfig(config.configFileName);
    expConfigStringSave(exportConfig, [serverConfig.codePath '/config/' serverConfig.experimentName 'ConfigDefault.txt']);
    
    if ~isempty(bundle)
    bundleName = [config.experimentName '_' num2str(config.codeVersion) '_' date() '.zip' ];
    zip([config.exportPath bundleName], config.experimentName, config.exportPath);

    warning('off', 'MATLAB:RMDIR:NoDirectoriesRemoved');
    rmdir([config.exportPath config.experimentName], 's');
    warning('on', 'MATLAB:RMDIR:NoDirectoriesRemoved');
    fprintf('Bundle is available at: %s%s\n:', config.exportPath, bundleName);
    end
end





