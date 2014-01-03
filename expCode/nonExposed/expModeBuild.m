function v = expModeBuild(vSpec, vSet)

mask=[];
for k=1:size(vSet, 1)
    value = unique(vSet(k, :));
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
for k=1:length(mask)
    invFilter = [invFilter k];
    if size(vSpec.values{k}, 2)~=1
        if length(mask(k))==1 && mask(k) >0
            if isnumeric(vSpec.values{k}{1})
                m{k} = sprintf('%s: %g, ', vSpec.names{k}, vSpec.values{k}{mask(k)});
            else
                m{k} = sprintf('%s: %s, ', vSpec.names{k}, vSpec.values{k}{mask(k)});
            end
        else
            invFilterMask = [invFilterMask k];
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
    nbPruned = 0;
    for m=1:size(vSet, 1)
        if vSet(m, k)
            value = vSpec.values{m}{vSet(m, k)};
            mNames{end+1} = vSpec.names{m};
            if isnumeric(value)
                t{end+1} = strrep(sprintf('%s: %g', vSpec.names{m}, value), '.', '-');
                st{end+1} = strrep(sprintf('%s%g', vSpec.shortNames{m}, value), '.', '-');
            else
                t{end+1} = sprintf('%s: %s', vSpec.names{m}, value);
                sn = vSpec.shortValues{m}{vSet(m, k)};
                sn = [upper(sn(1)) sn(2:end)];
                st{end+1} = sprintf('%s%s', vSpec.shortNames{m},  sn);
            end
            if any(invFilter==m) % TODO wrong
               filter(end+1) = length(filter)+1; 
            end
            fm = find(invFilterMask==m);
            if any(fm)
               filterMask = [filterMask invFilterMask(fm)-nbPruned]; 
            end
        else
            nbPruned = nbPruned+1;
        end
    end
    
    [null, parameterOrder] = sort(mNames);
    vn{k} = sprintf('%s, ', t{parameterOrder(filter)}); 
    svn{k} = sprintf('%s_', st{parameterOrder(filter)}); 
    vnm{k} = sprintf('%s, ', t{filterMask}); 
    svnm{k} = sprintf('%s_', st{filterMask}); 
%     
%          cmTmp = v(end:-1:1, k);
%          cmm{k} = cmTmp;
%          cm{k} = cmTmp(invFilterMask);
end

for k=1:size(vSet, 2)
    for m=1:size(vSet, 1)
        if vSet(m, k)
            v(k).(vSpec.names{m})  = vSpec.values{m}{vSet(m, k)};
        else
            v(k).(vSpec.names{m})  = NaN;
        end
    end
    
    v(k).id = k;
    v(k).infoString = vn{k}(1:end-2) ;
    v(k).infoShortString = svn{k}(1:end-1);
    v(k).infoStringMasked = vnm{k}(1:end-2);
    v(k).infoShortStringMasked = svnm{k}(1:end-1);
    v(k).infoStringMask = maskInfo(1:end-2);
%          v(k).infoCellMasked = cm{k}';
%          v(k).infoCell = cmm{k}';
    v(k).infoModeNames = vSpec.names(invFilterMask);
    v(k).infoShortNames = vSpec.shortNames(invFilterMask);
    v(k).infoId = vSet(:, k)';
end