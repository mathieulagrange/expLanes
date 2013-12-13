function config = setConfigVariants(config)



minusConfig = setConfigVariantsIn(config, -1);
config = setConfigVariantsIn(config, 1);

for m=1:length(config.variants)
    fieldNames = fieldnames(config.variants{m});
    for l=1:length(fieldNames)
        if ~isfield(minusConfig.variants{m}, fieldNames{l})
            config.variants{m}.(fieldNames{l}) = NaN;
            config.parameters.list{m, l} = '';
        end
    end
    config.variants{m}.infoShortString = minusConfig.variants{m}.infoShortString;
    config.variants{m}.infoStringMask = minusConfig.variants{m}.infoStringMask;
end

p = config.parameters;
l=1;
toDelete=[];
for k=1:length(p.name)
    kSet = unique(p.list(:, k)) ;
    if length(kSet)>1
        p.set{l} = kSet;
        l=l+1;
    else
        toDelete(end+1) = k;
    end
end
p.name(toDelete) = [];
p.list(:, toDelete) = [];
p.set(:, toDelete) = [];
config.parameters = p;

function config = setConfigVariantsIn(config, mode)

% variantsFileName = [config.projectName 'Variants.txt'];
% variantsFileName = ['_' config.projectName 'Variants' config.userName '.txt'];
if ~exist('mode', 'var'), mode=1; end

variants = [];

config = selectParameters(config, mode);

if length(config.mask)==1
    configTmp = config;
    configTmp.mask = config.mask{1};
    [variants , config.allParameters, config.parameters, null, config.variantSequence] = expVariants(configTmp);
else
    variantSequence = {};
    config.parameters = [];
    for k=1:length(config.mask)
        configTmp = config;
        configTmp.mask = config.mask{k};
        
        [v, p, null, null, sequence] = expVariants(configTmp);
        for l=1:length(sequence)
            sequence{l} = sequence{l}+length(variants);
        end
        variantSequence = [variantSequence sequence];
        variants = [variants v];
        if k==1
            config.parameters = p;
        elseif size(config.parameters.list, 2) == size(p.list, 2)
            config.parameters.list = [config.parameters.list; p.list]; % FIXME wrong
        end
    end
    config.variantSequence = variantSequence;
    config.allParameters = config.parameters;
    
    icml=0;
    for k=1:length(variants)
        variants{k}.id = k;
        variants{k}.infoStringMasked = variants{k}.infoString;
        variants{k}.infoShortStringMasked = variants{k}.infoShortString;
        variants{k}.infoCellMasked = variants{k}.infoCell;
        icml = max(icml, length(variants{k}.infoCellMasked));
%         variants{k}.infoStringMask= 'all'; % FIXME could be improved and the infoId are wrong
%         iId(k, :) = variants{k}.infoId;
    end
end

config.variants = variants;


