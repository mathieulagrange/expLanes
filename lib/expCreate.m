function expCreate(experimentName, stepNames, codePath, dataPath, configValues)
% expCreate create an expLanes experiment
%	expCreate(experimentName, stepNames, codePath, dataPath)
%	- experimentName: name of the experiment
%	- stepNames: cell array of strings defining the names
%	 of the different processing steps
%	- codePath: path for code storage
%	- dataPath: path for data storage
%   - configValues: cell array of string pairs (one for the filed name one
%       for its value) to be added to the
%   config file
%
%	Default values and other settings can be set in your configuration file
% 	located in your home in the .expLanes directory. This file serves
%	as the initial config file for your expLanes experiments

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.

expLanesPath = fileparts(mfilename('fullpath'));
addpath(genpath(expLanesPath));

if ~exist('experimentName', 'var')
    experimentName = 'helloExperiment';
elseif ~ischar(experimentName)
    error('The experimentName must be a string');
end
if ~exist('stepNames', 'var'), stepNames = {}; end

if ~iscell(stepNames), stepNames = {stepNames}; end

if ~exist('configValues', 'var'), configValues = []; end

shortExperimentName = names2shortNames(experimentName);
shortExperimentName = shortExperimentName{1};

% load default config

[userDefaultConfigFileName, userDir] = expUserDefaultConfig([expLanesPath '/expLanesConfig.txt']);
if ~exist(userDefaultConfigFileName, 'file')
    error(['Unable to find ' userDefaultConfigFileName '\n']);
end
configFile=fopen(userDefaultConfigFileName);
configCell=textscan(configFile,'%s%s', 'CommentStyle', '%', 'delimiter', '=');
fclose(configFile);
names = strtrim(configCell{1});
values = strtrim(configCell{2});

for k=1:length(names)
    if k <= length(values)
        values{k} = strrep(values{k}, '<>', experimentName);
        values{k} = strrep(values{k}, '<experimentName>', experimentName);
        values{k} = strrep(values{k}, '<experimentPath>', experimentName);
    else
        values{k} = '';
    end
end

config = cell2struct(values, names);
config.experimentName = experimentName;
config.shortExperimentName = shortExperimentName;
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

if exist('dataPath', 'var')
    if ~isempty(dataPath)
        config.dataPath = dataPath;
    end
end

% config.dataPath = strrep(config.dataPath, '<experimentName>', experimentName);
% config.codePath = strrep(config.codePath, '<experimentName>', experimentName);

if isempty(config.dataPath)
    config.dataPath = fullfile(pwd());
