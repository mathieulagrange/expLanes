function fileName = expSave(config, data, extension, write)
% expSave save data to the the repository of the current task
%	fileName = expSave(config, data, extension)
%	- config: expLanes configuration
%	- data: data to be saved
%	- extension: string appended at the end of the name of the file
%	-- fileName: name of the file used to store the data

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.

if ~exist('write', 'var'), write=1; end

if ~exist('extension', 'var')
    extension = '';
else
    [p, n] = fileparts(extension);
    extension = ['_' n ''];
end

stepName = config.stepName{config.step.id};

if ~isempty(strfind(extension, '_obs')) && ~isempty(config.obsPath)
    path = [config.obsPath stepName '/'];
else
    path = [config.dataPath stepName '/'];
end
% path = [config.dataPath stepName '/'];

% config.step.setting.infoString
switch config.namingConventionForFiles
    case 'short'
        name = config.step.setting.infoShortString; % FIXME should be masked
    case 'long'
        name = config.step.setting.infoString; % FIXME should be masked
    case 'hash'
        name = DataHash(config.step.setting.infoString); % FIXME should be masked
end

if config.dummy
    name = [name '_dummy_' num2str(config.dummy)];
end

fileName = [path name  extension];

if write || (exist('data', 'var') && ~isempty(data))
    data.info = expStripConfig(config);
    data.info.settingFileName = fileName;
    save(fileName, 'data', ['-v' num2str(config.encodingVersion)]);
end

function c = expStripConfig(config)

c.runId = config.runId;  
c.setting = config.step.setting; 
c.stepName = config.stepName{config.step.id};
c.userName = config.userName;
c.codePath = config.codePath;
c.dataPath = config.dataPath;
c.inputPath = config.inputPath;
c.obsPath = config.obsPath;
c.setting = config.step.setting;
