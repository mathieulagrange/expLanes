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

% TODO utilities path and config probe (tex, rsync, ssh connect to servers)


% TODO set current host with hostName (<0 detached server mode >0 attached mode 0 auto mode, Inf debug mode)

%userDefaultConfigFileName = expUserDefaultConfig();

configFileName = getUserFileName(shortProjectName, projectName, projectPath);
config = expUpdateConfig(configFileName);
config.shortProjectName = shortProjectName;
config.userName = getUserName();
config.staticDataFileName = [projectPath '/config' filesep shortProjectName];

staticData = load(config.staticDataFileName);

[p, projectName] = fileparts(projectPath);

config.projectName = projectName;
config.projectPath = projectPath;
config.configFileName = configFileName;
config.hostName = char(getHostName(java.net.InetAddress.getLocalHost));

if isempty(config.completeName)
    config.completeName = config.userName;
end

config.factorFileName = [projectPath filesep config.shortProjectName 'Factors.txt'];
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

if nargin<1 || config.host < 1
    hostIndex = find(strcmp(config.machineNames, config.hostName));
    if isempty(hostIndex)
        hostIndex = 1;
    end
else
    hostIndex = config.host;
end

if hostIndex>1
    config.hostName = config.machineNames{hostIndex};
else
    config.hostName = config.machineNames{1};
end

% if config.resume
%     config.runId = config.resume;
% else
config.runId = staticData.runId;
if config.host>0
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

config = expandPath(config, hostIndex, projectPath);

config.configMatName = [config.codePath 'config/' config.shortProjectName 'Config' config.userName '_' num2str(config.runId) '.mat'];
config.reportPath = [config.codePath 'report/'];

if iscell(config.parallel)
    if length(config.parallel)>=hostIndex
        config.parallel = config.parallel{hostIndex};
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

if ~exist(config.reportPath, 'dir'), mkdir(config.reportPath); end
if ~exist([config.reportPath 'figures'], 'dir'), mkdir([config.reportPath 'figures']); end
if ~exist([config.reportPath 'tables'], 'dir'), mkdir([config.reportPath 'tables']); end
if ~exist([config.reportPath 'tex'], 'dir'), mkdir([config.reportPath 'tex']); end
if ~exist([config.reportPath 'data'], 'dir'), mkdir([config.reportPath 'data']); end

expTools(config);

function config = commandLine(config, v)

configNames = fieldnames(config);
% overwrite default parameters with command line ones
for pair = reshape(v,2,[]) % pair is {propName;propValue}
    if ~any(strcmp(pair{1},strtrim(configNames))) % , length(pair{1})
        disp(['Warning. The command line parameter ' pair{1} ' is not found in the Config file. Setting anyway.']);
    end
    config.(pair{1}) = pair{2};
end

function config = expandPath(config, hostIndex, projectPath)

for k=1:length(config.dependencies)
    field = config.dependencies{k};
    if ~isempty(field) && any(strcmp(field(end), {'/', '\'}))
        field = field(1:end-1);
    end
    if hostIndex > 1
        [p field] = fileparts(field);
        field = ['dependencies' filesep field];
    end
    config.dependencies{k} = field;
end

fieldNames=fieldnames(config);
for k=1:length(fieldNames)
     if ~isempty(strfind(fieldNames{k}, 'Path'))
         field = config.(fieldNames{k});
   
         % pick relevant path
        if iscell(field)
            if length(field)>=hostIndex
                 config.(fieldNames{k}) = field{hostIndex};
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
        field = config.(fieldNames{k});
        % if relative add projectPath
        if all(~strcmp(fieldNames{k}, {'matlabPath', 'toolPath'}))  && (isempty(field) || ((~isempty(field) && ~any(strcmp(field(1), {'~', '/', '\'}))) && ((length(field)<1 || ~strcmp(field(2), ':')))))
            config.(fieldNames{k}) = [projectPath filesep field];
        end
    end
end

for k=1:length(fieldNames)
    if ~isempty(strfind(fieldNames{k}, 'Path'))
        field = config.(fieldNames{k});
       
        if isempty(field) || iscell(field) || any(strcmp(field(end), {'/', '\'}))
            config.(fieldNames{k})=field;
        else
            config.(fieldNames{k})=[field filesep];
        end
    end
end


