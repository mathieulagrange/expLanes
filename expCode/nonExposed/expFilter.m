function dataDisplay = expFilter(config, p)
% filter data in various ways

data = config.evaluation.results;
metrics = config.evaluation.metrics;

% fData = data;
settingSelector = 1:config.step.nbSettings;

if  p.expand ~= 0 % TODO allow expand with mutiple metrics
    % TODO allow for irregular number of settings per expanded item
    if length(config.evaluation.metrics)==1
        p.metric=1;
    end
    if ~p.metric
        error('Please select the metric you want to expand.');
    end
    % select one metric
    fData = (data(:, p.metric, :));
    if length(p.metric)==1 && p.expand >0
        % use one parameter to rearrange data
        pList = config.step.oriParameters.list(:, p.expand);
        nExpand = length(config.step.oriParameters.values{p.expand});
        %         settingSelector = (1:length(pList));
        % sort
        [null, idx] = sort(pList);
        %         settingSelector = settingSelector(idx);
        % cut
        fData = fData(idx, :, :);
        fSize = size(fData, 1)/nExpand;
        %         settingSelector = settingSelector(1:fSize);
        % reshape
        if p.integrate
            fData = reshape(fData, fSize, 1, nExpand*size(fData, 3));
        else
            fData = reshape(fData, fSize, nExpand, size(fData, 3));
        end
    end
elseif  p.integrate ~= 0
    fData = data;
    parameters = 1:length(config.step.oriParameters.names);
    parameters(p.integrate)=[];
    for k=1:length(config.step.oriParameters.list)
        pList{k} = [config.step.oriParameters.list{k, parameters}];
    end
    [modalityNames a modalityIndexes]=unique(pList);
    
    data={};
    for k=1:length(modalityNames)
        idx = find(modalityIndexes == k);
        for n=1:length(idx)
            for m=1:length(metrics)
                if isempty(fData{idx(n)})
                    data{k}.(metrics{m}) = 0;
                else
                    if length(data)>=k && ~isempty(data{k}) && isfield(data{k}, metrics{m})
                        data{k}.(metrics{m}) = [data{k}.(metrics{m}); fData{idx(n)}.(metrics{m})];
                    else
                        data{k}.(metrics{m}) = fData{idx(n)}.(metrics{m});
                    end
                end
            end
        end
    end
    
end

if p.metric==0
    p.metric = 1:length(config.evaluation.metrics);
end

for k=1:length(data)
    for m=1:length(p.metric)
        if isempty(data{k})
            sData(k, m) = NaN;
            vData(k, m) = 0;
        else
        sData(k, m) = mean(data{k}.(metrics{p.metric(m)}));
        vData(k, m) = std(data{k}.(metrics{p.metric(m)}));
        end
    end
end
highlights = zeros(size(sData));
if p.highlight ~= -1
    if ~p.highlight
        p.highlight = 1:size(sData, 2);
    end
    for k=1:length(p.metric)
        col = round(sData(:, k)*10^config.displayDigitPrecision);
        [maxValue maxIndex] = max(col);
        
        if any(vData(:))
            for m=1:length(data)
                if ~isempty(data{m})
                highlights(m, k) = ~ttest2(data{m}.(metrics{p.metric(k)}), data{maxIndex}.(metrics{p.metric(k)}));
                end
            end
        else
            highlights(:, k) =  col==maxValue;
        end
    end
end

% if ndims(data) == 3
%     sData = squeeze(nanmean(fData, 3));
%     vData = squeeze(nanstd(fData, 0, 3));
%     highlights = zeros(size(sData));
%     % FIXME move this at display time
%     if p.highlight ~= -1
%         if ~p.highlight
%             p.highlight = 1:size(sData, 2);
%         end
%         for k=p.highlight
%             [null, maxIndex] = max(sData(:, k));
%             maxIndex = maxIndex(1);
%             tData = squeeze(fData(:, k, :));
%             tData = bsxfun(@minus, tData, tData(maxIndex, :));
%             tRes = ttest(tData')';
%             tRes(maxIndex) = 0;
%             tRes(isnan(tRes)) = 0; % handle special case of identity
%             highlights(:, k) = tRes==0;
%         end
%     end
% else
%     sData = fData;
%     vData = zeros(size(sData));
%     highlights = zeros(size(fData));
%     if p.highlight
%         for k=1:size(fData, 2)
%             col = round(fData(:, k)*10^config.displayDigitPrecision);
%             maxValue = max(col);
%             highlights(:, k) =  col==maxValue;
%         end
%     end
% end

if size(sData, 2) == 1
    select = ~isnan(sData');
else
    select = ~all(isnan(sData'));
end

parameterSelected = {};
for k=1:length(config.factors.names)
    vsk = config.step.set(k, select);
    vsk(vsk==0)=[];
    if length(unique(vsk))>1
        parameterSelected(end+1) = config.factors.names(k);
    end
end

parameterSelector = [];
for k=1:length(config.step.parameters.names)
    if any(strcmp(parameterSelected, config.step.parameters.names{k}))
        parameterSelector(end+1) = k;
    end
end
% if  p.expand ~= 0;
%     parameterSelector(parameterSelector==p.expand)=[];
% end

dataDisplay.rawData = data;
% dataDisplay.filteredData = squeeze(fData);
% if isvector(dataDisplay.filteredData)
%     dataDisplay.filteredData = dataDisplay.filteredData(:).';
% end
dataDisplay.meanData = sData(select, :);
dataDisplay.highlights = highlights(select, :);
dataDisplay.parameterSelector = parameterSelector;
% dataDisplay.p.expand = p.expand;
dataDisplay.p.metric = p.metric;
dataDisplay.varData = vData(select, :);
dataDisplay.selector = select;
if isempty(settingSelector)
    dataDisplay.settingSelector = [];
else
    dataDisplay.settingSelector = settingSelector(select);
end



