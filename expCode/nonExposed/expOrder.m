function [config, permutationVector] = expOrder(config, order)

order = [order setdiff(1:length(config.factors.names), order)]; % TODO test should fail

vSpec = config.factors;

vSpec.names = vSpec.names(order);
vSpec.shortNames = vSpec.shortNames(order);
vSpec.values = vSpec.values(order);
vSpec.stringValues = vSpec.stringValues(order);
vSpec.step = vSpec.step(order);

select = vSpec.selectParameters;
[null io] = sort(order);
for k=1:length(select)
    c = regexp(select{k}, '/', 'split');
    select{k} = [num2str(io(str2num(c{1}))) '/' num2str(io(str2num(c{2}))) '/' c{3}];
end
vSpec.selectParameters = select;

config.step = expStepDesign(vSpec, config.mask, config.step.id);

for k=1:size(vSet, 2)
    for m=1:length(vSet)
        if all(vSet(:, k)==config.step.set(order, m))
            permutationVector(k) = m;
        end
    end
end

config.step.set = vSet;
config.evaluation.results = config.evaluation.results(permutationVector, :, :);