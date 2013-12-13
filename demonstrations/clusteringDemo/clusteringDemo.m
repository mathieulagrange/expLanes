function config = clusteringDemo(varargin)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
% Welcome to the main entry point of clusteringDemo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
% Please DO NOT modify this file unless you have a precise intent.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
shortProjectName = 'clde';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
p = fileparts(mfilename('fullpath'));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
if nargin>0 && isstruct(varargin{1})                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
 config = varargin{1};                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
else                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
 config = expConfigParse(getUserFileName(shortProjectName, p));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
expDependencies(config);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
config = expRun(p, shortProjectName, varargin);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
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
    error('Unable to load the expCode config file for your project.');
end

configCell=textscan(configFile,'%s%s ', 'commentStyle', '%', 'delimiter', '=');
fclose(configFile);
names = strtrim(configCell{1});
values = strtrim(configCell{2});

for k=1:length(names)
    if k <= length(values)
    if ~isempty(values{k})
        if  ~isnan(str2double(values{k}))
            values{k} = str2double(values{k});
        elseif values{k}(1) == '{' || values{k}(1) == '['
            values{k} =  eval(values{k});
        end
    end
    else
       values{k} = ''; 
    end
end

config = cell2struct(values, names);


function userId=getUserName()

if isunix
userId = getenv('USER');
if isempty(userId), userId = getenv('USERNAME'); end
else
    userId = getenv('UserName');
end


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
function expDependencies(config)

p = fileparts(mfilename('fullpath'));
addpath(genpath(p));

if config.localDependencies == 0 || config.localDependencies == 2
    for k=1:length(config.dependencies)
        dependencyPath = config.dependencies{k};
        if dependencyPath(1) == '.'
            dependencyPath = [p filesep dependencyPath];
        end
        addpath(genpath(dependencyPath));
    end
end                                                                                                                                                                                                                                                                                                                   
