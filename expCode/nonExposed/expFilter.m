function dataDisplay = expFilter(config, p, data)
% filter data in various ways

if ~exist('data', 'var')
data = config.evaluation.results;
end
metrics = config.evaluation.metrics;

settingSelector = 1:config.step.nbSettings;


if isnumeric(p.integrate) && all(p.integrate ~= 0)
    fData = data;
    factors = 1:length(config.step.oriFactors.names);
    factors(p.integrate)=[];
    for k=1:size(config.step.oriFactors.list, 1)
        pListOri{k} = [config.step.oriFactors.list{k, factors}];
    end
    %     [modalityNames a modalityIndexes]=unique(pList);
    
    factors = 1:length(config.step.factors.names);
    for k=1:size(config.step.factors.list, 1)
        pList{k} = [config.step.factors.list{k, factors}];
    end
    
    data={};
    for k=1:length(pList)
         idx = find(ismember(pListOri, pList{k}));
        for n=1:length(idx)
            for m=1:length(metrics)
                if isempty(fData{idx(n)}) && ~isfield(data{k}, metrics{m})
                    data{k}.(metrics{m}) = [];
                elseif ~isempty(fData{idx(n)})
                    if length(data)>=k && ~isempty(data{k}) && isfield(data{k}, metrics{m})
                        d = fData{idx(n)}.(metrics{m});
                        data{k}.(metrics{m}) = [data{k}.(metrics{m}); (d(:))];
                    else
                        d = fData{idx(n)}.(metrics{m});
                        data{k}.(metrics{m}) = (d(:));
                    end
                end
            end
        end
    end
end

% TODO clean this part
if  p.expand ~= 0
    if length(config.evaluation.metrics)==1
        p.metric=1;
    end
   fData = data;
    metric = metrics(p.metric);
    metrics = config.step.oriFactors.values{p.expand};
    met={};
    met2={};
      for m=1:length(metrics)
      for k=1:length(metric)
            met = [met [metrics{m} metric{k}]];
            met2 = [met2 metric{k}];           
        end
    end
    fSize = length(fData)/length(metrics);
    metrics = met;
    p.metric = 1:length(metrics);
    data={};
    for m=1:length(metrics)
        metrics{m} = [config.step.oriFactors.names{p.expand} metrics{m}];
        for k=1:fSize
            data{k}.(metrics{m}) = fData{floor((m-1)/length(metric))*fSize+k}.(met2{m});
        end
    end
end

nbSettings = length(data);

if p.total
    for m=1:length(p.metric)
        for k=1:nbSettings
            if length(data)>nbSettings && ~isempty(data{nbSettings+1}) && isfield(data{nbSettings+1}, metrics{p.metric(m)})
                data{nbSettings+1}.(metrics{p.metric(m)}) = [data{nbSettings+1}.(metrics{p.metric(m)}); data{k}.(metrics{p.metric(m)})];
            else
                data{nbSettings+1}.(metrics{p.metric(m)}) = data{k}.(metrics{p.metric(m)});
            end
        end
    end
end

sData = [];
vData = [];
fData = [];
nbData = 0;
for m=1:length(p.metric)
    for k=1:length(data)
        if isempty(data{k})
            nbData(k, m, :) = 0;
            sData(k, m) = NaN;
            vData(k, m) = 0;
        else
            nbData(k, m) = length(data{k}.(metrics{p.metric(m)}));
            sData(k, m) = mean(data{k}.(metrics{p.metric(m)}));
            vData(k, m) = std(double(data{k}.(metrics{p.metric(m)})));
        end
    end
end
nbData = max(nbData);
fData  = NaN*zeros(size(sData, 1), size(sData, 2), nbData);
for m=1:length(p.metric)
    for k=1:length(data)
        if isempty(data{k})
        else
            datak = data{k}.(metrics{p.metric(m)});
            fData(k, m, 1:length(datak)) = datak;
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
        
        if any(vData(:, k))
            for m=1:length(data)
                if ~isempty(data{m}) && ~isempty(data{m}.(metrics{p.metric(k)}))
                    rejection = ttest2(double(data{m}.(metrics{p.metric(k)})), double(data{maxIndex}.(metrics{p.metric(k)})));
                    if isnan(rejection), rejection = 0; end
                    highlights(m, k) = ~rejection;
                end
            end
        else
            highlights(:, k) =  col==maxValue;
        end
    end
    if p.total
        col = round(sData(end, :)*10^config.displayDigitPrecision);
        [maxValue maxIndex] = max(col);
        
        if any(vData(end, :))
            for m=1:length(col)
                if ~isempty(data{end}.(metrics{p.metric(m)}))
                    rejection = ttest2(data{end}.(metrics{p.metric(m)}), data{end}.(metrics{p.metric(maxIndex)}));
                    if isnan(rejection), rejection = 0; end
                    highlights(end, m) = ~rejection;
                end
            end
        else
            highlights(end, :) =  col==maxValue;
        end
    end
end

if size(sData, 2) == 1
    select = ~isnan(sData');
else
    select = ~all(isnan(sData'));
end


factorSelected = {};
for k=1:length(config.factors.names)
    vsk = config.step.set(k, select(1:min(length(select):size(config.step.set, 2))));
    vsk(vsk==0)=[];
    if length(unique(vsk))>1
        factorSelected(end+1) = config.factors.names(k);
    end
end


factorSelector = [];
for k=1:length(config.step.factors.names)
    if any(strcmp(factorSelected, config.step.factors.names{k}))
        factorSelector(end+1) = k;
    end
end
% if  p.expand ~= 0;
%     factorSelector(factorSelector==p.expand)=[];
% end

dataDisplay.rawData = data;
dataDisplay.filteredData = squeeze(fData);
% if isvector(dataDisplay.filteredData)
%     dataDisplay.filteredData = dataDisplay.filteredData(:).';
% end
dataDisplay.meanData = sData(select, :);
dataDisplay.highlights = highlights(select, :);
dataDisplay.factorSelector = factorSelector;
% dataDisplay.p.expand = p.expand;
% dataDisplay.p.metric = p.metric;
dataDisplay.varData = vData(select, :);
dataDisplay.selector = select;
if isempty(settingSelector)
    dataDisplay.settingSelector = [];
else
    dataDisplay.settingSelector = settingSelector(select(1:min(length(select), length(settingSelector))));
end
