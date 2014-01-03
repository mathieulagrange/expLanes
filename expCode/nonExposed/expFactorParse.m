function [modeSpec] = expModeParse(fileName)

fid =fopen(fileName);
C = textscan(fid,'%s%s%s%s', 'commentstyle', '%', 'delimiter', '=');
fclose(fid);
names=C{1};
step=C{2};
select=C{3};
values=C{4};

if length(unique(names)) < length(names)
    error('Duplicate parameter name in mode file');
end

selectAll = {};
for k=1:length(names)
    names{k}=strtrim(names{k});
    selectSplit = regexp(strtrim(select{k}), ',', 'split');
    if ~isempty(selectSplit{1})
        for l=1:length(selectSplit)
            selectAll{end+1} = [num2str(k) '/' selectSplit{l}];
        end
    end
    values{k}=eval(values{k});
    if iscellstr(values{k})
        shortValues{k} = names2shortNames(values{k});
       if ~all(cellfun(@isempty, strfind(values{k}, '/'))) || ~all(cellfun(@isempty, strfind(values{k}, '\'))) || ~all(cellfun(@isempty, strfind(values{k}, '.')))
          error(['Invalid set of modes for ' names{k} ' parameter in ' fileName '. the modes shall not include any path-like characters like: ''/'', ''\'', or ''.''.']); 
       end
        if length(unique(values{k})) < length(values{k})
            error(['Duplicate values of parameter ' names{k} ' in mode file']);
        end
    elseif isnumeric(values{k})
        shortValues{k} = values{k};
    else
        error(['Invalid set of modes for ' names{k} ' parameter in ' fileName '. Shall be numeric or cell array of strings.']);
    end
end

sequentialParameter = [];

seq=0;
for k=1:length(step)
    step{k} = strtrim(step{k});
    if length(step{k}) ~= length(regexp(step{k}, '[0-9:s,]', 'match'))
        error(['Unrecognized step definition for parameter ', names{k}]);
    end
    sMatch = strfind(step{k}, 's');
    if any(sMatch)
        sequentialParameter = names{k};
        seq=seq+1;
        step{k}(sMatch==1) = [];
    end
end

if seq>1, error('Only one sequential parameter is allowed'); end


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
        %         values{k} = values(k);
        %         shortValues{k} = shortValues(k);
    end
end

modeSpec.values = values;
modeSpec.stringValues = stringValues;
modeSpec.names = names;
modeSpec.shortNames = shortNames;
modeSpec.shortValues = shortValues;
modeSpec.step = step;
modeSpec.selectParameters = selectAll;
modeSpec.sequentialParameter = sequentialParameter;
