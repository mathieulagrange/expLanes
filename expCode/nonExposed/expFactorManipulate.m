function config = expFactorManipulate(config, name, modalities, steps, selector, defaultModality, rank)

if ~exist('defaultModality', 'var'), defaultModality=0; end
if ~exist('steps', 'var'), steps=''; end
if ~exist('selector', 'var'), selector=''; end
if ~exist('rank', 'var'), rank=0; end


if iscell(modalities)
    m = '{';
    for k=1:length(modalities)
        m = [m '''' modalities{k} ''', '];
    end
    modalities = [m(1:end-2) '}'];
end


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
        if ~isempty(name)
            newFactorLine = [name ' = ', steps, ' = ', selector, ' = ', modalities];
            fprintf(fid, '%s\n', newFactorLine);
        else
            continue
        end
    end
    if k<=length(lines)
        fprintf(fid, '%s\n', lines{k});
    end
end
fclose(fid);

factors = expFactorParse(config, config.factorFileName);

if defaultModality
    dataType = {'data', 'obs'};
    destMask(rank) = defaultModality;
    destMask = {num2cell(destMask)};
    oriMask = {{}};
    
    if isempty(name)
        tempMask = oriMask;
        oriMask = destMask;
        destMask = tempMask;
    end
    
    for k=1:length(config.stepName)
        settings = expStepSetting(config.factors, oriMask, k);
        newSettings = expStepSetting(factors, destMask, k);
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