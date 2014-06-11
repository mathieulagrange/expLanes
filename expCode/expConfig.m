function config = expConfig(projectPath, projectName, shortProjectName, commands)

% TODO command to purge server code base

% TODO default still in title
% TODO seed index after resampling ?
% TODO expCreate diamond ??
% TODO 'host' 1 on  linux -> matlab path ?
% TODO symbolic link to data, issue with rsync and issues with path generation ?
% TODO renaming .mat function when adding factor
% TODO convert disp by expLog

% TODO creation of .expCode data at each run of config ??

% FIXME fails to attach config file

% FIXME store dependency string and force localDep = 2 if different

% FIXME status of time as unique metric

% FIXME missing info in confusion Matrix

% TODO help command

% sync obs / data with different paths

% TODO set current host with hostName (<0 detached server mode >0 attached mode 0 auto mode, Inf debug mode)

% FIXME issue with toolpath on server mode

% FIXME number of succesful settings wrong

%userDefaultConfigFileName = expUserDefaultConfig();

% TODO test validity of submitted mask

% FIXME test still in store ??

if ~isempty(commands) && isstruct(commands{1})
    config = commands{1};
    commands = commands(2:end);
else
    configFileName = getUserFileName(shortProjectName, projectName, projectPath);
    config = expUpdateConfig(configFileName);
    config.shortProjectName = shortProjectName;
    config.userName = getUserName();
    config.projectName = projectName;
    config.projectPath = projectPath;
    config.configFileName = configFileName;
end

config.staticDataFileName = [projectPath '/config' '/' shortProjectName];
if ~exist(config.staticDataFileName, 'file')
    runId=1;
    save(config.staticDataFileName, 'runId');
end
staticData = load(config.staticDataFileName);
[p, projectName] = fileparts(projectPath);

detectedHostName = char(getHostName(java.net.InetAddress.getLocalHost));
disp(['detectedHostName: ' detectedHostName]);

if isempty(config.completeName)
    config.completeName = config.userName;
end

config.factorFileName = [projectPath '/' config.shortProjectName 'Factors.txt'];
config.stepName = expStepName(config.projectPath, config.shortProjectName);
config.factors = expFactorParse(config.factorFileName, length(config.stepName));

% checking maximal length of data files
fileLength = 0;
switch config.namingConventionForFiles
    case 'long'
        fileLength = sum(cellfun(@length, config.factors.names)+1);
        for k=1:length(config.factors.stringValues)
            valueLength(k) = max(cellfun(@length, config.factors.stringValues{k}));
        end
        fileLength = fileLength+sum(valueLength+1);
    case 'short'
        fileLength = sum(cellfun(@length, config.factors.shortNames)+1);
        for k=1:length(config.factors.shortValues)
            valueLength(k) = max(cellfun(@length, config.factors.shortValues{k}));
        end
        fileLength = fileLength+sum(valueLength+1);
end
if fileLength && fileLength>512
    warning('Following your factors definition, the longer data file name may exceed the possible range of the file system (512). Please consider using the hash based naming convention.')
end

if nargin>3,
    configOri = config;
    %     if ~mod(nargin, 2)
    config = commandLine(config, commands);
    %     else
    %         config = commandLine(config, commands(2:end));
    %     end
    if isnumeric(config.mask)
        if config.mask==0
            config.mask = {{}};
            elseexit
            config.mask = configOri.mask(config.mask);
        end
    end
end

if iscell(config.mask)
    if isempty(config.mask) || ~iscell(config.mask{1})
        config.mask = {config.mask};
    end
end

config = expDesign(config);

config.attachedMode = 1;
if nargin<1 || config.host==0
    config.host = 0;
    for k=1:length(config.machineNames)
        id = find(strcmp(config.machineNames{k}, detectedHostName));
        if ~isempty(id)
            config.host = k;
            config.hostName = config.machineNames{k}{id(1)};
        end
    end
    if config.host==0
        error(['Unable to find the detected host ' detectedHostName  ' in the machineNames field of your configuration file. Either explicitely set the host number (''host'', <value>) or add ' detectedHostName ' to the list of your machines in your config file.']);
    end
else
    if config.host>0
        config.attachedMode = 0;
    end
    config.host = abs(config.host);
    if config.host == floor(config.host)
        if iscell(config.machineNames{config.host})
            config.hostName = config.machineNames{config.host}{1};
        else
            config.hostName = config.machineNames{config.host};
        end
    else
        config.hostName = config.machineNames{floor(config.host)}{floor(rem(config.host, 1)*10)};
        config.host = floor(config.host);
    end
