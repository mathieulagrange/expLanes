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
    data.info.runId = config.runId; %#ok<NASGU> 
    data.info.setting = config.step.setting; %#ok<NASGU>
    data.info.stepName = stepName;
    data.info.userName = config.userName;
    config.waitBar = [];
    data.info.config = config;
    data.info.setting.fileName = fileName;
    save(fileName, 'data', ['-v' num2str(config.encodingVersion)]);
end



