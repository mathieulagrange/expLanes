function stepSetting = expStepSetting(vSpec, mask, currentStep)

vSet = expSettingSet(vSpec, mask, currentStep);

maskFilter = expMaskFilter(vSpec, vSet);
% settings = expSettingBuild(vSpec, vSet);

sequence = expSettingSequence(vSpec, vSet);

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

factors.list = list(e, :)';
factors.names = vSpec.names(e);
factors.values = values(e);

stepSetting.nbSettings = size(vSet, 2);
stepSetting.maskFilter = maskFilter;
stepSetting.sequence = sequence;
stepSetting.factors = factors;
stepSetting.set = vSet;
stepSetting.specifications = vSpec;
stepSetting.id = currentStep;

stepSetting.setting = expSetting(stepSetting, 1);