elseif ~any(strcmp(config.dataPath(1), {'~', '/', '\'}))
    config.dataPath = fullfile(pwd(), config.dataPath);
end

if ~any(strcmp(config.codePath(1), {'~', '/', '\'}))
    config.codePath = fullfile(pwd(), config.codePath);
end

if isempty(config.dependencies)
    config.dependencies = ['{''' expLanesPath '''}'];
elseif isempty(strfind(config.dependencies, 'expLanes'))
    if strcmp(config.dependencies(1), '{')
        config.dependencies = [config.dependencies(1:end-1) ' ''' expLanesPath '''}'];
    else
        config.dependencies = ['{''' config.dependencies ''', ''' expLanesPath '''}'];
    end
end

if isempty(config.obsPath)
    config.obsPath = config.dataPath;
end

% prompt
fprintf('You are about to create an experiment called %s with short name %s', experimentName, shortExperimentName);
if ~isempty(stepNames)
     fprintf(' and steps: '); 
disp(stepNames);
else
    fprintf('\n');
end
fprintf('Path to code %s\nData path: %s\nObservations path: %s\n', config.codePath, config.dataPath, config.obsPath);
disp(['Note: you can set the default values to all configuration parameters in your config file: ' userDir '/' '.expLanes' '/' 'defaultConfig.txt']);

if ~inputQuestion(), fprintf(' Bailing out ...\n'); return; end

% create code repository
if exist(config.codePath, 'dir'),
    if ~inputQuestion('Warning: you are about to reinitialize an existing experiment.\n');
        fprintf('Bailing out \n');
        return;
    else
        rmdir(config.codePath, 's');
    end
end
mkdir(config.codePath);

configPath = [config.codePath '/' 'config' '/'];
mkdir(configPath);

config = orderfields(config);
n = fieldnames(config);
p = find(~cellfun(@isempty, strfind(n, 'Path')));
p = [p; find(~cellfun(@isempty, strfind(n, 'Name')))];
p = [p; setdiff(1:length(n), p)'];
config = orderfields(config, p);

for k=1:2:length(configValues)
    config.(configValues{k}) = configValues{k+1};
end

% create config file
configFileName = [configPath '/' config.shortExperimentName 'Config' [upper(config.userName(1)) config.userName(2:end)] '.txt']; % [configPath '/' config.shortExperimentName 'ConfigDefault.txt'];
fid = fopen(configFileName, 'w');
if fid == -1, error(['Unable to open ' configFileName]); end

fprintf(fid, '%% Config file for the %s experiment\n%% Adapt at your convenience\n\n', config.shortExperimentName);
configFields = fieldnames(config);
for k=1:length(configFields)
    fprintf(fid, '%s = %s\n', configFields{k}, char(config.(configFields{k})));
end
fclose(fid);

expConfigMerge(configFileName, [expLanesPath '/expLanesConfig.txt'], 2, 0);

% create factors file
factorFileName = [config.codePath '/' config.shortExperimentName 'Factors.txt'];
fid = fopen(factorFileName, 'w');
if fid == -1, error(['Unable to open ' factorFileName]); end
% fprintf(fid, 'method =1== {''methodOne'', ''methodTwo'', ''methodThree''} % method will be defined for step 1 only \nthreshold =s1:=1/[1 3]= [0:10] % threshold is defined for step 1 and the remaining steps, will be sequenced and valid for the 1st and 3rd value of the 1st factor (methodOne and methodThree) \n\n%% Settings file for the %s experiment\n%% Adapt at your convenience\n', config.shortExperimentName);
fclose(fid);

%create root file
expCreateRootFile(config, experimentName, shortExperimentName, expLanesPath);

% create experiment functions
for k=1:length(stepNames)
    expStepFile(config, stepNames{k}, k);
end


functionName = [shortExperimentName 'Init'];
functionString = char({...
    ['function [config, store] = ' shortExperimentName 'Init(config)'];
    ['% ' shortExperimentName 'Init INITIALIZATION of the expLanes experiment ' experimentName];
    ['%    [config, store] = ' functionName '(config)'];
    '%      - config : expLanes configuration state';
    '%      -- store  : processing data to be saved for the other steps ';
    '';
    ['% Copyright: ' config.completeName];
    ['% Date: ' date()];
    '';
    ['if nargin==0, ' , experimentName '(); return; else store=[];  end'];
    });
dlmwrite([config.codePath '/' functionName '.m'], functionString,'delimiter','');

functionString = char({...
    ['function config = ' shortExperimentName 'Report(config)'];
    ['% ' shortExperimentName 'Report REPORTING of the expLanes experiment ' experimentName];
    ['%    config = ' functionName 'Report(config)'];
    '%       config : expLanes configuration state';
    '';
    ['% Copyright: ' config.completeName];
    ['% Date: ' date()];
    '';
    ['if nargin==0, ' , experimentName '(''report'', ''rhv''); return; end'];
    '';
    ['config = expExpose(config, ''t'');'];
    });
dlmwrite([config.codePath '/' shortExperimentName 'Report.m'], functionString,'delimiter','');

% create readme file
readmeString = char({['% This is the README for the experiment ' config.experimentName]; ''; ['% Created on ' date() ' by ' config.userName]; ''; '% Purpose: '; ''; '% Reference: '; ''; '% Licence: '; ''; ''});
dlmwrite([config.codePath '/README.txt'], readmeString, 'delimiter', '')
% append remaining of the file
dlmwrite([config.codePath '/README.txt'], fileread([expLanesPath '/internal/README.txt']), '-append', 'delimiter', '')

runId=1; %#ok<NASGU>
save([configPath config.shortExperimentName], 'runId');

% copy depencies if necessary
if str2double(config.localDependencies) >= 1
    config.dependencies = eval(config.dependencies);
    keep =   config.localDependencies;
    config.localDependencies = 2;
    expDependencies(config);
    config.localDependencies = keep;
end

fprintf('Done.\nMoving to experiment directory.\n')
cd(config.codePath);
