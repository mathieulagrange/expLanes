function [config, factors, factorsName] = expModifyExposition(config, factors)

if ~isnumeric(factors)
    if ~iscell(factors)
        factors = {factors};
    end
    for k=1:length(factors)
        factorIndex(k) = find(strcmp(config.factors.names, factors{k}));
        if isempty(factorIndex(k))
            error(['Unable to find factor ' factors{k}]);
        end
    end
    factors = factorIndex;
end
factorsName = config.factors.names(factors);
mask = config.mask;
for k=1:length(mask)
    for m=1:length(factors)
        if sum(size(mask{k}))<factors(m)
            mask{k} = [mask{k} num2cell(zeros(1,  factors(m)-length(mask{k})))];
        end
        mask{k}{factors(m)} = -1;
    end
end

for k=1:length(factorsName)
    factors(k) = find(strcmp(config.step.factors.names, factorsName{k}));
end
oriStep = config.step;
config.step = expStepSetting(config.factors, mask, config.step.id);
config.step.oriFactors = oriStep.factors;