function config = setConfigModes(config)



minusConfig = setConfigModesIn(config, -1);
config = setConfigModesIn(config, 1);

for m=1:length(config.modes)
    fieldNames = fieldnames(config.modes{m});
    for l=1:length(fieldNames)
        if ~isfield(minusConfig.modes{m}, fieldNames{l})
            config.modes{m}.(fieldNames{l}) = NaN;
            config.parameters.list{m, l} = '';
        end
    end
    config.modes{m}.infoShortString = minusConfig.modes{m}.infoShortString;
    config.modes{m}.infoStringMask = minusConfig.modes{m}.infoStringMask;
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

function config = setConfigModesIn(config, mode)

% modesFileName = [config.projectName 'Modes.txt'];
% modesFileName = ['_' config.projectName 'Modes' config.userName '.txt'];
if ~exist('mode', 'var'), mode=1; end

modes = [];

config = selectFactors(config, mode);

if length(config.mask)==1
    configTmp = config;
    configTmp.mask = config.mask{1};
    [modes , config.allFactors, config.parameters, null, config.modeSequence] = expModes(configTmp);
else
    modeSequence = {};
    config.parameters = [];
    for k=1:length(config.mask)
        configTmp = config;
        configTmp.mask = config.mask{k};
        
        [v, p, null, null, sequence] = expModes(configTmp);
        for l=1:length(sequence)
            sequence{l} = sequence{l}+length(modes);
        end
        modeSequence = [modeSequence sequence];
        modes = [modes v];
        if k==1
            config.parameters = p;
        elseif size(config.parameters.list, 2) == size(p.list, 2)
            config.parameters.list = [config.parameters.list; p.list]; % FIXME wrong
        end
    end
    config.modeSequence = modeSequence;
    config.allFactors = config.parameters;
    
    icml=0;
    for k=1:length(modes)
        modes{k}.id = k;
        modes{k}.infoStringMasked = modes{k}.infoString;
        modes{k}.infoShortStringMasked = modes{k}.infoShortString;
        modes{k}.infoCellMasked = modes{k}.infoCell;
        icml = max(icml, length(modes{k}.infoCellMasked));
%         modes{k}.infoStringMask= 'all'; % FIXME could be improved and the infoId are wrong
%         iId(k, :) = modes{k}.infoId;
    end
end

config.modes = modes;


