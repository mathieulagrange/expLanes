function mask = expVariantStep(vSpec, mask, currentTask)

% complete mask according to currentTask
for k=1:length(vSpec.step)
    cp = regexp(vSpec.step{k}, ',', 'split');
    doTask=0;
    for m=1:length(cp)
        sp = regexp(cp{m}, ':', 'split');
        if ~isempty(sp{1})
            taskStepMin = str2double(sp{1});
            taskStepMax = taskStepMin;
        else
            taskStepMin = 1;
            taskStepMax = Inf;
        end
        if length(sp)>1 && ~isempty(sp{2})
            taskStepMax = str2double(sp{2});
        elseif length(sp)==2
            taskStepMax = Inf;
        end
        
        if taskStepMin<=currentTask && currentTask<=taskStepMax
            doTask = 1;
        end
    end
    if ~doTask
        mask{k} = -1;
    end
end