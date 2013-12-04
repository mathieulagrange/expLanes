function config = expConfig(projectPath, shortProjectName, commands)

% TODO redo allow to rerun the specific run, aka store runId in stored Data

% TODO function expAddTask to add a task at a given rank

% TODO etudier la possibilite de compiler le code pour se passer de
% parallel : mettre toute les variantes dans un fichier proteger par un
% lock

% TODO allow usage of local backup of dependencies (with expTool) 0 not, 1
% use (set dependencies path to local ones in config structure), 2 perform backup

% FIXME store dependency string and force localDep = 2 if different

configFileName = getUserFileName(shortProjectName, projectPath);
staticData = load([projectPath '/config' filesep shortProjectName]);

[p projectName] = fileparts(projectPath);
config = expConfigParse(configFileName);

config.projectPath = projectPath;
config.configFileName = configFileName;
config.hostName = char(getHostName(java.net.InetAddress.getLocalHost));

if isempty(config.completeName)
    config.completeName = config.userName;
end

config.variantFileName = [projectPath '/config' filesep config.shortProjectName 'Variants.txt'];
config.variantSpecifications = expVariantParse(config.variantFileName);


if nargin>1,
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

config.taskName = expTaskName(config.projectPath, config.shortProjectName);

if iscell(config.parallel)
    if length(config.parallel)>=hostIndex
        config.parallel = config.parallel{hostIndex};
    else
        config.parallel = config.parallel{end};
    end
end
while length(config.parallel)<length(config.taskName)
    config.parallel(end+1)=config.parallel(end);
end
config.parallel(end) = 0; % never for reduce


% config.randState = staticData.randState;
if config.setRandomSeed
    rng(0, 'twister');
    %     expRandomSeed(config);
end

config.displayData.figureHandles = findobj('Type','figure');
config.displayData.figureTaken = zeros(1, length(config.displayData.figureHandles)) ;
config.displayData.figureCaption = {};
config.displayData.figureLabel = {};
config.displayData.latex = [];

config.currentTask = length(config.taskName);
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

fieldNames=fieldnames(config);

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
        if ~strcmp(fieldNames{k}, 'matlabPath')  && (isempty(field) || ~isempty(field) && ~any(strcmp(field(1), {'~', '/', '\'})))
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

