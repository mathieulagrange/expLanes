function maskFilter = expMaskFilter(vSpec, vSet)

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

% maskFilter.m = m;
maskFilter.maskInfo = maskInfo;
% maskFilter.filterMask = filterMask;
maskFilter.invFilter = invFilter;
maskFilter.invFilterMask = invFilterMask;