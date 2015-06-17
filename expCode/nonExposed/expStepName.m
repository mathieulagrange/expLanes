function stepName = expStepName(config, experimentPath, shortExperimentName)

fInfo = dir([experimentPath filesep shortExperimentName '*.m']);
stepName = {};
for k=1:length(fInfo)
    r =  regexp(fInfo(k).name, [shortExperimentName '([1-9]+)(\w+).m'], 'tokens');
    if ~isempty(r)
        num = str2num(r{1}{1});
        stepName(num) = r{1}(2);
    end
end

if isempty(stepName) && ~isempty(config.addStep);
    fprintf(2, 'No processing steps detected, please add steps using the ''addStep'' command.\n');
end

if  length(unique(stepName)) ~=  length(stepName)
            error('Steps must have different names.'); 
end

for k=1:length(stepName)
    if isempty(stepName{k})
        error('Unable to find a continuous set of steps.'); 
    end
end

