function expSync(config, syncMode, syncDestination, syncDirection, detach, delete)
% expSync(syncMode, syncDestination, syncDirection, detach, delete, config)
%   perform code and data synchronization between host and servers
%
%   syncMode: ['c', 'd', 'i', task_numeric_id] aka code, dependencies, input,
%       tasks as specified by their numeric ids optinally append with s (store) or d (display)
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
        for k=1:length(config.taskName)
            config.syncMode = [config.syncMode sprintf('%d%s ', k, dType)];
        end
    else
    config.syncMode = sprintf('%d ', 1:length(config.taskName));
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
    if ~exist([config.bundlePath config.projectName], 'dir')
        mkdir([config.bundlePath config.projectName]);
    end
    fieldNames=fieldnames(serverConfig);
    for k=1:length(fieldNames)
        if ~isempty(strfind(fieldNames{k}, 'Path')) && isempty(strfind(fieldNames{k}, 'data'))
            serverConfig.(fieldNames{k}) =  [config.bundlePath config.projectName filesep fieldNames{k}(1:end-4)]; 
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
        syncDirectory(config, serverConfig, config.taskName{str2double(tokens{k})}, delete, detach, '', selector);
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
    rmdir([config.bundlePath config.projectName], 's');
end

function syncDependencies(config, serverConfig)

syncString = 'rsync -arC   -e ssh --delete-after --exclude=.git ';

fprintf('Performing DEPENDENCIES sync \n');

if config.localDependencies == 2
     system(['ssh ' serverConfig.hostName ' ''rm -r ' serverConfig.codePath 'dependencies 2>/dev/null ''']);
end

[status, dep] = system(['ssh ' serverConfig.hostName ' '' ls ' serverConfig.codePath 'dependencies ''']);
if status~=2
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
    [p n]=fileparts(dependency);
    dep(strcmp(n, dep))=[];
    command = [syncString strrep(dependency, ' ', '\ ') ' ' serverConfig.hostName ':' serverConfig.codePath 'dependencies'];
    system(command);
    %     end
end
% remove old dependencies
for k=1:length(dep)
    if ~isempty(dep{k})
        system(['ssh ' serverConfig.hostName ' ''rm -r ' serverConfig.codePath 'dependencies' filesep dep{k} ' 2>/dev/null ''']);
    end
end

function syncDirectory(config, serverConfig, directoryName, deleteOld, detach, extensionPath, selector)

if nargin<4, deleteOld=0; end
if nargin<5, detach=0; end
if nargin<6, extensionPath = ''; end
if nargin<7, selector = []; end

if any(strcmp(config.taskName, directoryName))
    directoryPath = [config.dataPath directoryName filesep extensionPath];
    serverDirectoryPath = [serverConfig.dataPath directoryName filesep extensionPath];
else
    directoryPath = [eval(['config.' directoryName 'Path'])  extensionPath];
    serverDirectoryPath = [eval(['serverConfig.' directoryName 'Path'])  extensionPath];
end

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

fprintf('Performing %s %s sync of project %s %s ', upper(directoryName), extensionPath, config.projectName, detachMessage);

% create it if needed
if system(['ssh ' serverConfig.hostName ' '' ls ' serverDirectoryPath ' >/dev/null ''']) % TODO remove output when it fails put & ?
    system(['ssh ' serverConfig.hostName ' ''mkdir -p ' serverDirectoryPath '''']);
end
switch lower(config.syncDirection(1))
    case 'u'
        fprintf('from host to server %s\n', serverConfig.hostName);
        ori = directoryPath;
        dest = [serverConfig.hostName ':' serverDirectoryPath];
        excludeString=getExcludeString(config, directoryPath);
    case 'd'
        fprintf('from server %s to host\n', serverConfig.hostName);
        dest = directoryPath;
        excludeString=getExcludeString(serverConfig, serverDirectoryPath);
        ori = [serverConfig.hostName ':' serverDirectoryPath];
    case 'c'
        fprintf('cleaning host %s\n', serverConfig.hostName);
        if config.syncDirection(1)=='c'
            fprintf('Backed up data is available at %s\n', config.backupPath);
        end
        excludeString=getExcludeString(serverConfig, serverDirectoryPath);
        if ~exist(config.backupPath, 'file')
            mkdir(config.backupPath);
        end
        dest = config.backupPath;
        ori = [serverConfig.hostName ':' serverDirectoryPath ''];
end

if ~isempty(selector)
    switch selector
        case 's'
            excludeString = [excludeString '--include ''*_store.mat'' --exclude ''*'''];
        case 'd'
            excludeString = [excludeString '--include ''*_display.mat'' --exclude ''*'''];
    end
end

commandString = [syncString verboseString excludeString ' '  ori '/ ' dest detachString];
% commandString

if config.syncDirection(1)~='C'
    system(commandString);
end

if lower(config.syncDirection(1))=='c'
    %     removeCommand = ['ssh ' serverConfig.hostName ' ''rm -f ' serverDirectoryPath '* ' ''' 2>/dev/null '];
    removeCommand = ['ssh ' serverConfig.hostName ' ''find ' serverDirectoryPath ' -name "*" -maxdepth 1 -print0 | xargs -0 rm -f' ''' 2>/dev/null '];
    
    system(removeCommand);
end

% remove reduceData
reduceDataFileName = [directoryPath 'reduceData.mat'];
if exist(reduceDataFileName, 'file')
    delete(reduceDataFileName);
end

function excludeString=getExcludeString(config, directoryPath)


% excludeString = ' --filter=''- dependencies''';
excludeString ='';
fieldNames=config.taskName;
for k=1:length(fieldNames)
    pathName = [config.dataPath fieldNames{k} filesep];
    index = strfind(pathName, directoryPath);
    if  ~strcmp(pathName, directoryPath) && ~isempty(index)
        excludeString = [excludeString ' --filter=''- ' pathName(length(directoryPath):end)  ''''];
    end
end


fieldNames={'code' 'report' 'input'};
for k=1:length(fieldNames)
    pathName = eval(['config.' fieldNames{k} 'Path']);
    index = strfind(pathName, directoryPath);
    if  ~strcmp(pathName, directoryPath) && ~isempty(index)
        excludeString = [excludeString ' --filter=''- ' pathName(length(directoryPath):end)  ''''];
    end
end


