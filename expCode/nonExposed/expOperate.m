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
if ~exist(config.reportPath, 'dir'), mkdir(config.reportPath); end
if ~exist([config.reportPath 'figures'], 'dir'), mkdir([config.reportPath 'figures']); end
if ~exist([config.reportPath 'tables'], 'dir'), mkdir([config.reportPath 'tables']); end
if ~exist([config.reportPath 'tex'], 'dir'), mkdir([config.reportPath 'tex']); end
if ~exist([config.reportPath 'data'], 'dir'), mkdir([config.reportPath 'data']); end
    %     copyfile([fileparts(mfilename('fullpath')) filesep 'utils/mcode.sty'], [config.reportPath 'tex/']);

% expDependencies(config);



config.step.setting = [];

% step = config.step;

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

if all(config.do>0)
    if sum(abs(config.parallel))
        if any(config.parallel>1)
            matlabpool('open', 'local', max(config.parallel));
        elseif matlabpool('size') == 0
            matlabpool('open', 'local');
        end
        
        for k=1:length(config.do)
            config.step = config.stepSettings{config.do(k)};
            % remove reduceData
            reduceDataFileName = [config.dataPath config.stepName{config.step.id} filesep 'reduceData.mat'];
            if exist(reduceDataFileName, 'file')
                delete(reduceDataFileName);
            end
            
            if config.parallel(config.do(k))>0 % ~= 1 % length(config.stepName)
                settingStatus = config.settingStatus;
                parfor l=1:length(config.step.sequence)
                   [~, settingStatus(l)] =  expProcessOne(config, l);
                end
                for l=1:length(config.step.sequence)
                config.settingStatus.success = config.settingStatus.success+settingStatus(l).success;
                config.settingStatus.failed = config.settingStatus.failed+settingStatus(l).failed;
                end
            else
                for l=1:length(config.step.sequence)
                    config = expProcessOne(config, l);
                end
                
            end
        end
        if sum(abs(config.parallel))
            config.parallel = matlabpool('size');
           % matlabpool('close');
        end
    else
        for k=1:length(config.do)
           config.step = config.stepSettings{config.do(k)}; % remove reduceData
            reduceDataFileName = [config.dataPath config.stepName{config.step.id} filesep 'reduceData.mat'];
            if exist(reduceDataFileName, 'file')
                delete(reduceDataFileName);
            end
            for l=1:length(config.step.sequence)
                config = expProcessOne(config, l);
            end
        end
    end
end

config.runDuration=ceil(toc/60);

function [config settingStatus] = expProcessOne(config, sequence)

config.step.idName = config.stepName{config.step.id};

config.sequentialData = [];

for k=1:length(config.step.sequence{sequence})
    config.step.setting = expSetting(config.step, config.step.sequence{sequence}(k));
    success=1;
    if config.host == 0
        config = expProcessOneSub(config);
    else
        try
            config = expProcessOneSub(config);
        catch error
            config.settingStatus.failed = config.settingStatus.failed+1;
            config = expLog(config, error, 2, 1);
            success = 0;
        end
    end
    if success
        config.settingStatus.success = config.settingStatus.success+1;
    end
end

settingStatus = config.settingStatus;

function config = expProcessOneSub(config)

functionName = [config.shortProjectName num2str(config.step.id) config.stepName{config.step.id}];

if config.redo==0 && (exist(expSave(config, [], 'data'), 'file') || exist(expSave(config, [], 'obs'), 'file'))
   disp(['skipping ' config.step.idName ' ' config.step.setting.infoString]);
   return
end

loadedData = [];
if config.step.id>1
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

config = expProgress(config);
[config storeData storeObs] = feval(functionName, config, config.step.setting, loadedData);

if config.showTiming && ~isfield(storeObs, 'time')
    storeObs.time = toc(ticId);
end



if ~isempty(storeData)
    expSave(config, storeData, 'data');
end
if ~isempty(storeObs)
    expSave(config, storeObs, 'obs');
end




