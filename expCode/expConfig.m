function config = expConfig(projectPath, shortProjectName, commands)

% TODO command to purge server code base

% TODO default still in title
% TODO seed index after resampling ?
% TODO expCreate diamond ??
% TODO 'host' 1 on  linux -> matlab path ?
% TODO config copy managment
% TODO symbolic link to data, issue with rsync and issues with path generation ?
% TODO display obs in mail
% TODO have a default config within user folder
% TODO end in factor selector
% TODO fix factor selector (too much NaNs)
% TODO display plan of experiment
% TODO keep latex data for next run
% TODO s at beginning
% TODO build GUI
% TODO renaming .mat function when adding factor
% TODO put default timing observations (show average duration per mode)
% TODO convert disp by expLog
% TODO clusteringMetrics
% TODO split expModesBuild into a helper function that is called to build
% FIXME expMex recompile everytime on server side
% TODO dump obs data as .mat attached to report

% one mode

% FIXME expProgress ctrl C opened figure

% TODO fix potential issues with short naming (issues with too long file names, hashing ?)

% FIXME store dependency string and force localDep = 2 if different

configFileName = getUserFileName(shortProjectName, projectPath);
config = expConfigParse(configFileName);

expCodePath = fileparts(mfilename('fullpath'));  
defaultConfig = expConfigParse([expCodePath filesep 'defaultConfig.txt']);

namesDefault = fieldnames(defaultConfig);
namesConfig = fieldnames(config);
for k=1:length(namesDefault)
    if ~strcmp(namesConfig, namesDefault{k})
        disp(['Missing config field ' namesDefault{k} ' in your config file (see defaultConfig.txt in expCode rootPath for default setting).']);
        config.(namesDefault{k}) = defaultConfig.(namesDefault{k});
    end
end


staticData = load([projectPath '/config' filesep shortProjectName]);

[p projectName] = fileparts(projectPath); % TODO may be unused

config.projectPath = projectPath;
config.configFileName = configFileName;
config.hostName = char(getHostName(java.net.InetAddress.getLocalHost));

if isempty(config.completeName)
    config.completeName = config.userName;
end

config.factorFileName = [projectPath filesep config.shortProjectName 'Factors.txt'];
config.factors = expFactorParse(config.factorFileName);


if nargin>2,
    configOri = config;
    %     if ~mod(nargin, 2)
    config = commandLine(config, commands);
    %     else
    %         config = commandLine(config, commands(2:end));
    %     end
    if isnumeric(config.mask)
        if config.mask==0
            config.mask = {{}};
        else
            config.mask = configOri.mask(config.mask);
        end
    end
end

if iscell(config.mask)
    if isempty(config.mask) || ~iscell(config.mask{1})
        config.mask = {config.mask};
    end
end

config = expPlan(config);

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

if config.resume
    config.runId = config.resume;
else
    config.runId = staticData.runId;
    if config.host>0
        runId = config.runId+1; %#ok<NASGU>
        save([projectPath '/config' filesep config.shortProjectName], 'runId', '-append');
        config.runId = runId;
    end
end

config = expandPath(config, hostIndex, projectPath);

config.configMatName = [config.codePath 'config/' config.shortProjectName 'Config' config.userName '_' num2str(config.runId) '.mat'];
config.reportPath = [config.codePath 'report/'];

config.stepName = expStepName(config.projectPath, config.shortProjectName);

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
% config.parallel(end) = 0; % never for reduce


% config.randState = staticData.randState;
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
config.displayData.latex = [];

config.currentstep = length(config.stepName);
config.suggestedNumberOfCores = Inf;
config.loadFileInfo.date = {'', ''};
config.loadFileInfo.dateNum = [Inf, 0];

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
        if ~strcmp(fieldNames{k}, 'matlabPath')  && (isempty(field) || ((~isempty(field) && ~any(strcmp(field(1), {'~', '/', '\'}))) && ((length(field)<1 || ~strcmp(field(2), ':')))))
            config.(fieldNames{k}) = [projectPath filesep field];
        end
    end
end

for k=1:length(fieldNames)
    if ~isempty(strfind(fieldNames{k}, 'Path'))
        field = config.(fieldNames{k});
       
        if isempty(field) || any(strcmp(field(end), {'/', '\'}))
            config.(fieldNames{k})=field;
        else
            config.(fieldNames{k})=[field filesep];
        end
    end
end

config.waitBar = [];
