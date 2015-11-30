function config = expExportConfig(configFileName)

configFile=fopen(configFileName);
if configFile==-1, 
    error('Unable to load the expLanes config file for your experiment.');
end

configCell=textscan(configFile,'%s%s ', 'commentStyle', '%', 'delimiter', '=');
fclose(configFile);
names = strtrim(configCell{1});
values = strtrim(configCell{2});

config = cell2struct(values, names);

names=fieldnames(config);
for k=1:length(names)
    if ~isempty(strfind(names{k}, 'Path')) && isempty(strfind(names{k}, 'matlab'))
        config.(names{k}) = names{k}(1:end-4);
    end
end
config.codePath = '.';
config.dataPath = './data';
config.obsPath = './data';
config.inputPath = './input';
config.localDependencies = 1;
