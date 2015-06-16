function stepName = expStepName(experimentPath, shortExperimentName)

fInfo = dir([experimentPath filesep shortExperimentName '*.m']);

for k=1:length(fInfo)
    r =  regexp(fInfo(k).name, [shortExperimentName '([1-9]+)(\w+).m'], 'tokens');
    if ~isempty(r)
        num = str2num(r{1}{1});
        stepName(num) = r{1}(2);
    end
end

if  length(unique(stepName)) ~=  length(stepName)
            error('Steps must have different names.'); 
end

for k=1:length(stepName)
    if isempty(stepName{k})
        error('Unable to find a continuous set of steps.'); 
    end
end

