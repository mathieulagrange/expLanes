function config=expReduce(config)

% TODO reduceData per expose Call

data = {};
reduceFileName = [config.dataPath config.stepName{config.currentStep} filesep 'reduceData.mat'];

if exist(reduceFileName, 'file')
    % get vSet
    loadedData=load(reduceFileName, 'vSet');
    if isequal(loadedData.vSet, config.variantSet)
        loadedData=load(reduceFileName, 'data');
        data = loadedData.data;
    end
end

if isempty(data)%
    config.currentStep = config.currentStep+1;
    
    config.loadFileInfo.date = {'', ''};
    config.loadFileInfo.dateNum = [Inf, 0];
    
    for k=1:length(config.variants)
        config.currentVariant = config.variants(k);
        
        config = expLoad(config, [], [], 'display');
        if ~isempty(config.load)
            data{k} = config.load;
        end
    end
    
    if config.loadFileInfo.dateNum(2)
        disp(['Loaded data files dates are in the range: | ' config.loadFileInfo.date{1} ' || ' config.loadFileInfo.date{2} ' |']);
        vSet = config.variantSet; %#ok<NASGU>
        save(reduceFileName, 'data', 'vSet', 'config');
        if ~strcmp(config.message, 'default')
            copyfile(reduceFileName, [config.reportPath config.projectName '_' config.message '.mat']);
        end
    end
    config.currentStep = config.currentStep-1;
end

% list all metrics
metrics = {};
structMetrics = {};
maxLength = 0;
for k=1:length(data)
    if ~isempty(data{k})
        names = fieldnames(data{k});
        for m=1:length(names)
            if ~isstruct(data{k}.(names{m}))
                metrics = [metrics names{m}];
            else
                 structMetrics = [structMetrics names{m}];
               
            end
        end
        for m=1:length(names)
            maxLength = max(maxLength, length(data{k}.(names{m})));
        end
    end
end
metrics = unique(metrics);
structMetrics = unique(structMetrics);

% build results matrix
% TODO remove usage of NaN by using cell arrays
results = zeros(length(data), length(metrics), maxLength)*NaN;
for k=1:length(metrics)
    for m=1:length(data)
        if isfield(data{m}, metrics{k})
            results(m, k, :) = data{m}.(metrics{k});
        end
    end
end

if isempty(structMetrics)
    structResults = [];
else
    for k=1:length(structMetrics)
        n=1;
        for m=1:length(data)
            if isfield(data{m}, structMetrics{k})
                structResults.(structMetrics{k})(n) = data{m}.(structMetrics{k});
                %             structResults.(structMetrics{k})(n).variant = config.variants(m);
                n=n+1;
            end
        end
    end
end

% store
config.evaluation.metrics = metrics;
config.evaluation.results = results;
config.evaluation.structMetrics = structMetrics;
config.evaluation.structResults = structResults;
config.evaluation.data = data;
