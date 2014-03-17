function config = expUpdateConfig(configFileName)

config = expConfigParse(configFileName);

expCodePath = [fileparts(mfilename('fullpath')) filesep '..'];  
defaultConfig = expConfigParse([expCodePath filesep 'expCodeConfig.txt']);

namesDefault = fieldnames(defaultConfig);
namesConfig = fieldnames(config);

newNames = setdiff(namesDefault, namesConfig);

if ~isempty(newNames)
    for k=1:length(newNames)
        disp(['Missing config field ' newNames{k} ' in your config file.']);
        config.(newNames{k}) = defaultConfig.(newNames{k});
    end
    disp('');
    layout = 0;
    if inputQuestion('Do you want to update your config with your original layout ?')
        layout = 1;
    elseif inputQuestion('Do you want to update your config with your expCode layout ?')
        layout = 2;
    end
    if layout
        expConfigMerge(configFileName, [expCodePath filesep 'expCodeConfig.txt'], layout);
    end
end