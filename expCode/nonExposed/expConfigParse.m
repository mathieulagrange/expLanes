function config = expConfigParse(configFileName)

configFile=fopen(configFileName);
if configFile==-1,
    error('Unable to load the expCode config file for your project.');
end

configCell=textscan(configFile,'%s%s ', 'commentStyle', '%', 'delimiter', '=');
fclose(configFile);
names = strtrim(configCell{1});
values = strtrim(configCell{2});

for k=1:length(names)
    if k <= length(values)
    if ~isempty(values{k})
        if  ~isnan(str2double(values{k}))
            values{k} = str2double(values{k});
        elseif values{k}(1) == '{' || values{k}(1) == '['
            values{k} =  eval(values{k});
        end
    end
    else
       values{k} = ''; 
    end
end

config = cell2struct(values, names);

