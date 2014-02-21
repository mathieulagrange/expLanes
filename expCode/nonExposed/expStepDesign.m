function stepDesign = expStepDesign(vSpec, mask, currentStep)

vSet = expDesignSet(vSpec, mask, currentStep);

maskFilter = expMaskFilter(vSpec, vSet);
% designs = expDesignBuild(vSpec, vSet);

sequence = expDesignSequence(vSpec, vSet);

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

stepDesign.nbDesigns = size(vSet, 2);
stepDesign.maskFilter = maskFilter;
stepDesign.sequence = sequence;
stepDesign.parameters = parameters;
stepDesign.set = vSet;
stepDesign.specifications = vSpec;
stepDesign.id = currentStep;

stepDesign.design = expDesign(stepDesign, 1);



