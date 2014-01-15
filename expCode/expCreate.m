function expCreate(projectName, stepNames, codePath, dataPath)
% expCreate(projectName, stepNames, codePath, dataPath)
%   create an expCode project
%
%   projectName: the name of the project
%   stepNames: cell array of names of the steps  (default value set in defaultConfig.txt)
%   codePath: path for code storage (default value set in defaultConfig.txt)
%   dataPath: path for data storage (default value set in defaultConfig.txt)

% TODO remove expPath

expCodePath = fileparts(mfilename('fullpath'));
addpath(genpath(expCodePath));

if ~exist('projectName', 'var')
    projectName = 'helloProject';
elseif ~ischar(projectName)
    error('The projectName must be a string');
end

shortProjectName = names2shortNames(projectName);
shortProjectName = shortProjectName{1};

% load default config
configFile=fopen([expCodePath '/defaultConfig.txt']);
configCell=textscan(configFile,'%s%s', 'CommentStyle', '%', 'delimiter', '=');
fclose(configFile);
names = strtrim(configCell{1});
values = strtrim(configCell{2});

for k=1:length(names)
    if k <= length(values)
        values{k} = strrep(values{k}, '<>', projectName);
    else
        values{k} = '';
    end
end

config = cell2struct(values, names);
config.projectName = projectName;
config.shortProjectName = shortProjectName;
config.userName = getUserName();
if isempty(config.completeName)
    config.completeName = config.userName;
end
if ~exist('stepNames', 'var')
    stepNames = {};
end
% config.stepName = cell2string(stepNames);

if exist('codePath', 'var')
    if ~isempty(codePath)
        config.codePath = codePath;
    end
end
% TODO pick the first if several by default
if exist('dataPath', 'var')
    if ~isempty(dataPath)
        config.dataPath = dataPath;
    end
end

config.dataPath = strrep(config.dataPath, '<>', projectName);
config.codePath = strrep(config.codePath, '<>', projectName);

if isempty(config.dataPath)
    config.dataPath = fullfile(pwd());
