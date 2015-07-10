function config = expUpdateConfig(configFileName)

config = expConfigParse(configFileName);

if isempty(config), return; end;

expLordPath = [fileparts(mfilename('fullpath')) filesep '..'];  
defaultConfig = expConfigParse([expLordPath filesep 'expLordConfig.txt']);

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
    if inputQuestion(['Do you want to update ' configFileName ' with the expLord layout ?'])
        layout = 2;
    elseif inputQuestion(['Do you want to update ' configFileName ' with your original layout ?'])
        layout = 1;
    end
    if layout
        expConfigMerge(configFileName, [expLordPath filesep 'expLordConfig.txt'], layout);
    end
end