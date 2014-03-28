function [modes, parameters, parametersMasked, order, sequence] = expModes(config)

% if mod(nargin, 2)
%     config = varargin{nargin};
% else
%     config.mask={{}};
% end

values = config.factorSpecifications.values;
names = config.factorSpecifications.names;
shortNames = config.factorSpecifications.shortNames;
shortValues = config.factorSpecifications.shortValues;
step = config.factorSpecifications.step;

if isempty(config.mask) || isempty(config.mask{1})
    mask = cell(1, size(values, 2));
    mask(:) = {0};
elseif length(config.mask)<length(names)
    %     mask = [mask num2cell(-ones(1, length(names)-length(mask)))];
    mask = [config.mask num2cell(zeros(1, length(names)-length(config.mask)))]; % FIX ME fragile
else
    mask = config.mask;
end

seq=0;
for k=1:length(step)
    step{k} = strtrim(step{k});
    if length(step{k}) ~= length(regexp(step{k}, '[0-9s]', 'match'))
        error(['Unrecognized step definition for parameter ', names{k}]);
    end
    sMatch = strfind(step{k}, 's');
    if any(sMatch)
        config.sequentialFactor = names{k};
        seq=seq+1;
        step{k}(sMatch==1) = [];
    end
    if length(step{k})==1
        taskStep = str2double(step{k});
    else
        taskStep = 1;
    end
    
    if taskStep>config.currentTask
        mask{k} = -1;
    end
end

if seq>1, error('Only one sequential parameter is allowed'); end

if isfield(config, 'order')
    if length(config.order) > length(names)
        error('selection vector is not of the right size');
    elseif length(config.order) < length(names)
        order = [config.order setdiff(1:length(names), config.order)];
    else
        order = config.order;
    end
    names = names(order);
    values = values(order);
   shortValues = shortValues(order);
    
else
    order = 1:length(names); % FIXME fragile
end

if isempty(names), values=[]; return; end

keep=[];
for k=1:length(mask) % FIXME multiple mask ?
    if mask{k}(1) ~= -1 %|| length(modes{k})==1 || ischar(modes{k})
        keep(end+1) = k;
    end
end
names = names(keep);
shortNames = shortNames(keep);
values = values(keep);
shortValues = shortValues(keep);
mask = mask(order(keep)); % TODO fails when permuting

% mask = mask(order);

[null, parameterOrder] = sort(names);
% parameterOrder=1:length(names);
% shortNames=names2shortNames(names);

for k=1:size(values, 2)
    if isnumeric(values{k})
        values{k} = num2cell(values{k});
        shortValues{k} = num2cell(shortValues{k});
    elseif ischar(values{k})
        values{k} = values(k);
        shortValues{k} = shortValues(k);
    end
end

% for k=1:length(values)
%     shortValues{k} = names2shortNames(values{k});
% end


[v sv n] = buildModesCell(values, shortValues, mask);

m={};
invFilter=[];
invFilterMask=[];
for k=1:length(mask)
    invFilter = [invFilter k];
    %     invFilterMask = [invFilterMask k];
    if size(values{k}, 2)~=1
        % invFilter = [invFilter k];
        if length(mask{k})==1 && mask{k} >0
            if isnumeric(values{k}{1})
                m{k} = sprintf('%s: %g, ', names{k}, values{k}{mask{k}});
            else
                m{k} = sprintf('%s: %s, ', names{k}, values{k}{mask{k}});
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

for k=1:size(v, 2)
    for l=1:size(v, 1)
        if isnumeric( v{end-l+1, end-k+1})
            t{l} = strrep(sprintf('%s: %g', names{l}, v{end-l+1, k}), '.', '-');
            st{l} = strrep(sprintf('%s%g', shortNames{l}, v{end-l+1, k}), '.', '-');
        else
            t{l} = sprintf('%s: %s', names{l}, v{end-l+1, k});
            sn = sv{end-l+1, k};
            sn = [upper(sn(1)) sn(2:end)];
            st{l} = sprintf('%s%s', shortNames{l},  sn);
        end
    end
    vn{k} = sprintf('%s, ', t{parameterOrder(invFilter)});
    svn{k} = sprintf('%s_', st{parameterOrder(invFilter)});
    vnm{k} = sprintf('%s, ', t{invFilterMask}); % FIXME make it inmode
    svnm{k} = sprintf('%s_', st{invFilterMask});
    
    modes(k) = cell2struct(v(end:-1:1, k), names);
    cmTmp = v(end:-1:1, k);
    cmm{k} = cmTmp;
    cm{k} = cmTmp(invFilterMask);
    
end

for k=1:size(v, 2)
    modes(k).id = k;
    modes(k).infoString = vn{k}(1:end-2) ;
    modes(k).infoShortString = svn{k}(1:end-1);
    modes(k).infoStringMasked = vnm{k}(1:end-2);
    modes(k).infoShortStringMasked = svnm{k}(1:end-1);
    modes(k).infoStringMask = maskInfo(1:end-2);
    modes(k).infoCellMasked = cm{k}';
    modes(k).infoCell = cmm{k}';
    modes(k).infoModeNames = names(invFilterMask);
    modes(k).infoModeShortNames = shortNames(invFilterMask);
    modes(k).infoId = n(end:-1:1, k)';
end

parametersMasked.name = names(invFilterMask);
parametersMasked.set = values(invFilterMask);

parameters.name = names;
parameters.set = values;

fMask = mask(invFilterMask);
for k=1:length(fMask)
    if fMask{k} ~= 0
        parametersMasked.set{k} = parametersMasked.set{k}(fMask{k});
    end
end

parameters.list = enumsFromInfo([modes(:).infoCell], parameters);

parametersMasked.list = enumsFromInfo([modes(:).infoCellMasked], parametersMasked);



% end
% if size(enums, 1) == 1
%     parametersMasked.list = enums';
% else
%     parametersMasked.list = enums;
% end

if length(modes) >1
    sequence = sequencingModes(config, modes, parametersMasked);
else
    sequence = {1};
end


for k=1:length(modes)
    vv{k} = modes(k);
end
modes=vv;

end

function enums = enumsFromInfo(enums, parameters)

if size(enums, 2) > length(parameters.name)
    enums = reshape(enums, length(parameters.name), size(enums, 2)/length(parameters.name))';
end
for k=1:size(enums, 2)
    if isnumeric(enums{1, k})
        values = [enums{:, k}];
        m=0;
        while m<10 && mean(values*10^m-floor((values+eps)*10^m)) > 10^-10
            m = m+1;
        end
        enums(:, k) =  cellstr(num2str(values', ['%.' num2str(m) 'f\n']));
    end
end
end



function [v sv, n] = buildModesCell(modes, shortModes, mask)


if length(modes)>1
    [pvs spvs pns] = buildModesCell(modes(2:end), shortModes(2:end), mask(2:end));
    v=[];
    sv=[];
    n=[];
    if mask{1}>0
        it = mask{1};
    else
        it = 1:length(modes{1});
    end
    for k=it
        pv=pvs;
        spv=spvs;
        pn=pns;
        for l=1:size(pv, 2)
            pv{size(pvs, 1)+1, l} = modes{1}{k};
            spv{size(spvs, 1)+1, l} = shortModes{1}{k};
            pn(size(pns, 1)+1, l) = k;
        end
        v = [v pv];
        sv = [sv spv];
        n = [n pn];
    end
else
    if mask{1}>0
        v= modes{1}(mask{1});
        sv= shortModes{1}(mask{1});
        n= mask{1};
    else
        v= modes{1};
        sv= shortModes{1};
        n= 1:length(modes{1});
    end
end
end

