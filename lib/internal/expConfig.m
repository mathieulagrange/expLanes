function config = expConfig(experimentPath, experimentName, shortExperimentName, commands)

% TODO expCreate diamond ??

% TODO convert disp by expLog

% TODO sorting for all exposition

% FIXME bug when saving figure (do not display)

% FIXME is reduceData by day still necessary ? // should not

expLanesPath = fileparts(fileparts(mfilename('fullpath')));

if exist('commands', 'var') && ~isempty(commands) && isstruct(commands{1})
    config = commands{1};
    commands = commands(2:end);
else
    configFileName = getUserFileName(shortExperimentName, experimentName, experimentPath, expLanesPath);
    expUserDefaultConfig([expLanesPath '/expLanesConfig.txt']);
    config = expUpdateConfig(configFileName);
    if isempty(config), return; end;
    
    config.shortExperimentName = shortExperimentName;
    config.userName = getUserName();
    config.experimentName = experimentName;
    config.experimentPath = experimentPath;
    config.configFileName = configFileName;
end


config.staticDataFileName = [experimentPath '/config' '/' shortExperimentName '_' config.userName];
if ~exist([config.staticDataFileName '.mat'], 'file')
    runId=1; %#ok<NASGU>
    save(config.staticDataFileName, 'runId');
end
staticData = load(config.staticDataFileName);

if isempty(config.completeName)
    config.completeName = config.userName;
end

config.factorFileName = [config.experimentPath '/' config.shortExperimentName 'Factors.txt'];
config.stepName = expStepName(config, config.experimentPath, config.shortExperimentName);




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

config.attachedMode = 1;
config.run = 1;
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

config.factors = expFactorParse(config, config.factorFileName);

if iscell(config.mask)
    if isempty(config.mask) || ~iscell(config.mask{1})
        config.mask = {config.mask};
    end
end

config.localHostName = char(getHostName(java.net.InetAddress.getLocalHost));
config.localHostName = strrep(config.localHostName, '.local', '');
% disp(['detectedHostName: ' config.localHostName]);
config.hostName = config.localHostName;
config = expDesign(config);
if ~isempty(config.machineNames) % && ~iscell(config.machineNames{1})
    config.machineNames = {config.machineNames};
end

if nargin<1 || config.host==0
    config.host = 0;
    for k=1:length(config.machineNames)
        id = find(strcmp(config.machineNames{k}, config.localHostName));
        if ~isempty(id)
            config.hostGroup = k;
            config.host = k+id(1)/10;
            config.hostName = config.machineNames{k}{id(1)};
        end
    end
    if config.host==0
        fprintf(2, ['Unable to find the detected host ' config.localHostName  ' in the machineNames field of your configuration file. \nEither explicitely set the host number (''host'', <value>) or  add ' config.localHostName ' to the list of your machines \n in your config file: ' config.configFileName '\n']);
        config.host=1;
    end
else
    if config.host>0
        config.attachedMode = -1;
    end
    config.host = abs(config.host);
    if config.host == floor(config.host)
        if iscell(config.machineNames{config.host})
            config.hostName = config.machineNames{config.host}{1};
        else
            config.hostName = config.machineNames{config.host};
        end
    else
        config.hostName = expGetMachineName(config, config.host);
    end
end
config.hostGroup = floor(config.host);

% if config.resume
%     config.runId = config.resume;
% else
config.runId = staticData.runId;
if config.run
    runId = config.runId+1;
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
config.displayData.style = [];
config.homePath = expandHomePath('~');

config.tmpPath = [config.homePath '/.expLanes/tmp/'];
if ~exist(config.tmpPath, 'dir')
    mkdir(config.tmpPath);
end

if isempty(config.dataPath), config.dataPath = [fileparts(which(config.experimentName)) '/data']; end

if isempty(config.obsPath), config.obsPath = config.dataPath; end
if isempty(config.codePath), config.codePath = fileparts(which(config.experimentName)); end

if iscell(config.codePath)
    if length(config.codePath)>=config.hostGroup
        experimentPath = expandHomePath(strtrim(config.codePath{config.hostGroup}));
    else
        experimentPath = expandHomePath(strtrim(config.codePath{end})); % convention add the last parameter
    end
else
    experimentPath = expandHomePath(strtrim(config.codePath));
end

if ~isempty(experimentPath)
    config.experimentPath = experimentPath;
end
   
