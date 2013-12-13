function config = expMerge (config, parameterName, mergeMethod, mergeData)

if nargin<2, parameterName = config.parameters.name{end}; end
if nargin<3, mergeMethod = 'mean'; end

% if isnumeric(parameterName)
%     parameterId = parameterName;
% else
parameterId = find(strcmp(config.allParameters.name, parameterName));
if isempty(parameterId),
    config.parameters = config.oriConfig.parameters;
    config.variants = config.oriConfig.variants;
    config.mask = config.oriConfig.mask;
    config.evaluation = config.oriconfig.evaluation;
    
    parameterId = find(strcmp(config.allParameters.name, parameterName));
    if isempty(parameterId),
        error(['Unable to find parameter with name ' parameterName]);
    end
end
% end

% reorder if needed
orderList = 1:length(config.allParameters.name);
if parameterId ~= length(config.allParameters.name)
    orderList(parameterId) = [];
    orderList(end+1) = parameterId;
    config = expOrder (config,  orderList);
    
    parameterId = length(config.parameters.name);
end

% merge
% TODO what if multiple metrics ??
nbMerge = length(config.parameters.set{parameterId});
nbMergedResults = length(config.variants)/nbMerge;
for k=1:nbMergedResults
    if strcmp(mergeMethod, 'stack')
        t = config.evaluation.results((k-1)*nbMerge+1:k*nbMerge, :, :);
        t=reshape(squeeze(t)', size(t, 2), size(t, 1)*size(t, 3)); % FIXME fails with more than one metric
        mergedResults{k} = t;
    elseif nargin<4 || isempty(mergeData)
        mergedResults{k} = feval(mergeMethod, config.evaluation.results((k-1)*nbMerge+1:k*nbMerge, :));
    else
        mergedResults{k} = feval(mergeMethod, config.evaluation.results((k-1)*nbMerge+1:k*nbMerge), config, (k-1)*nbMerge+1:k*nbMerge);
    end
end


[nrows, ncols] = cellfun(@size, mergedResults);
mResults = zeros(nbMergedResults, 1, max(ncols))*NaN;
for k=1:nbMergedResults
    mResults(k, 1, 1:length(mergedResults{k})) = mergedResults{k};
end

% generate new variant data
% TODO handle multiple masks
% ov=[];
% opp=[];
% uMask = unionMask(config.mask);
% uConfig = config;
% uConfig.mask = uMask;
% [cv p uConfig.parameters] = expVariants(uConfig);

for k=1:length(config.mask)
    op = find(strcmp(config.allParameters.name, parameterName));
    mask = config.mask{k};
    if length(mask)<parameterId
        tMask=arrayfun(@(x) 0,1:parameterId,'uni',false);
        tMask(1:length(mask)) = mask(:);
        mask = tMask;
    end
    mask{op} = -1;
    %     configTmp = config;
    %     configTmp.mask = mask; % FIXME multiple mask ?
    %
    %     [cv p cp] = expVariants(configTmp);
    config.mask{k} = mask;
    %     names = p.name;
end
config = setConfigVariants(config);
% config.variants = ov;
% config.parameters.name = uConfig.parameters;

config.evaluation.results = mResults;
% TODO add a way to set merge


function um = unionMask(m)

um = m{1};
for k=2:length(m)
    for l=1:length(m{k})
        um{l} = union(um{l}, m{k}{l});
    end
end
