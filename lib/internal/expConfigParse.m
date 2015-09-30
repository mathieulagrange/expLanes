function config = expConfigParse(configFileName)

config=[];
configFile=fopen(configFileName);
if configFile==-1,
    fprintf(2,['Unable to load the expLanes config file for your experiment named: ' configFileName '\n']); return;
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
            else
                if values{k}(1) == '{' || values{k}(1) == '[' || values{k}(end) == '}' || values{k}(end) == ']'
                    try
                        values{k} =  eval(values{k});
                    catch
                        fprintf(2,['Unable to parse definition of  ' names{k} ' in file ' configFileName '.\n']); return;
                    end
                    %                 else
                    %                     fprintf(2,['Unable to parse definition of  ' names{k} ' in file ' configFileName '.\n']); return;
                end
            end
        end
    else
        values{k} = '';
    end
end

try
config = cell2struct(values, names);
catch error
       fprintf(2,[error.message ' in file ' configFileName '\n']); return;
end
