function expSync(config, syncMode, syncDestination, syncDirection, detach, delete)
% expSync(syncMode, syncDestination, syncDirection, detach, delete, config)
%   perform code and data synchronization between host and servers
%
%   syncMode: ['c', 'd', 'i', task_numeric_id] code, dependencies, input,
%       tasks as specified by their numeric ids
%   syncDestination: host numeric id
%   syncDirection: ['up', 'down'], from host to server and vice versa
%   detach: [0,1], default 0, sync in background mode
%   delete: [0,1], default 0, delete non existing files (with backup)
%

% if ~exist('config', 'var'), config = expConfig(); end


if ~isfield(config, 'syncMode'),
    config.syncMode = sprintf('%d', 1:length(config.taskName));
end


if exist('syncMode', 'var')
    if isnumeric(syncMode)
    config.syncMode = sprintf('%d', syncMode);
    else
        config.syncMode = syncMode; 
    end
end

if exist('syncDirection', 'var'),
    if isempty(syncDirection), syncDirection = 'down'; end
    config.syncDirection = syncDirection;
else
    if ~isfield(config, 'syncDirection'),
        if isletter(config.syncMode(1))
            config.syncDirection = 'up';
        else
            config.syncDirection = 'down';
        end
    end
end

if ~exist('delete', 'var'), delete = 0; end
if ~exist('detach', 'var'),
    if config.syncMode(1)=='i',
        detach = 1;
    else
        detach = 0;
    end
end



if ~exist('syncDestination', 'var'),
    if config.syncDirection == 'c'
        syncDestination = 1;
    else
        syncDestination = 2;
    end
end

serverConfig = expConfig(config.codePath, {'host', syncDestination});

if syncDestination==-1
    % bundle mode
    if ~exist([config.bundlePath config.projectName], 'dir')
        mkdir([config.bundlePath config.projectName]);
    end
    fieldNames=fieldnames(serverConfig);
    for k=1:length(fieldNames)
        if ~isempty(strfind(fieldNames{k}, 'Path')) && isempty(strfind(fieldNames{k}, 'root'))
            serverConfig.(fieldNames{k}) = strrep(serverConfig.(fieldNames{k}), serverConfig.rootPath, [config.bundlePath config.projectName filesep]);
        end
    end
    serverConfig.codePath = [config.bundlePath config.projectName filesep 'code' filesep];
end

% TODO what if some directories are unset ?
% TODO put options for detach verbosity, update...
for k=1:length(config.syncMode)
    if isletter(config.syncMode(k))
        switch config.syncMode(k)
            case 'd'
                syncDependencies(config, serverConfig);
            case 'c'
                syncDirectory(config, serverConfig, 'code', delete, detach);
            case 'i'
                dataBaseModeIndex = find(strcmp(config.modeNames, 'dataBase'));
                if ~isempty(dataBaseModeIndex)
                    dataBases = config.modeValues{dataBaseModeIndex};
                    for k=1:length(dataBases)
                        syncDirectory(config, serverConfig, 'input', delete, detach, dataBases{k});
                    end
                else
                    syncDirectory(config, serverConfig, 'input', delete, detach);
                end
            otherwise
                disp('Wrong request');
        end
    else
        syncDirectory(config, serverConfig, config.taskName{str2double(config.syncMode(k))}, delete, detach);
    end
end

if syncDestination==-1
    %  save bundle config
    fid = fopen([serverConfig.codePath '/_bundle_' serverConfig.projectName 'Config' serverConfig.userName '.txt'], 'w');
    fprintf(fid, '%% Bundle config file for the %s project\n%% Adapt at your convenience\n\n', serverConfig.projectName);
    configFields = fieldnames(serverConfig);
    for k=1:length(configFields)
        if ischar(serverConfig.(configFields{k}))
            fprintf(fid, '%s = %s\n', configFields{k}, serverConfig.(configFields{k}));
        elseif isnumeric(serverConfig.(configFields{k}))
            fprintf(fid, '%s = %d\n', configFields{k}, serverConfig.(configFields{k}));
        end
    end
    fclose(fid);
    
    bundleName = [config.projectName '_' num2str(config.versionName) '_' date() '.tgz' ];
    system(['cd ' config.bundlePath ' && tar czf '  bundleName ' ' config.projectName]);
    rmdir([config.bundlePath config.projectName], 's');
