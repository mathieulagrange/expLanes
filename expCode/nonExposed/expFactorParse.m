function [settingSpec] = expFactorParse(fileName, nbSteps)

if ~exist('nbSteps', 'var'), nbSteps=0; end

fid =fopen(fileName);
C = textscan(fid,'%s%s%s%s', 'commentstyle', '%', 'delimiter', '=');
fclose(fid);
names=C{1};
step=C{2};
select=C{3};
values=C{4};

if length(unique(names)) < length(names)
    error('Duplicate factor name in setting file');
end

selectAll = {};
deselectAll = {};
for k=1:length(names)
    names{k}=strtrim(names{k});
    selectSplit = regexp(strtrim(select{k}), ',', 'split');
    if ~isempty(selectSplit{1})
        for l=1:length(selectSplit)
            c = regexp(selectSplit{l}, '/', 'split');
            p = eval(c{1});
            s = eval(c{2});
             if p<0
                  deselectAll{end+1} = [num2str(k) '/' selectSplit{l} ];
%                 sLength = length(eval(values{-p}));
%                 if s>1 && s<sLength
%                     if s>2
%                         sel1 = ['1:' num2str(s-1)];
%                     else
%                         sel1 = '1';
%                     end
%                     if s<sLength-1
%                         sel2 = [num2str(s+1) ':' num2str(sLength)];
%                     else
%                         sel2 = sLength;
%                     end
%                 else
%                     if s==1
%                         sel1 = ['2:' num2str(sLength)];
%                     else
%                         sel1 = ['1:' num2str(sLength-1)];
%                     end
%                     sel2 = [];
%                 end
%                 for m=1:length(names)
%                     selectSplitm = regexp(strtrim(select{m}), ',', 'split');
%                      doit = 1;
%                        if ~isempty(selectSplitm{1})
%                         for n=1:length(selectSplitm)
%                             cn = regexp(selectSplitm{n}, '/', 'split');
%                             pn = eval(cn{1});
%                             sn = eval(cn{2});
%                             if pn == p, doit=0; end
%                         end
%                        end
%                         if m~=k && m ~=-p && doit
%                             selectAll{end+1} = [num2str(m) '/' num2str(-p) '/' sel1]; % FIXME more difficult than this
%                         if ~isempty(sel2)
%                             selectAll{end+1} = [num2str(m) '/' num2str(-p) '/' sel2]; % FIXME more difficult than this
%                         end
%                         end
%                 end
             else
                selectAll{end+1} = [num2str(k) '/' selectSplit{l} ];
             end
        end
    end
end
for k=1:length(names)

    values{k}=eval(values{k});
    if iscellstr(values{k})
        shortValues{k} = names2shortNames(values{k});
       if ~all(cellfun(@isempty, strfind(values{k}, '/'))) || ~all(cellfun(@isempty, strfind(values{k}, '\'))) || ~all(cellfun(@isempty, strfind(values{k}, '.')))
          error(['Invalid set of settings for ' names{k} ' factor in ' fileName '. the settings shall not include any path-like characters like: ''/'', ''\'', or ''.''.']); 
       end
        if length(unique(values{k})) < length(values{k})
            error(['Duplicate values of factor ' names{k} ' in setting file']);
        end
    elseif isnumeric(values{k})
        shortValues{k} = values{k};
    else
        error(['Invalid set of settings for ' names{k} ' factor in ' fileName '. Shall be numeric or cell array of strings.']);
    end
end

% identifying sequential factor
sequentialFactor = [];
seq=0;
for k=1:length(step)
    step{k} = strtrim(step{k});
    if length(step{k}) ~= length(regexp(step{k}, '[0-9:s,]', 'match'))
        error(['Unrecognized step definition for factor ', names{k}]);
    end
    sMatch = strfind(step{k}, 's');
    if any(sMatch)
        sequentialFactor = names{k};
        seq=seq+1;
        step{k}(sMatch) = [];
    end
end

if seq>1, error('Only one sequential factor is allowed'); end


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
