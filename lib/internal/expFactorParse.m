function [settingSpec] = expFactorParse(config, fileName)

settingSpec = [];
if ~exist(fileName, 'file'), error(['Unable to open ' fileName]); end
fid =fopen(fileName);
C = textscan(fid,'%s%s%s%s', 'commentstyle', '%', 'delimiter', '=');
fclose(fid);
names=C{1};
step=C{2};
select=C{3};
values=C{4};

if isempty(C{1})
    if isempty(config.addFactor)
        fprintf(2, 'Factor file empty, please add factor using the ''addFactor'' command.\n');
    end
    return;
end

if length(unique(names)) < length(names)
    fprintf(2, 'Factors definition, duplicate factor name in setting file.\n');
    return;
end

selectAll = {};
deselectAll = {};
for k=1:length(names)
    if isempty(values{k})
        fprintf(2, ['Factors definition, missing definition of modalities for factor: ' names{k} '\n']);
        return;
    end
    
    names{k}=strtrim(names{k});
    selectSplit = regexp(strtrim(select{k}), ',', 'split');
    if ~isempty(selectSplit{1})
        for l=1:length(selectSplit)
            c = regexp(selectSplit{l}, '/', 'split');
            p = eval(c{1});
            s = eval(c{2});
            if p<0
                deselectAll{end+1} = [num2str(k) '/' selectSplit{l} ];
            else
                selectAll{end+1} = [num2str(k) '/' selectSplit{l} ];
            end
        end
    end
end
for k=1:length(names)
    try
        values{k}=eval(values{k});
    catch
        fprintf(2, ['Factors definition, unable to parse the set of modalities of the factor: ' names{k}, '\n']);
        return;
    end
    if iscellstr(values{k})
        shortValues{k} = names2shortNames(values{k});
        if ~all(cellfun(@isempty, strfind(values{k}, '/'))) || ~all(cellfun(@isempty, strfind(values{k}, '\'))) || ~all(cellfun(@isempty, strfind(values{k}, '.')))
            fprintf(2,['Factors definition, Invalid set of settings for ' names{k} ' factor in ' fileName '. the settings shall not include any path-like characters like: ''/'', ''\'', or ''.''.\n']); return;
        end
        if length(unique(values{k})) < length(values{k})
            fprintf(2,['Factors definition, Duplicate values of factor ' names{k} ' in setting file.\n']); return;
        end
    elseif isnumeric(values{k})
        shortValues{k} = values{k};
    else
        fprintf(2,['Factors definition, i nvalid set of settings for ' names{k} ' factor in ' fileName '. Shall be numeric or cell array of strings.\n']); return;
    end
end

% identifying sequential factor
sequentialFactor = [];
seq=0;
for k=1:length(step)
    step{k} = strtrim(step{k});
    if length(step{k}) ~= length(regexp(step{k}, '[0-9:s,]', 'match'))
        fprintf(2,['Factors definition, unrecognized step definition for factor ', names{k}, '\n']);  return;
    end
    sMatch = strfind(step{k}, 's');
    if any(sMatch)
        sequentialFactor = names{k};
        seq=seq+1;
        step{k}(sMatch) = [];
    end
end

if seq>1, fprintf(2,'Factors definition, only one sequential factor is allowed\n');  return; end

values=values';
shortNames=names2shortNames(names);

for k=1:size(values, 2)
    if isnumeric(values{k})
        m=0;
        while m<10 && mean(values{k}*10^m-floor((values{k}+eps)*10^m)) > 10^-10
            m = m+1;
        end
        stringValues{k} = cellstr(num2str(values{k}', ['%.' num2str(m) 'f\n']));
        
        values{k} = num2cell(values{k});
        shortValues{k} = num2cell(shortValues{k});
    elseif iscellstr(values{k})
        % check if cell array of strings
        stringValues(k) = values(k);
    end
end

settingSpec.values = values;
settingSpec.stringValues = stringValues;
settingSpec.names = names;
settingSpec.shortNames = shortNames;
settingSpec.shortValues = shortValues;
settingSpec.step = step;
settingSpec.selectFactors = selectAll;
settingSpec.deselectFactors = deselectAll;
settingSpec.sequentialFactor = sequentialFactor;
