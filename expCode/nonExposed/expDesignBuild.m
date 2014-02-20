function v = expDesignBuild(vSpec, vSet)

mask=[];
for k=1:size(vSet, 1)
    value = unique(vSet(k, :));
    value(value==0)=[];
    if length(value)==1
        if value==0
            mask(end+1) =  -1;
        else
            mask(end+1) =  value;
        end
    else
        mask(end+1) =  0;
    end
end



m={};
invFilter=[];
invFilterMask=[];
filterMask = [];
for k=1:length(mask)
    invFilter(end+1) = k;
    if size(vSpec.values{k}, 2)~=1
        if length(mask(k))==1 && mask(k) >0
            if isnumeric(vSpec.values{k}{1})
                m{k} = sprintf('%s: %g, ', vSpec.names{k}, vSpec.values{k}{mask(k)});
            else
                m{k} = sprintf('%s: %s, ', vSpec.names{k}, vSpec.values{k}{mask(k)});
            end
            filterMask(end+1) = k;
        else
            invFilterMask(end+1) = k;
        end
    end
end

if isempty(m)
    maskInfo='all, ';
else
    maskInfo = sprintf('%s', m{:});
end


for k=1:size(vSet, 2)
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
            if any(invFilter==m) % TODO wrong
                filter(end+1) = length(filter)+1;
            end
            fm = find(invFilterMask==m);
            if any(fm)
                prunedFilterMask = [prunedFilterMask invFilterMask(fm)-nbPruned];
                filterMask = [filterMask invFilterMask(fm)];
            end
        else
            nbPruned = nbPruned+1;
        end
    end
    
    for m=1:size(vSet, 1)
        if vSet(m, k)
            v(k).(vSpec.names{m})  = vSpec.values{m}{vSet(m, k)};
        else
            v(k).(vSpec.names{m})  = NaN;
        end
    end
    
    
    [null, parameterOrder] = sort(mNames);
    v(k).id = k;
    f = t(parameterOrder(filter));
    f(2, :) = {', '}; f(2, end) = {''};
    v(k).infoString = [f{:}];
    
    f = st(parameterOrder(filter));
    if ~isempty(skipIndex)
        [~, id] = sort(parameterOrder);
         f(id(skipIndex)) = [];
    end
    f(2, :) = {'_'}; f(2, end) = {''};
    v(k).infoShortString = [f{:}];
    
    f = t(prunedFilterMask);
    v(k).infoStringMasked = [f{:}];
    
    f = st(prunedFilterMask);
    f(2, :) = {'_'}; f(2, end) = {''};
    v(k).infoShortStringMasked = [f{:}];
    
    
    v(k).infoStringMask = maskInfo(1:end-2);
    
    f = vSpec.names(filterMask).';
    f(2, :) = {', '}; f(2, end) = {''};
    v(k).infoStringFactors = [f{:}];
    v(k).infoShortNames = vSpec.shortNames(invFilterMask);
    v(k).infoId = vSet(:, k)';
end
