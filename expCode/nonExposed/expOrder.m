function [config, permutationVector] = expOrder(config, order)

order = [order setdiff(1:length(config.factors.names), order)]; % TODO test should fail

vSpec = config.factors;

vSpec.names = vSpec.names(order);
vSpec.shortNames = vSpec.shortNames(order);
vSpec.values = vSpec.values(order);
vSpec.shortValues = vSpec.shortValues(order);
vSpec.stringValues = vSpec.stringValues(order);
vSpec.step = vSpec.step(order);

% [b p] = sort(order);
% sf = vSpec.selectFactors;
% for k=1:length(sf)
%         sf{k}(1) = num2str(p(str2num(sf{k}(1))));
%         sf{k}(3) = num2str(p(str2num(sf{k}(3))));
% end
% vSpec.selectFactors = sf;

select = vSpec.selectFactors;
[null io] = sort(order);
for k=1:length(select)
    c = regexp(select{k}, '/', 'split');
    select{k} = [num2str(io(str2num(c{1}))) '/' num2str(io(str2num(c{2}))) '/' c{3}];
end
vSpec.selectFactors = select;

vSet = config.step.set;
mask =  config.mask{1}(order);
mask = {mask};
config.step = expStepSetting(vSpec,mask, config.step.id);
config.mask = mask;
for k=1:size(vSet, 2)
    for m=1:size(vSet, 2)
        if all(vSet(order, k)==config.step.set(:, m))
            permutationVector(m) = k;
        end
    end
end

% config.step.set = vSet;
config.factors = vSpec;
config.evaluation.results = config.evaluation.results(permutationVector);