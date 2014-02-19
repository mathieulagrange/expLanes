function config=expOperate(config)

if nargin<1, config=expConfig(); end

% check data directory
if ~exist(config.inputPath, 'dir')
    warning('Unreachable input path %s ', config.inputPath);
end

%create needed directories
for k=1:length(config.stepName)
    stepPath = [config.dataPath config.stepName{k} filesep];
    if ~exist(stepPath, 'dir')
        mkdir(stepPath);
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



config.currentMode = [];

step = config.step;

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

if all(step>0)
    if sum(abs(config.parallel))
        if any(config.parallel>1)
            matlabpool('open', 'local', max(config.parallel));
        elseif matlabpool('size') == 0
            matlabpool('open', 'local');
        end
        
        for k=1:length(step)
            config = expSetStep(config, step(k));
            % remove reduceData
            reduceDataFileName = [config.dataPath config.stepName{config.currentStep} filesep 'reduceData.mat'];
            if exist(reduceDataFileName, 'file')
                delete(reduceDataFileName);
            end
            
            if config.parallel(step(k))>0 % ~= 1 % length(config.stepName)
                modeStatus = config.modeStatus;
                parfor l=1:length(config.modeSequence)
                   [~, modeStatus(l)] =  expProcessOne(config, config.modes(config.modeSequence{l}), step(k));
                end
                for l=1:length(config.modeSequence)
                config.modeStatus.success = config.modeStatus.success+modeStatus(l).success;
                config.modeStatus.failed = config.modeStatus.failed+modeStatus(l).failed;
                end
            else
                for l=1:length(config.modeSequence)
                    config = expProcessOne(config, config.modes(config.modeSequence{l}), step(k));
                end
                
            end
        end
        if sum(abs(config.parallel))
            config.parallel = matlabpool('size');
           % matlabpool('close');
        end
    else
        for k=1:length(step)
            config = expSetStep(config, step(k));
            % remove reduceData
            reduceDataFileName = [config.dataPath config.stepName{config.currentStep} filesep 'reduceData.mat'];
            if exist(reduceDataFileName, 'file')
                delete(reduceDataFileName);
            end
            for l=1:length(config.modeSequence)
                config = expProcessOne(config, config.modes(config.modeSequence{l}), step(k));
            end
        end
    end
end

config.runDuration=ceil(toc/60);

function [config modeStatus] = expProcessOne(config, mode, step)

config.currentStepName = config.stepName{config.currentStep};

config.sequentialData = [];

for k=1:length(mode)
    config.currentMode = mode(k);
    success=1;
    try
        config = expProcessOneSub(config, config.currentMode, step);
    catch error
        if config.host == 0
            rethrow(error);
        else
            config.modeStatus.failed = config.modeStatus.failed+1;
            config = expLog(config, error, 2, 1);
            success = 0;
        end
    end
    if success
        config.modeStatus.success = config.modeStatus.success+1;
    end
end

modeStatus = config.modeStatus;

function config = expProcessOneSub(config, mode, step)

functionName = [config.shortProjectName num2str(step) config.stepName{step}];

if config.redo==0 && (exist(expSave(config, [], 'data'), 'file') || exist(expSave(config, [], 'display'), 'file'))
   disp(['skipping ' config.currentStepName ' ' config.currentMode.infoString]);
   return
end

loadedData = [];
if config.currentStep>1
    config = expLoad(config, [], [], 'data');
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

ticId = tic;

[config storeData storeObs] = feval(functionName, config, mode, loadedData);

if config.showTiming && ~isfield(storeObs, 'time')
    storeObs.time = toc(ticId);
end

config = expProgress(config);

if ~isempty(storeData)
    expSave(config, storeData, 'data');
end
if ~isempty(storeObs)
    expSave(config, storeObs, 'obs');
end




