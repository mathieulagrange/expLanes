function config = addFactor(config, name, modalities, defaultModality, steps, selector, rank)

if ~exist('defaultModality', 'var'), defaultModality=0; end
if ~exist('steps', 'var'), steps=''; end
if ~exist('selector', 'var'), selector=''; end
if ~exist('rank', 'var'), rank=0; end


% read Factor file
fid=fopen(config.factorFileName);
C = textscan(fid, '%s', 'delimiter', '');
fclose(fid);
lines = C{1};
if ~rank, rank=length(lines)+1; end

% write new Factor file
fid=fopen(config.factorFileName, 'w');
for k=1:length(lines)+1
    if k==rank
        newFactorLine = [name ' = ', steps, ' = ', selector, ' = ', modalities];
        fprintf(fid, '%s\n', newFactorLine);
    end
    if k<=length(lines)
        fprintf(fid, '%s\n', lines{k});
    end
end
fclose(fid);

factors = expFactorParse(config.factorFileName);

if defaultModality
    dataType = {'data', 'obs'};
    for k=1:length(config.stepName)
        settings = expStepSetting(config.factors, {{}}, k);
        mask(rank) = defaultModality;
        newSettings = expStepSetting(factors, {num2cell(mask)}, k);
        config.step.id=k;
        for m=1:settings.nbSettings
            for n=1:length(dataType)
                config.step.setting = expSetting(settings, m);
                fileName = expSave(config, [], dataType{n});
                config.step.setting = expSetting(newSettings, m);
                newFileName = expSave(config, [], dataType{n});
                if exist(fileName, 'file')
                    movefile(fileName, newFileName);
                end
            end
        end
    end
end

config.factors = factors;