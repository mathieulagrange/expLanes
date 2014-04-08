function stepName = expStepName(projectPath, shortProjectName)

fInfo = dir([projectPath filesep shortProjectName '*.m']);

for k=1:length(fInfo)
    r =  regexp(fInfo(k).name, [shortProjectName '([1-9]+)(\w+).m'], 'tokens');
    if ~isempty(r)
        num = str2num(r{1}{1});
        stepName(num) = r{1}(2);
    end
end

for k=1:length(stepName)
    if isempty(stepName{k})
        error('Unable to find a continuous set of steps.'); 
    end
end

