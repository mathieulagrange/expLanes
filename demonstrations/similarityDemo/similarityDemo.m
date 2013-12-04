function config = similarityDemo(varargin)

[p projectName] = fileparts(mfilename('fullpath'));
if nargin>0 && isstruct(varargin{1})
    config = varargin{1};
else
    config = expConfigParse(getUserFileName(projectName, p));
end

expDependencies(config);
config = expRun(p, varargin);

function configFileName = getUserFileName(projectName, projectPath)

% shortProjectName = names2shortNames(projectName);
% shortProjectName = shortProjectName{1};

userName = getUserName();

configFileName = [projectPath '/config' filesep projectName 'Config' [upper(userName(1)) userName(2:end)] '.txt'];

if ~exist(configFileName, 'file')
    defaultConfigFileName = [projectPath '/config' filesep projectName 'ConfigDefault.txt'];
    fprintf('Unable to find user specific Config file for user %s. Copying default one.\n', userName);
    copyfile(defaultConfigFileName, configFileName);
end



function config = expConfigParse(configFileName)

configFile=fopen(configFileName);
if configFile==-1,
    error('Unable to load the expTool config file for your project.');
end

configCell=textscan(configFile,'%s%s ', 'commentStyle', '%', 'delimiter', '=');
fclose(configFile);
names = strtrim(configCell{1});
values = strtrim(configCell{2});

for k=1:length(values)
    if  ~isnan(str2double(values{k}))
        values{k} = str2double(values{k});
    elseif values{k}(1) == '{' || values{k}(1) == '['
        values{k} =  eval(values{k});
    end
end

config = cell2struct(values, names);


function userId=getUserName()

if isunix
    userId = getenv('USER');
    if isempty(userId), userName = getenv('USERNAME'); end
else
    userId = getenv('UserName');
end



function expDependencies(config)

p = fileparts(mfilename('fullpath'));
addpath(genpath(p));

if config.localDependencies == 0
    for k=1:length(config.dependencies)
        addpath(genpath(config.dependencies{k}));
    end
elseif config.localDependencies ==2
    expSync(config, 'd', 0, 0, 0, 1);
    p = fileparts(mfilename('fullpath'));
    addpath(genpath(p));
end

