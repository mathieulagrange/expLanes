function expSyncDirectory(config, serverConfig, directoryName, deleteOld, detach, extensionPath, selector)

if nargin<4, deleteOld=0; end
if nargin<5, detach=0; end
if nargin<6, extensionPath = ''; end
if nargin<7, selector = []; end

if any(strcmp(config.stepName, directoryName))
    if selector == 'd'
        directoryPath = [config.dataPath directoryName filesep extensionPath];
        serverDirectoryPath = [serverConfig.dataPath directoryName filesep extensionPath];
        dataType = 'data';
    elseif selector == 'o'
        dataType = 'obs';
        directoryPath = [config.obsPath directoryName filesep extensionPath];
        serverDirectoryPath = [serverConfig.obsPath directoryName filesep extensionPath];
    end
else
    dataType=''; %GREGOIRE => FIXME needed for fprintf ligne 48
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
    case 'b'
        fprintf('Copying %s %s %s of experiment %s %s ', upper(directoryName), dataType, extensionPath, config.experimentName, detachMessage);
        ori = directoryPath;
        dest = serverDirectoryPath;
        excludeString=getExcludeString(config, directoryPath);
    case 'u'
        fprintf('Syncing %s %s %s of experiment %s %s ', upper(directoryName), dataType, extensionPath, config.experimentName, detachMessage);
        fprintf('from host to server %s\n', serverConfig.hostName);
        ori = directoryPath;
        if  serverConfig.host == config.host
            dest = serverDirectoryPath;
        else
            dest = [serverConfig.hostName ':' serverDirectoryPath];
        end
        %         dest = [serverConfig.hostName ':' serverDirectoryPath];
        excludeString=getExcludeString(config, directoryPath);
    case 'd'
        fprintf('Syncing %s %s %s of experiment %s %s ', upper(directoryName), dataType, extensionPath, config.experimentName, detachMessage);
        fprintf('from server %s to host\n', serverConfig.hostName);
        dest = directoryPath;
        excludeString=getExcludeString(serverConfig, serverDirectoryPath);
        
        if serverConfig.host == config.host
            ori = serverDirectoryPath;
        else
            ori = [serverConfig.hostName ':' serverDirectoryPath];
        end
    case 'c'
        fprintf('Cleaning %s %s %s of experiment %s %s ', upper(directoryName), dataType, extensionPath, config.experimentName, detachMessage);
        fprintf('on host %s\n', serverConfig.hostName);
%         if ~isempty(config.backupPath)
%             fprintf('Backed up data is available at %s\n', config.backupPath);
%         end
        excludeString=getExcludeString(serverConfig, serverDirectoryPath);
        if ~isempty(config.backupPath) && ~exist(config.backupPath, 'file')
            mkdir(config.backupPath);
        end
        dest = config.backupPath;
        if serverConfig.host  == config.host
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
            excludeString = [excludeString '--include ''*/*_data.mat'' --exclude ''*/*'''];
        case 'o'
            selectorString = '_obs.mat';
            excludeString = [excludeString '--include ''*/*_obs.mat'' --exclude ''*/*'''];
    end
end

if ~isempty(dest)
    if any(strcmp(dest(end), {'\', '/'}))
        dest = dest(1:end-1);
    end
    if any(strcmp(ori(end), {'\', '/'}))
        ori = ori(1:end-1);
    end
    dest = fileparts(dest);
    
    commandString = [syncString verboseString excludeString ' '  ori ' ' dest detachString];
    
    if ispc % FIXME will not work on the other side
        commandString= strrep(commandString, 'C:', '/cygdrive/c'); % FIXME build regexp to fix
        commandString= strrep(commandString, '\', '/');
    end
    % commandString
    
    if config.syncDirection(1)~='C'
        system(commandString);
    end
end

if lower(config.syncDirection(1)) == 'c'
    if serverConfig.host == config.host
        removeCommand = ['find ' serverDirectoryPath ' -name "*' selectorString '"  -print0 | xargs -0 rm -f 2>/dev/null  '];
    else
        removeCommand = ['ssh ' serverConfig.hostName ' ''find ' serverDirectoryPath ' -name "*"  -print0 | xargs -0 rm -f' ''' 2>/dev/null '];
    end    
    system(removeCommand);
end

% remove reduceData files
files = dir([directoryPath 'reduceData*']);
for k=1:length(files)
reduceDataFileName = [directoryPath files(k).name];
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


fieldNames={ 'input' 'export'}; % FIXME  too old code report
for k=1:length(fieldNames)
    pathName = eval(['config.' fieldNames{k} 'Path']);
    index = strfind(pathName, directoryPath);
    if  ~strcmp(pathName, directoryPath) && ~isempty(index)
        excludeString = [excludeString ' --filter=''- ' pathName(length(directoryPath)+1:end)  ''''];
    end
end
