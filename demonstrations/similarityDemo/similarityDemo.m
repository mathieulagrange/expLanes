function config = similarityDemo(varargin)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
% Welcome to the main entry point of similarityDemo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
% Please DO NOT modify this file unless you have a precise intent.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
shortProjectName = 'side';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
[p, projectName] = fileparts(mfilename('fullpath'));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
if nargin>0 && isstruct(varargin{1})                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
 config = varargin{1};                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
else                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
 config = expConfigParse(getUserFileName(shortProjectName, projectName, p));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
if ~isempty(config)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
expDependencies(config);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
config = expRun(p, projectName, shortProjectName, varargin);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
function configFileName = getUserFileName(shortProjectName, projectName, projectPath)

% shortProjectName = names2shortNames(projectName);
% shortProjectName = shortProjectName{1};

userName = getUserName();

configFileName = [projectPath '/config' filesep shortProjectName 'Config' [upper(userName(1)) userName(2:end)] '.txt'];

if ~exist(configFileName, 'file')
    userDefaultConfigFileName = expUserDefaultConfig();
    fprintf('Copying default config file for user %s.\n', userName);
    
    fid = fopen(userDefaultConfigFileName, 'rt');
    fidw = fopen(configFileName, 'w');
    while ~feof(fid)
        text = fgetl(fid);
        if line ~= -1
            text = strrep(text, '<projectPath>', projectPath);
            text = strrep(text, '<userName>', userName);
            text = strrep(text, '<projectName>', projectName);
            fprintf(fidw, '%s\n', text);
        end
    end
    fclose(fid);
    fclose(fidw);    
    open(configFileName);
    disp(['Please update the file ' configFileName ' to suit your needs.']);    
end                                                                                                                                                                                                                                                                                                                           
function config = expConfigParse(configFileName)

config=[];
configFile=fopen(configFileName);
if configFile==-1,
    fprintf(2,['Unable to load the expCode config file for your project named: ' configFileName '.']); return;
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
            else
                if values{k}(1) == '{' || values{k}(1) == '[' || values{k}(end) == '}' || values{k}(end) == ']'
                    try
                        values{k} =  eval(values{k});
                    catch
                        fprintf(2,['Unable to parse definition of  ' names{k} ' in file ' configFileName '.\n']); return;
                    end
                    %                 else
                    %                     fprintf(2,['Unable to parse definition of  ' names{k} ' in file ' configFileName '.\n']); return;
                end
            end
        end
    else
        values{k} = '';
    end
end

try
config = cell2struct(values, names);
catch error
       fprintf(2,[error.message ' in file ' configFileName '\n']); return;
end

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
        elseif dependencyPath(1) == '~'
            dependencyPath = expandHomePath(dependencyPath);
        end
        addpath(genpath(dependencyPath));
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
function [userDefaultConfigFileName userDir] = expUserDefaultConfig(expCodePath)

if ~exist(expCodePath), return; end % FIXME

if ispc, userDir= getenv('USERPROFILE');
else userDir= getenv('HOME');
end

if ~exist([userDir filesep '.expCode'], 'dir')
    mkdir([userDir filesep '.expCode']);
end

userDefaultConfigFileName = [userDir filesep '.expCode' filesep getUserName() 'Config.txt'];
if ~exist(userDefaultConfigFileName, 'file')
    disp(['Creating default config in ' userDir filesep '.expCode' filesep]);
    copyfile([expCodePath '/expCodeConfig.txt'], userDefaultConfigFileName);
else
    expUpdateConfig(userDefaultConfigFileName);
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
function [ out ] = expandHomePath(in)
%EXPPATH Summary of this function goes here
%   Detailed explanation goes here

if ischar(in)
    out =  stringPath (in);
else
  out = cellfun(@stringPath, in, 'UniformOutput', 0);
end

function out =  stringPath (in)

in = strrep(in, '\', '/');

if ~isempty(in) && strcmp(in(1), '~')
   if ispc; 
       homePath= getenv('USERPROFILE'); 
   else
       homePath= getenv('HOME');
   end
   out = strrep(in, '~', homePath);
else    
    out = in;
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