end

% if config.resume
%     config.runId = config.resume;
% else
config.runId = staticData.runId;
if config.host
    runId = config.runId+1; %#ok<NASGU>
    save(config.staticDataFileName, 'runId', '-append');
    config.runId = runId;
end
% end
if isfield(staticData, 'waitbarId') && isobject(staticData.waitbarId)
    delete(staticData.waitbarId);
end
config.waitBar = [];
config.progressId = 0;
config.displayData.prompt = [];

if isempty(config.obsPath), config.obsPath = config.dataPath; end

config = expandPath(config, projectPath);

config.configMatName = [config.codePath 'config/' config.shortProjectName 'Config' config.userName '_' num2str(config.runId) '.mat'];
config.reportPath = [config.codePath 'report/'];

if iscell(config.parallel)
    if length(config.parallel)>=config.host
        config.parallel = config.parallel{config.host};
    else
        config.parallel = config.parallel{end};
    end
end
while length(config.parallel)<length(config.stepName)
    config.parallel(end+1)=config.parallel(end);
end

if config.setRandomSeed
    expRandom();
end

figureHandles = findobj('Type','figure');
config.displayData.figure = [];
for k=1:length(figureHandles)
    config.displayData.figure(k).handle = figureHandles(k);
    config.displayData.figure(k).taken = 0;
    config.displayData.figure(k).caption = 0;
    config.displayData.figure(k).report = 0;
    config.displayData.figure(k).label = 0;
    
end
config.displayData.table = [];

% config.currentStep = length(config.stepName);
config.suggestedNumberOfCores = Inf;
config.loadFileInfo.date = {'', ''};
config.loadFileInfo.dateNum = [Inf, 0];

config.settingStatus.success = 0;
config.settingStatus.failed = 0;



function config = commandLine(config, v)

configNames = fieldnames(config);
% overwrite default parameters with command line ones
for pair = reshape(v,2,[]) % pair is {propName;propValue}
    if ~any(strcmp(pair{1},strtrim(configNames))) % , length(pair{1})
        disp(['Warning. The command line parameter ' pair{1} ' is not found in the Config file. Setting anyway.']);
    end
    config.(pair{1}) = pair{2};
end

function config = expandPath(config, projectPath)

for k=1:length(config.dependencies) % FIXME may be wrong
    field = config.dependencies{k};
    if ~isempty(field) && any(strcmp(field(end), {'/', '\'}))
        field = field(1:end-1);
    end
    if ~config.attachedMode
        [p field] = fileparts(field);
        field = ['dependencies' '/' field];
    end
    config.dependencies{k} = field;
end

fieldNames=fieldnames(config);
for k=1:length(fieldNames)
    if ~isempty(strfind(fieldNames{k}, 'Path'))
        field = config.(fieldNames{k});
        
        % pick relevant path
        if iscell(field)
            if length(field)>=config.host
                config.(fieldNames{k}) = field{config.host};
            else
                config.(fieldNames{k}) = field{end}; % convention add the last parameter
            end
        end
        %         if ~strcmp(fieldNames{k}, 'matlabPath')  && ~isempty(field) && strcmp(field(1), '.')
        %             config.(fieldNames{k}) = [pwd() field(2:end)];
        %         end
    end
end

for k=1:length(fieldNames)
    if ~isempty(strfind(fieldNames{k}, 'Path'))
        if config.attachedMode
            field = expandHomePath(config.(fieldNames{k}));
        else
             field = config.(fieldNames{k});
        end
        % if relative add projectPath
        if all(~strcmp(fieldNames{k}, {'matlabPath', 'toolPath'}))  && (isempty(field) || ((~isempty(field) && ~any(strcmp(field(1), {'~', '/', '\'}))) && ((length(field)<1 || ~strcmp(field(2), ':')))))
            config.(fieldNames{k}) = [projectPath '/' field];
        else
            config.(fieldNames{k}) = field;
        end
    end
end

for k=1:length(fieldNames)
    if ~isempty(strfind(fieldNames{k}, 'Path'))
        field = config.(fieldNames{k});
        
        if isempty(field) || iscell(field) || any(strcmp(field(end), {'/', '\'}))
            config.(fieldNames{k})=field;
        else
            config.(fieldNames{k})=[field '/'];
        end
    end
end