elseif ~any(strcmp(config.dataPath(1), {'~', '/', '\'}))
    config.dataPath = fullfile(pwd(), config.dataPath);
end

if ~any(strcmp(config.codePath(1), {'~', '/', '\'}))
    config.codePath = fullfile(pwd(), config.codePath);
end

config.dependencies = [config.dependencies(1:end-1) ' ''' expCodePath '''}']; % TODO zhy (1:find(expCodePath=='/',1,'last'))

% prompt
fprintf('You are about to create an experiment called %s with short name %s and steps: ', projectName, shortProjectName);
disp(stepNames);
fprintf('Path to code %s\nData path %s\n', config.codePath, config.dataPath);
fprintf('Note: you can set the default data path as well as other configuration parameters\n in the file defaultConfig.txt.\n');
if inputQuestion(), fprintf(' Bailing out ...\n'); return; end

% create code repository
if exist(config.codePath, 'dir'),
    if inputQuestion('Warning: you are about to reinitialize an existing project.\n');
        fprintf('Bailing out \n');
        return;
    else
        rmdir(config.codePath, 's');
    end
end
mkdir(config.codePath);

configPath = [config.codePath filesep 'config' filesep];
mkdir(configPath);

config = orderfields(config);
n = fieldnames(config);
p = find(~cellfun(@isempty, strfind(n, 'Path')));
p = [p; find(~cellfun(@isempty, strfind(n, 'Name')))];
p = [p; setdiff(1:length(n), p)'];
config = orderfields(config, p);

configFile=fopen([expCodePath '/defaultConfig.txt']);
configCell=textscan(configFile,'%s', 'delimiter', '\n');
fclose(configFile);

% create config file
fid = fopen([config.codePath filesep config.shortProjectName 'ConfigDefault.txt'], 'w');
fprintf(fid, '%% Config file for the %s project\n%% Adapt at your convenience\n\n', config.shortProjectName);
configFields = fieldnames(config);
for k=1:length(configFields)
    comment='%';
    fieldIndex = find(~cellfun('isempty',regexp(configCell{1}, ['^' configFields{k} '* ='])));
%     fieldIndex  = fieldIndex(end);
    if ~isempty(fieldIndex) && ~isempty(configCell{1}{fieldIndex-1}) && configCell{1}{fieldIndex-1}(1) == '%'
        comment = configCell{1}{fieldIndex-1};
    end
    fprintf(fid, '%s\n%s = %s\n', comment, configFields{k}, char(config.(configFields{k})));
end
fclose(fid);
copyfile([configPath '/' config.shortProjectName 'ConfigDefault.txt'], [configPath '/' config.shortProjectName 'Config' [upper(config.userName(1)) config.userName(2:end)] '.txt']);

% create factors file
fid = fopen([configPath '/' config.shortProjectName 'Factors.txt'], 'w');
fprintf(fid, 'method =1== {''methodOne'', ''methodTwo'', ''methodThree''} % method will be defined for step 1 only \nthreshold =s1:=1/[1 3]= [0:10] % threshold is defined for step 1 and the remaining steps, will be sequenced and valid for the 1st and 3rd value of the 1st parameter (methodOne and methodThree) \n\n%% Modes file for the %s project\n%% Adapt at your convenience\n', config.shortProjectName);
fclose(fid);


rootString = char({...
    ['function config = ' projectName '(varargin)'];
    ['% Welcome to the main entry point of ' projectName];
    '% Please DO NOT modify this file unless you have a precise intent.';
    '';
    ['shortProjectName = ''' shortProjectName ''';'];
    '[p projectName] = fileparts(mfilename(''fullpath''));';
    'if nargin>0 && isstruct(varargin{1})';
    ' config = varargin{1};';
    'else';
    ' config = expConfigParse(getUserFileName(shortProjectName, p));';
    'end';
    '';
    'expDependencies(config);';
    'config = expRun(p, shortProjectName, varargin);';
    '';
    fileread([expCodePath '/nonExposed/utils/getUserFileName.m'])
    fileread([expCodePath '/nonExposed/expConfigParse.m'])
    fileread([expCodePath '/nonExposed/utils/getUserName.m'])
    fileread([expCodePath '/nonExposed/expDependencies.m'])
    });

dlmwrite([config.codePath '/' projectName '.m'], rootString,'delimiter','');

config.latex = LatexCreator([config.codePath filesep config.projectName '.tex'], 0, config.completeName, [config.projectName ' version ' num2str(config.versionName) '\\ ' config.message], projectName, 1, 1);

% create project functions
% TODO add some comments
for k=1:length(stepNames)
    functionName = [shortProjectName num2str(k) stepNames{k}];
    functionString = char({...
        ['function [config, store, obs] = ' functionName '(config, mode, data)'];
        ['% ' functionName ' ' upper(stepNames{k}) ' step of the expCode project ' projectName];
        ['%    [config, store, obs] = ' functionName '(config, mode, data)'];
        '%       config : expCode configuration state';
        '%       mode   : set of factors to be evaluated';
        '%       data   : processing data stored during the previous step';
        '%';
        '%       store  : processing data to be saved for the other steps ';
        '%       obs    : observations to be saved for analysis';
        '';
        ['% Copyright ' config.completeName];
        ['% Date ' date()];
        '';
        ['if nargin==0, ' , projectName '(''do'', ' num2str(k) ', ''mask'', {{}}); return; end'];
        '';
        'disp([config.currentStepName '' '' mode.infoString]);';
        '';
        'store=[];';
        'obs=[];';
        });
    dlmwrite([config.codePath '/' functionName '.m'], functionString,'delimiter','');
    
    %     fid=fopen([config.codePath '/' functionName '.m'], 'w');
    %     sprintf('function [config, store, display] = %s(config, mode, data)\n\nif nargin==0, %s(''do'', %d, ''mask'', {{}}); return; end\n\n\n\n', );
    %     fclose(fid);
end

functionString = char({...
    ['function [config, store] = ' shortProjectName 'Init(config)'];
    ['% ' shortProjectName 'Init INITIALIZATION of the expCode project ' projectName];
    ['%    [config, store] = ' functionName 'Init(config)'];
    '%       config : expCode configuration state';
    '%';
    '%       store  : processing data to be saved for the other steps ';
    '';
    ['% Copyright ' config.completeName];
    ['% Date ' date()];
    '';
    ['if nargin==0, ' , projectName '(); return; end'];
    'store=[];';
    });
dlmwrite([config.codePath '/' shortProjectName 'Init.m'], functionString,'delimiter','');


functionName = [shortProjectName 'Report'];
fid=fopen([config.codePath '/' functionName '.m'], 'w');
fprintf(fid, 'function config = %s(config)\n\nif nargin==0, %s(''report'', 2); return; end', functionName, projectName);
fclose(fid);

functionString = char({...
    ['function config = ' shortProjectName 'Report(config)'];
    ['% ' shortProjectName 'Report REPORTING of the expCode project ' projectName];
    ['%    config = ' functionName 'Report(config)'];
    '%       config : expCode configuration state';
    '';
    ['% Copyright ' config.completeName];
    ['% Date ' date()];
    '';
    ['if nargin==0, ' , projectName '(''report'', 0); return; end'];
    });
dlmwrite([config.codePath '/' shortProjectName 'Report.m'], functionString,'delimiter','');

% create readme file
readmeString = char({['% This is the README for the experiment ' config.projectName]; ''; ['% Created on ' date() ' by ' config.userName]; ''; '% Purpose: '; ''; '% Reference: '; ''; '% Licence: '; ''; ''});
dlmwrite([config.codePath '/README.txt'], readmeString, 'delimiter', '')
% append remaining of the file
dlmwrite([config.codePath '/README.txt'], fileread([expCodePath '/nonExposed/README.txt']), '-append', 'delimiter', '')

runId=1;
save([configPath config.shortProjectName], 'runId');


% copy depencies if necessary
if str2num(config.localDependencies) >= 1
    config.dependencies = eval(config.dependencies);
    keep =   config.localDependencies;
    config.localDependencies = 2;
    expDependencies(config);
    config.localDependencies = keep;
end

fprintf('Done.\nMoving to project directory.\n')
cd(config.codePath);

function s=cell2string(c)

if isempty(c)
    s='{}';
else
    s='{';
    for k=1:length(c)
        s = [s '''' c{k} ''' '];
    end
    s = [s(1:end-1) '}'];
end
