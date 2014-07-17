function dataDisplay = expFilter(config, p, data)
% filter data in various ways

if ~exist('data', 'var')
    data = config.evaluation.results;
end

observations = config.evaluation.observations;

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
            for m=1:length(observations)
                if isempty(fData{idx(n)}) && ~isfield(data{k}, observations{m})
                    data{k}.(observations{m}) = [];
                elseif ~isempty(fData{idx(n)})
                    if length(data)>=k && ~isempty(data{k}) && isfield(data{k}, observations{m})
                        d = fData{idx(n)}.(observations{m});
                        data{k}.(observations{m}) = [data{k}.(observations{m}); (d(:))];
                    else
                        d = fData{idx(n)}.(observations{m});
                        data{k}.(observations{m}) = (d(:));
                    end
                end
            end
        end
    end
end

% TODO clean this part
if  p.expand ~= 0
    if length(config.evaluation.observations)==1
        p.obs=1;
    end
    fData = data;
    observation = observations(p.obs);
    observations = strrep(config.step.oriFactors.values{p.expand}, '-', 'expCodeMinus');
    met={};
    met2={};
    ind = [];
    for m=1:length(observations)
        for k=1:length(observation)
            met = [met [observations{m} observation{k}]];
            met2 = [met2 observation{k}];
            ind(end+1) = m;
        end
    end
    fSize = length(fData)/length(observations);
    observations = met;
    p.obs = 1:length(observations);
    data={};
    for m=1:length(observations)
        observations{m} = [config.step.oriFactors.names{p.expand} observations{m}];
        for k=1:fSize
            if isempty(fData{(k-1)*length(observations)/length(observation)+ind(m)})
                data{k}.(observations{m}) = NaN;
            else
                data{k}.(observations{m}) = fData{(k-1)*length(observations)/length(observation)+ind(m)}.(met2{m});
            end
        end
    end
end

nbSettings = length(data);

if p.total
    for m=1:length(p.obs)
        for k=1:nbSettings
            if ~isempty(data{k})
                if length(data)>nbSettings && ~isempty(data{nbSettings+1}) && isfield(data{nbSettings+1}, observations{p.obs(m)})
                    data{nbSettings+1}.(observations{p.obs(m)}) = [data{nbSettings+1}.(observations{p.obs(m)}) data{k}.(observations{p.obs(m)})];
                else
                    data{nbSettings+1}.(observations{p.obs(m)}) = data{k}.(observations{p.obs(m)});
                end
            end
        end
    end
end

sData = [];
vData = [];
fData = [];
nbData = 0;
for m=1:length(p.obs)
    for k=1:length(data)
        if isempty(data{k}) || ~isfield(data{k}, observations{p.obs(m)})
            nbData(k, m, :) = 0;
            sData(k, m) = NaN;
            vData(k, m) = 0;
        else
            nbData(k, m) = length(data{k}.(observations{p.obs(m)}));
            sData(k, m) = mean(data{k}.(observations{p.obs(m)}));
            vData(k, m) = std(double(data{k}.(observations{p.obs(m)})));
        end
    end
end
nbData = max(nbData(:));
fData  = NaN*zeros(size(sData, 1), size(sData, 2), nbData);
for m=1:length(p.obs)
    for k=1:length(data)
        if ~isempty(data{k}) && isfield(data{k}, observations{p.obs(m)})
            datak = data{k}.(observations{p.obs(m)});
            fData(k, m, 1:length(datak)) = datak;
        end
    end
end

highlights = zeros(size(sData));
if p.highlight ~= -1
    if ~p.highlight
        p.highlight = 1:size(sData, 2);
    end
    for k=1:length(p.obs)
        %  col = round(sData(:, k)*10^config.tableDigitPrecision); % FIXME
        %  why ?
        if any(p.highlight==k)
            col = sData(:, k);
            [maxValue, maxIndex] = max(col);
            if any(vData(:, k))
                for m=1:length(data)
                    if ~isempty(data{m}) && ~isempty(data{m}.(observations{p.obs(k)}))
                        rejection = ttest2(double(data{m}.(observations{p.obs(k)})), double(data{maxIndex}.(observations{p.obs(k)})));
                        if isnan(rejection), rejection = 0; end
                        highlights(m, k) = ~rejection;
                    end
                end
                highlights(col==maxValue, k) = 2;
            else
                highlights(:, k) =  (col==maxValue)*2;
            end
        end
    end
    if p.total
        col = round(sData(end, :)*10^config.tableDigitPrecision);
        [maxValue, maxIndex] = max(col);
        
        if any(vData(end, :))
            for m=1:length(col)
                if ~isempty(data{end}.(observations{p.obs(m)}))
                    rejection = ttest2(data{end}.(observations{p.obs(m)}), data{end}.(observations{p.obs(maxIndex)}));
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
    vsk = config.step.set(k, select(1:min(length(select), size(config.step.set, 2))));
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
% dataDisplay.obs = p.obs;
dataDisplay.varData = vData(select, :);
dataDisplay.selector = select;
if isempty(settingSelector)
    dataDisplay.settingSelector = [];
else
    dataDisplay.settingSelector = settingSelector(select(1:min(length(select), length(settingSelector))));
end
