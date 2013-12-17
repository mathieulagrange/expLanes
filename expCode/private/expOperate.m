function config=expOperate(config)

if nargin<1, config=expConfig(); end

% check data directory
if ~exist(config.inputPath, 'dir')
    warning('Unreachable input path %s ', config.inputPath);
end

%create needed directories
for k=1:length(config.taskName)
    taskPath = [config.dataPath config.taskName{k} filesep];
    if ~exist(taskPath, 'dir')
        mkdir(taskPath);
    end
end
if ~exist(config.reportPath, 'dir')
    mkdir(config.reportPath);
    mkdir([config.reportPath 'figures']);
    mkdir([config.reportPath 'tables']);
    mkdir([config.reportPath 'tex/']);
    %     copyfile([fileparts(mfilename('fullpath')) filesep 'utils/mcode.sty'], [config.reportPath 'tex/']);
end

% expDependencies(config);

config.logFileName = [config.reportPath 'log_' num2str(config.runId) '.txt'];
config.errorDataFileName = {};
if exist(config.logFileName, 'file')
    delete(config.logFileName);
end

config.logFile = fopen([config.reportPath 'config.txt'], 'w');
fprintf(config.logFile, '\n%s\n', evalc('disp(config)'));
fclose(config.logFile);

config.currentVariant = [];

task = config.do;

tic
try
    [config config.initStore] = feval([config.shortProjectName 'Init'], config);
catch error
    if config.host == 0
        rethrow(error);
    else
        config = expLog(config, error, 3, 1);
    end
end

if all(task>0)
    if sum(abs(config.parallel))
        if any(config.parallel>1)
            matlabpool('open', 'local', max(config.parallel));
        elseif matlabpool('size') == 0
            matlabpool('open', 'local');
        end
        
        for k=1:length(task)
            config = expSetTask(config, task(k));
            % remove reduceData
            reduceDataFileName = [config.dataPath config.taskName{config.currentTask} filesep 'reduceData.mat'];
            if exist(reduceDataFileName, 'file')
                delete(reduceDataFileName);
            end
            
            if config.parallel(task(k))>0 % ~= 1 % length(config.taskName)
                parfor l=1:length(config.variantSequence)
                    expProcessOne(config, config.variants(config.variantSequence{l}), task(k));
                end
            else
                for l=1:length(config.variantSequence)
                    config = expProcessOne(config, config.variants(config.variantSequence{l}), task(k));
                end
                
            end
        end
        if sum(abs(config.parallel))
            config.parallel = matlabpool('size');
           % matlabpool('close');
        end
    else
        for k=1:length(task)
            config = expSetTask(config, task(k));
            % remove reduceData
            reduceDataFileName = [config.dataPath config.taskName{config.currentTask} filesep 'reduceData.mat'];
            if exist(reduceDataFileName, 'file')
                delete(reduceDataFileName);
            end
            for l=1:length(config.variantSequence)
                config = expProcessOne(config, config.variants(config.variantSequence{l}), task(k));
            end
        end
    end
end

config.runDuration=ceil(toc/60);

function config = expProcessOne(config, variant, task)

config.currentTaskName = config.taskName{config.currentTask};

config.sequentialData = [];

for k=1:length(variant)
    config.currentVariant = variant(k);
    try
        config = expProcessOneSub(config, config.currentVariant, task);
    catch error
        if config.host == 0
            rethrow(error);
        else
            config = expLog(config, error, 2, 1);
        end
    end
end

function config = expProcessOneSub(config, variant, task)

functionName = [config.shortProjectName num2str(task) config.taskName{task}];

if config.redo==0 && (exist(expSave(config, [], 'store'), 'file') || exist(expSave(config, [], 'display'), 'file'))
   disp(['skipping ' config.currentTaskName ' ' config.currentVariant.infoString]);
   return
end

loadedData = [];
if config.currentTask>1
    config = expLoad(config, [], [], 'store');
    if ~isempty(config.load)
        loadedData = config.load;
    end
    %     config = expLoad(config, [], [], 'display');
    %     if ~isempty(config.load)
    %         loadedDisplay = config.load;
    %     end
else
    loadedData = config.initStore;
end

[config storeData storeDisplay] = feval(functionName, config, variant, loadedData);

if ~isempty(storeData)
    expSave(config, storeData, 'store');
end
if ~isempty(storeDisplay)
    expSave(config, storeDisplay, 'display');
end




