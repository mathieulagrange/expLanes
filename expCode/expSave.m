function fileName = expSave(config, data, extension)


if ~exist('extension', 'var')
    extension = '.mat';
else
    [p n e] = fileparts(extension);
    extension = ['_' n '.mat'];
end

taskName = config.taskName{config.currentTask};

path = [config.dataPath taskName filesep];

name = config.currentVariant.infoShortString;

if config.dummy
    name = [name '_dummy_' num2str(config.dummy)];
end

if exist('data', 'var') && ~isempty(data)
    runId = config.runId;
    save([path name  extension ], 'data', 'taskName', 'runId');
end

fileName = [path name  extension];

