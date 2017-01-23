function config=expReduce(config)

data = {};

stepPath = [config.obsPath config.stepName{config.step.id} filesep];
files = dir([stepPath 'reduceData*']);

for k=1:length(files)
    reduceFileName = [stepPath files(k).name];
    if strfind(reduceFileName, num2str(datenum(date)))
        % get vSet
        modReduce = dir(reduceFileName);
        modFactors = dir(config.factorFileName);
        loadedData=load(reduceFileName, 'vSet', 'loadFileNames', 'loadedFileNames');
        
        
        dataTime = [];
        for k=1:length(loadedData.loadedFileNames)
            file=dir(loadedData.loadedFileNames{k});
            if ~isempty(file)
                dataTime(end+1) = file.datenum;
            end
        end
        newItems = 0;
        if length(loadedData.loadedFileNames) < length(loadedData.loadFileNames)
            found = 0;
            for k=1:length(loadedData.loadFileNames)
                file=dir(loadedData.loadFileNames{k});
                
                if ~isempty(file)
                    found = found+1;
                end
            end
            if found > length(loadedData.loadedFileNames)
                newItems = 1;
            end
        end
        
        if ~newItems && ~isempty(dataTime) && isequal(loadedData.vSet, config.step.set) && modReduce.datenum > modFactors.datenum && modReduce.datenum > max(dataTime)
            loadedData=load(reduceFileName, 'data');
            data = loadedData.data;
        end
    else
        delete(reduceFileName);
    end
end

if isempty(data)
    config.loadFileInfo.date = {'', ''};
    config.loadFileInfo.dateNum = [Inf, 0];
    loadedFileNames = {};
    loadFileNames = {};
    dataTimeStamps = [];
    for k=1:config.step.nbSettings
        config.step.setting = expSetting(config.step, k);
        
        [data{k}, dataTimeStamps, config, loadedFileName, loadFileName] = expLoad(config, [], config.step.id, 'obs', [], 0);
        loadedFileNames = [loadedFileNames loadedFileName];
        loadFileNames = [loadFileNames loadFileName];
        %         if ~isempty(config.load)
        %             data{k} = config.load;
        %         else
        %             data{k} = [];
        %         end
    end
    
    if ~isempty(dataTimeStamps) %, dataTimeStamps.dateNum(2)
        disp(['Loaded data files dates are in the range: | ' config.loadFileInfo.date{1} ' || ' config.loadFileInfo.date{2} ' |']);
        vSet = config.step.set; %#ok<NASGU>
        reduceFileName = [stepPath 'reduceData_' num2str(datenum(date)) '_' num2str(ceil(rand(1)*100))];
        save(reduceFileName, 'data', 'loadFileNames', 'loadedFileNames', 'vSet'); % , 'config' FIXME
    end
end

% list all observations
observations = {};
structObservations = {};
maxLength = 0;
for k=1:length(data)
    if ~isempty(data{k})
        names = fieldnames(data{k});
        for m=1:length(names)
            if isstruct(data{k}.(names{m})) % || iscell(data{k}.(names{m}))
                structObservations = [structObservations names{m}];
            elseif ~iscell(data{k}.(names{m}))
                observations = [observations names{m}];
            end
        end
        for m=1:length(names)
            maxLength = max(maxLength, length(data{k}.(names{m})));
        end
    end
end
observations = unique(observations);
structObservations = unique(structObservations);

if isempty(structObservations)
    structResults = [];
else
    for k=1:length(structObservations)
        n=1;
        for m=1:length(data)
            if isfield(data{m}, structObservations{k})
                structResults.(structObservations{k})(n) = data{m}.(structObservations{k});
                n=n+1;
            end
        end
    end
end

% store
config.evaluation.observations = observations;
config.evaluation.results = data;
config.evaluation.structObservations = structObservations;
config.evaluation.structResults = structResults;
config.evaluation.data = data;
