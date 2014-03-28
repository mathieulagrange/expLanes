function setting = expSetting(step, k)

vSpec = step.specifications;
vSet =  step.set;
maskFilter = step.maskFilter;


t={};
st={};
mNames={};
filter=[];
filterMask=[];
prunedFilterMask=[];
nbPruned = 0;
skipIndex = [];
for m=1:size(vSet, 1)
    if vSet(m, k)
        value = vSpec.values{m}{vSet(m, k)};
        mNames{end+1} = vSpec.names{m};
        if isnumeric(value)
            t{end+1} = strrep(sprintf('%s: %g', vSpec.names{m}, value), '.', '-');
            st{end+1} = strrep(sprintf('%s%g', vSpec.shortNames{m}, value), '.', '-');
            if ~value
                skipIndex(end+1) = length(mNames);
            end
        else
            t{end+1} = sprintf('%s: %s', vSpec.names{m}, value);
            sn = vSpec.shortValues{m}{vSet(m, k)}; % TODO put shortValues as unsafe option
            sn = [upper(sn(1)) sn(2:end)];
            st{end+1} = sprintf('%s%s', vSpec.shortNames{m},  sn);
            if strcmp(value, 'none')
                skipIndex(end+1) = length(mNames);
            end
            
        end
        if any(maskFilter.invFilter==m) % TODO wrong
            filter(end+1) = length(filter)+1;
        end
        fm = find(maskFilter.invFilterMask==m);
        if any(fm)
            prunedFilterMask = [prunedFilterMask maskFilter.invFilterMask(fm)-nbPruned];
            filterMask = [filterMask maskFilter.invFilterMask(fm)];
        end
    else
        nbPruned = nbPruned+1;
    end
end

for m=1:size(vSet, 1)
    if vSet(m, k)
        setting.(vSpec.names{m})  = vSpec.values{m}{vSet(m, k)};
    else
        setting.(vSpec.names{m})  = NaN;
    end
end


[null, parameterOrder] = sort(mNames);
setting.id = k;
f = t(parameterOrder(filter));
if ~isempty(f)
    f(2, :) = {', '}; f(2, end) = {''};
end
setting.infoString = [f{:}];


f = st(parameterOrder(filter));
if ~isempty(skipIndex)
    [~, id] = sort(parameterOrder);
    f(id(skipIndex)) = [];
end
if ~isempty(f)
    f(2, :) = {'_'}; f(2, end) = {''};
end
setting.infoShortString = [f{:}];

f = t(prunedFilterMask);
if ~isempty(f)
    f(2, :) = {', '}; f(2, end) = {''};
end
setting.infoStringMasked = [f{:}];

f = st(prunedFilterMask); % TODO should output something
if ~isempty(f)
    f(2, :) = {'_'}; f(2, end) = {''};
end
setting.infoShortStringMasked = [f{:}];


setting.infoStringMask = maskFilter.maskInfo(1:end-2);

f = vSpec.names(filterMask).';
f(2, :) = {', '}; f(2, end) = {''};
setting.infoStringFactors = [f{:}];
setting.infoShortNames = vSpec.shortNames(maskFilter.invFilterMask);
setting.infoId = vSet(:, k)';