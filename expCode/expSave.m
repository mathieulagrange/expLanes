function fileName = expSave(config, data, extension)

if ~exist('extension', 'var')
    extension = '.mat';
else
    [p n e] = fileparts(extension);
    extension = ['_' n '.mat'];
end

stepName = config.stepName{config.step.id};

path = [config.dataPath stepName filesep];

switch config.namingConventionForFiles
    case 'short'
        name = config.step.design.infoShortString; % FIXME should be masked
    case 'long'
        name = config.step.design.infoString; % FIXME should be masked
    case 'hash'
        name = DataHash(config.step.design.infoString); % FIXME should be masked
end

if config.dummy
    name = [name '_dummy_' num2str(config.dummy)];
end

if exist('data', 'var') && ~isempty(data)
    runId = config.runId;
    design = config.step.design;
    save([path name  extension ], 'data', 'stepName', 'runId', 'design');
end

fileName = [path name  extension];