%if strcmp(config.localHostName, expGetMachineName(config, config.host)) && ...
%         strcmp(config.localHostName, expGetMachineName(config, config.host)) && ...
%   ~strcmp(strrep(config.experimentPath, '\', '/'), strrep(fileparts(which(config.experimentName)), '\', '/'))
%    fprintf(2, 'The codePath in your configuration file may be wrong.\n');
%end

config = expandPath(config, config.experimentPath);

config.configMatName = [config.codePath 'config/' config.shortExperimentName 'Config' config.userName '_' num2str(config.runId) '.mat'];
config.reportPath = [config.codePath 'report/'];

if iscell(config.parallel)
    if length(config.parallel)>=config.hostGroup
        config.parallel = config.parallel{config.hostGroup};
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

figureHandles = sort(findobj('Type','figure'));
config.displayData.figure = [];
for k=1:length(figureHandles)
    h = figureHandles(k);
    if ~isnumeric(h)
        h=h.Number;
    end
    config.displayData.figure(k).handle = h;
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
config.expLanesPath = expLanesPath;
config.runDuration = 0;
config.html = [];
config.html.tables = [];

if ~exist(config.reportPath, 'dir'), mkdir(config.reportPath); end
if ~exist([config.reportPath 'figures'], 'dir'), mkdir([config.reportPath 'figures']); end
if ~exist([config.reportPath 'tables'], 'dir'), mkdir([config.reportPath 'tables']); end
if ~exist([config.reportPath 'tex'], 'dir'), mkdir([config.reportPath 'tex']); end
if ~exist([config.reportPath 'reports'], 'dir'), mkdir([config.reportPath 'reports']); end


if ~isempty(config.addFactor)
    config = expFactorManipulate(config, config.addFactor{:});
end
if ~isempty(config.removeFactor)
    config = expFactorManipulate(config, '', '', config.removeFactor{2}, '', '', config.removeFactor{1});
end
if ~isempty(config.addStep)
    if iscell( config.addStep)
        config = expStepCreate(config, config.addStep{:});
    else
        config = expStepCreate(config, config.addStep);
    end
end
if ~isempty(config.removeStep)
    config = expStepRemove(config, config.removeStep);
end

function config = commandLine(config, v)

configNames = fieldnames(config);
% overwrite default parameters with command line ones
try
    parsedPairs = reshape(v,2,[]);
catch
    fprintf(2, 'Unable to parse command line which should be a series of pairs ''parameter'', value.\n');
    return;
end
for pair = parsedPairs% pair is {propName;propValue}
    if ~any(strcmp(pair{1},strtrim(configNames))) % , length(pair{1})
        disp(['Warning. The command line parameter ' pair{1} ' is not found in the Config file. Setting anyway.']);
    end
    config.(pair{1}) = pair{2};
end

function config = expandPath(config, experimentPath)

for k=1:length(config.dependencies) % FIXME may be wrong
    field = config.dependencies{k};
    if ~isempty(field) && any(strcmp(field(end), {'/', '\'}))
        field = field(1:end-1);
    end
    if ~config.attachedMode && ~strcmp(config.hostName, config.localHostName)
        [p, field] = fileparts(field);
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
            if length(field)>=config.hostGroup
                config.(fieldNames{k}) = strtrim(field{config.hostGroup});
            else
                config.(fieldNames{k}) = strtrim(field{end}); % convention add the last parameter
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
        if config.attachedMode == 1
            field = expandHomePath(config.(fieldNames{k}));
        end
        % if relative add experimentPath
        if all(~strcmp(fieldNames{k}, {'matlabPath', 'toolPath', 'backupPath'}))  && ...
                (isempty(field) || (~isempty(field) && ~any(strcmp(field(1), {'~', '/', '\'})))) && (length(field)>1 && ~strcmp(field(2), ':')) % FIXME  fragile ??
            config.(fieldNames{k}) = [experimentPath '/' field];
        else
            config.(fieldNames{k}) = field;
        end
    end
end

for k=1:length(fieldNames)
    if ~isempty(strfind(fieldNames{k}, 'Path'))
        field = config.(fieldNames{k});
        field = strrep(field, '\', '/');
        if isempty(field) || iscell(field) || any(strcmp(field(end), {'/', '\'}))
            config.(fieldNames{k})=field;
        else
            config.(fieldNames{k})=[field '/'];
        end
    end
end


