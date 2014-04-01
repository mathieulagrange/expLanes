function mask = expSettingStepMask(vSpec, mask, currentStep)

% complete mask according to currentStep
for k=1:length(vSpec.step)
    cp = regexp(vSpec.step{k}, ',', 'split');
    doStep=0;
    for m=1:length(cp)
        sp = regexp(cp{m}, ':', 'split');
        if ~isempty(sp{1})
            stepStepMin = str2double(sp{1});
            stepStepMax = stepStepMin;
        else
            stepStepMin = 1;
            stepStepMax = Inf;
        end
        if length(sp)>1 && ~isempty(sp{2})
            stepStepMax = str2double(sp{2});
        elseif length(sp)==2
            stepStepMax = Inf;
        end
        
        if stepStepMin<=currentStep && currentStep<=stepStepMax
            doStep = 1;
        end
    end
    if ~doStep
        for m=1:length(mask)
            mask{m}{k} = -1;
        end
    end
end