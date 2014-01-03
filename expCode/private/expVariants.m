function stepVariant = expVariants(vSpec, mask, currentStep)

vSet = expVariantSet(vSpec, mask, currentStep);

variants = expVariantBuild(vSpec, vSet);

sequence = expVariantSequence(vSpec, vSet);

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

stepVariant.variants = variants;
stepVariant.sequence = sequence;
stepVariant.parameters = parameters;
stepVariant.set = vSet;
stepVariant.id = currentStep;