end

function syncDependencies(config, serverConfig)

syncString = 'rsync -arC   -e ssh --delete-after --exclude=.git ';

fprintf('\n /////// Performing DEPENDENCIES sync ');

for k=1:length(config.dependencies)
    %     if ~isempty(config.dependencies{k}) && (config.dependencies{k}(1) == '\' || config.dependencies{k}(1) == '/' || config.dependencies{k}(1) == '~')
    if any(strcmp({'/', '\'}, config.dependencies{k}(end)))
        dependency = config.dependencies{k}(1:end-1);
    else
        dependency = config.dependencies{k};
    end
    command = [syncString strrep(dependency, ' ', '\ ') ' ' serverConfig.hostName ':' serverConfig.codePath 'dependencies'];
    system(command);
    %     end
end

function syncDirectory(config, serverConfig, directoryName, deleteOld, detach, extensionPath)

if nargin<4, deleteOld=0; end
if nargin<5, detach=0; end
if nargin<6, extensionPath = ''; end

directoryPath = [eval(['config.' directoryName 'Path']) extensionPath filesep];
serverDirectoryPath = [eval(['serverConfig.' directoryName 'Path']) extensionPath filesep];

syncString = 'rsync -arC   -e ssh  --exclude=.git --update ';
deleteString = [' --delete-after --backup --backup-dir=' config.backupPath ' '];
if detach
    detachString = ' >/dev/null &';
    detachMessage = 'in silent and detached mode';
    verboseString = '';
else
    detachString = '';
    detachMessage = '';
    verboseString = '-v ';
end
if deleteOld
    syncString = [syncString deleteString];
    disp(['Deletion is selected. Backed up data is available at ', config.backupPath])
end


% a: archive mode
% C: exclude cvs like files
% update: skip newer files

% TODO: be able to control update
% TODO: use the filesep command

fprintf('\n /////// Performing %s %s sync of project %s %s ', upper(directoryName), extensionPath, config.projectName, detachMessage);

% create it if needed
if system(['ssh ' serverConfig.hostName ' '' ls ' serverDirectoryPath ' >/dev/null ''']) % TODO remove output when it fails put & ?
    system(['ssh ' serverConfig.hostName ' ''mkdir -p ' serverDirectoryPath '''']);
end
switch lower(config.syncDirection(1))
    case 'u'
        fprintf('from host to server %s\n', serverConfig.hostName);
        ori = directoryPath;
        dest = [serverConfig.hostName ':' serverDirectoryPath];
        excludeString=getExcludeString(config, directoryName, directoryPath);
    case 'd'
        fprintf('from server %s to host\n', serverConfig.hostName);
        dest = directoryPath;
        excludeString=getExcludeString(serverConfig, directoryName, serverDirectoryPath);
        ori = [serverConfig.hostName ':' serverDirectoryPath];
    case 'c'
        fprintf('cleaning host %s\n', serverConfig.hostName);
        if config.syncDirection(1)=='c'
            fprintf('Backed up data is available at %s\n', config.backupPath);
        end
        excludeString=getExcludeString(serverConfig, directoryName, serverDirectoryPath);
        if ~exist(config.backupPath, 'file')
            mkdir(config.backupPath);
        end
        dest = config.backupPath;
        ori = [serverConfig.hostName ':' serverDirectoryPath ''];
end
commandString = [syncString verboseString excludeString ' '  ori '/ ' dest detachString];
% commandString

if config.syncDirection(1)~='C'
    system(commandString);
end

if lower(config.syncDirection(1))=='c'
    system(['ssh ' serverConfig.hostName ' ''rm -f ' serverDirectoryPath '* ' ''' 2>/dev/null ']);
end

function excludeString=getExcludeString(config, directoryName, directoryPath)


% excludeString = ' --filter=''- dependencies''';
excludeString ='';
fieldNames=['code' 'display' 'input' config.taskName];
for k=1:length(fieldNames)
    if  isempty(strfind(fieldNames{k}, directoryName))
        excludeString = [excludeString ' --filter=''- ' config.([fieldNames{k} 'Path']) ''''];
    end
end

excludeString = regexprep(excludeString, directoryPath, '');
