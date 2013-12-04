function taskName = expTaskName(projectPath, shortProjectName)

fInfo = dir([projectPath shortProjectName '*.m']);

for k=1:length(fInfo)
    r =  regexp(fInfo(k).name, [shortProjectName '([1-9]+)(\w+).m'], 'tokens');
    if ~isempty(r)
        num = str2num(r{1}{1});
        taskName(num) = r{1}(2);
    end
end

for k=1:length(taskName)
    if isempty(taskName{k})
        error('Unable to find a continuous set of tasks.'); 
    end
end

