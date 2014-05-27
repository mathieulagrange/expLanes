function syncDirectory(config, serverConfig, directoryName, deleteOld, detach, extensionPath, selector)

if nargin<4, deleteOld=0; end
if nargin<5, detach=0; end
if nargin<6, extensionPath = ''; end
if nargin<7, selector = []; end

if any(strcmp(config.stepName, directoryName))
    directoryPath = [config.dataPath directoryName filesep extensionPath];
    serverDirectoryPath = [serverConfig.dataPath directoryName filesep extensionPath];
else
    directoryPath = [eval(['config.' directoryName 'Path'])  extensionPath];
    serverDirectoryPath = [eval(['serverConfig.' directoryName 'Path'])  extensionPath];
end

syncString = 'rsync -arC    --exclude=.git --update ';
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
if serverConfig.host == config.host
    if ~exist(serverDirectoryPath, 'dir')
        mkdir(serverDirectoryPath);
    end
else
    syncString = [syncString  ' -e ssh '];
%     if system(['ssh -v ' serverConfig.hostName ' '' ls ' serverDirectoryPath ' 2>/dev/null >/dev/null ''']) % TODO remove output when it fails put & ?
%         system(['ssh ' serverConfig.hostName ' ''mkdir -p ' serverDirectoryPath '''']);
%     end
end

switch lower(config.syncDirection(1))
    % TODO special case of local
    case 'u'
        fprintf('from host to server %s\n', serverConfig.hostName);
        ori = directoryPath;
         if serverConfig.host < 2
            dest = serverDirectoryPath;
        else
            dest = [serverConfig.hostName ':' serverDirectoryPath];
        end
%         dest = [serverConfig.hostName ':' serverDirectoryPath];
        excludeString=getExcludeString(config, directoryPath);
    case 'd'
        fprintf('from server %s to host\n', serverConfig.hostName);
        dest = directoryPath;
        excludeString=getExcludeString(serverConfig, serverDirectoryPath);
        
         if serverConfig.host < 2
            ori = serverDirectoryPath;
        else
            ori = [serverConfig.hostName ':' serverDirectoryPath];
        end
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
        if serverConfig.host < 2
            ori = serverDirectoryPath;
        else
            ori = [serverConfig.hostName ':' serverDirectoryPath];
        end
        
end

selectorString = '';
if ~isempty(selector)
    switch selector
        case 'd'
            selectorString = '_data.mat';
            excludeString = [excludeString '--include ''*_data.mat'' --exclude ''*'''];
        case 'o'
            selectorString = '_obs.mat';
            excludeString = [excludeString '--include ''*_obs.mat'' --exclude ''*'''];
    end
end

dest = fileparts(dest(1:end-1));
commandString = [syncString verboseString excludeString ' '  ori(1:end-1) ' ' dest detachString];

if ispc % FIXME will not work on the other side
   commandString= strrep(commandString, 'C:', '/cygdrive/c'); % FIXME build regexp to fix
end
% commandString

if config.syncDirection(1)~='C'
    system(commandString);
end

if lower(config.syncDirection(1))=='c'
    if serverConfig.host ~= config.host
        removeCommand = ['find ' serverDirectoryPath ' -name "*' selectorString '" -maxdepth 1 -print0 | xargs -0 rm -f 2>/dev/null '];
    else
        removeCommand = ['ssh ' serverConfig.hostName ' ''find ' serverDirectoryPath ' -name "*" -maxdepth 1 -print0 | xargs -0 rm -f' ''' 2>/dev/null '];
    end
    
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
fieldNames=config.stepName;
for k=1:length(fieldNames)
    pathName = [config.dataPath fieldNames{k} filesep];
    index = strfind(pathName, directoryPath);
    if  ~strcmp(pathName, directoryPath) && ~isempty(index)
        excludeString = [excludeString ' --filter=''- ' pathName(length(directoryPath):end)  ''''];
    end
end


fieldNames={'code' 'report' 'input' 'bundle'};
for k=1:length(fieldNames)
    pathName = eval(['config.' fieldNames{k} 'Path']);
    index = strfind(pathName, directoryPath);
    if  ~strcmp(pathName, directoryPath) && ~isempty(index)
        excludeString = [excludeString ' --filter=''- ' pathName(length(directoryPath):end)  ''''];
    end
end
