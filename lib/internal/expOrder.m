function [config, permutationVector] = expOrder(config, order)

order = [order setdiff(1:length(config.factors.names), order)];

vSpec = config.factors;

vSpec.names = vSpec.names(order);
vSpec.shortNames = vSpec.shortNames(order);
vSpec.values = vSpec.values(order);
vSpec.shortValues = vSpec.shortValues(order);
vSpec.stringValues = vSpec.stringValues(order);
vSpec.step = vSpec.step(order);


select = vSpec.selectFactors;
[null, io] = sort(order);
for k=1:length(select)
    c = regexp(select{k}, '/', 'split');
    select{k} = [num2str(io(str2num(c{1}))) '/' num2str(io(str2num(c{2}))) '/' c{3}];
    if length(c)==4
        select{k} = [select{k}  '/' c{4}];
    end
end
vSpec.selectFactors = select;

deselect = vSpec.deselectFactors;
for k=1:length(deselect)
    c = regexp(deselect{k}, '/', 'split');  
    
   deselect{k} = [num2str(io(str2num(c{1}))) '/-' c{2} '/[' num2str(io(str2num(c{3}))) ']']; 
    if length(c)==4
        deselect{k} = [deselect{k}  '/' c{4}];
    end
end
vSpec.deselectFactors = deselect;

vSet = config.step.set;
mask =  config.mask{1};
if length(mask)<length(order)
    mask = [mask num2cell(zeros(1, length(order)-length(mask)))];
end
mask = mask(order);
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

config.factors = vSpec;
config.evaluation.results = config.evaluation.results(permutationVector);