function stepMode = expModes(vSpec, mask, currentStep)

vSet = expModeSet(vSpec, mask, currentStep);

modes = expModeBuild(vSpec, vSet);

sequence = expModeSequence(vSpec, vSet);

e=[];
for k=1:size(vSet, 1)
    for m=1:size(vSet, 2)
        if vSet(k, m)
            list{k, m} = vSpec.stringValues{k}{vSet(k, m)};
        else
            list{k, m} = '';
        end
    end
    if ~all(cellfun(@isempty,list(k, :)))
        e(end+1) = k;
    end
    values{k} = unique(list(k, :));
    values{k}(cellfun(@isempty,values{k}))=[];
end

parameters.list = list(e, :)';
parameters.names = vSpec.names(e);
parameters.values = values(e);

stepMode.modes = modes;
stepMode.sequence = sequence;
stepMode.parameters = parameters;
stepMode.set = vSet;
stepMode.id = currentStep;


