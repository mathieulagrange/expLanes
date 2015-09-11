function expConfigMerge(configFileName, defaultConfigFileName, layout, prompt)

if ~exist('layout', 'var'), layout = 1; end
if ~exist('prompt', 'var'), prompt = 1; end

if ~exist(configFileName, 'file'), error(['Unable to open ' configFileName]); end
configFile=fopen(configFileName);
configCell=textscan(configFile,'%s%s ', 'commentStyle', '%', 'delimiter', '=');
fclose(configFile);
names = strtrim(configCell{1});
values = strtrim(configCell{2});
while length(values)<length(names), values{end+1} = ''; end

if ~exist(defaultConfigFileName, 'file'), error(['Unable to open ' defaultConfigFileName]); end
defaultConfigFile=fopen(defaultConfigFileName);
configCell=textscan(defaultConfigFile,'%s%s ', 'commentStyle', '%', 'delimiter', '=');
fclose(defaultConfigFile);
defaultNames = strtrim(configCell{1});
defaultValues = strtrim(configCell{2});
while length(defaultValues)<length(defaultNames), defaultValues{end+1} = ''; end

if layout==1
    
    [newNames, newIndex] = setdiff(defaultNames, names);
    
    fid = fopen(configFileName, 'a');
    fprintf(fid, '\n\n');
    for k=1:length(newNames)
        fprintf(fid, '%s = %s\n', newNames{k}, defaultValues{newIndex(k)});
    end
    fclose(fid);
else
    fid = fopen(defaultConfigFileName, 'rt');
    text={};
    while ~feof(fid)
        line = fgetl(fid);
%         if line ~= -1
        text{end+1} = strtrim(line);
%         end
    end
    fclose(fid);
    
    fid = fopen(configFileName, 'w');
    % update existing parameters
    for k=1:length(text)
        if ~isempty(text{k}) && ~strcmp(text{k}(1), '%') && strfind(text{k}, '=')
            a=regexp(text{k}, '=', 'split');
            iNames = find(strcmp(names, strtrim(a{1})));
            if ~isempty(iNames)
                fprintf(fid, '%s = %s\n', a{1}, values{iNames});
            else
                fprintf(fid, '%s\n', text{k});
            end
        else
            fprintf(fid, '%s\n', text{k});
        end
    end
    % copy
    [newNames, newIndex] = setdiff(names, defaultNames);
    for k=1:length(newNames)
        if ~prompt || inputQuestion([ newNames{k} ' is not in the default Config File of expLanes. Keep it ?'])
            fprintf(fid, '%s = %s\n', newNames{k}, values{newIndex(k)});
        end
    end
end
