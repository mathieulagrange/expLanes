function [names, structId] = expGetStepVariables(config, stepId, type)

stepFileName = [config.codePath config.shortExperimentName num2str(stepId) config.stepName{stepId} '.m'];

names = {};
structNames = {};
if ~exist(stepFileName, 'file'), error(['Unable to open ' stepFileName]); end
fid = fopen(stepFileName);
while ~feof(fid)
    line = fgetl(fid);
    line = regexp(line, '%', 'split');
    match = regexp(line{1}, [type '\.(\w+)'], 'match');
    for k=1:length(match)
        names{end+1} = match{k}(length(type)+2:end);
    end
    match = regexp(line{1}, [type '\.(\w+)\.'], 'match');
    for k=1:length(match)
        structNames{end+1} = match{k}(length(type)+2:end-1);
    end
end
fclose(fid);

names = unique(names);
structId = zeros(1, length(names));
if ~isempty(structNames)
    structNames = unique(structNames);
    names = ([setdiff(names, structNames) structNames]);
    structId = zeros(1, length(names));
    structId(end-length(structNames)+1:end) = 1;
end