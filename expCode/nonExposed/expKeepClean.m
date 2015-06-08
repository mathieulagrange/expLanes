function expKeepClean(config)

dataType = {'data', 'obs'};

tmpPath = [config.dataPath 'tmp_' num2str(datenum(date())) '/'];

for k=1:length(config.stepName)
    movefile([config.dataPath config.stepName{k}] , tmpPath);
    mkdir([config.dataPath config.stepName{k}] );
    settings = expStepSetting(config.factors, config.mask, k);
    config.step.id=k;
    for m=1:settings.nbSettings
        for n=1:length(dataType)
            config.step.setting = expSetting(settings, m);
            fileName = expSave(config, [], dataType{n});
            [~, n, e] = fileparts(fileName);
            tmpName = [tmpPath n e];
            if exist(tmpName, 'file')
                movefile(tmpName, fileName);
            end
        end
    end
    rmdir(tmpPath, 's');
end
