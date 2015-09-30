function config = expUpdateConfig(configFileName)

config = expConfigParse(configFileName);

if isempty(config), return; end;

expLanesPath = [fileparts(mfilename('fullpath')) filesep '..'];  
defaultConfig = expConfigParse([expLanesPath filesep 'expLanesConfig.txt']);

namesDefault = fieldnames(defaultConfig);
namesConfig = fieldnames(config);

newNames = setdiff(namesDefault, namesConfig);

if ~isempty(newNames)
    disp(['Updating ' configFileName]);
    for k=1:length(newNames)
        disp(['Missing config field ' newNames{k} ' in your config file.']);
        config.(newNames{k}) = defaultConfig.(newNames{k});
    end
    disp('');
    layout = 0;
    if inputQuestion(['Do you want to update ' configFileName ' with the expLanes layout ?'])
        layout = 2;
    elseif inputQuestion(['Do you want to update ' configFileName ' with your original layout ?'])
        layout = 1;
    end
    if layout
        expConfigMerge(configFileName, [expLanesPath filesep 'expLanesConfig.txt'], layout);
    end
end