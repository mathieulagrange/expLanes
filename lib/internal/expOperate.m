function config=expOperate(config)

if nargin<1, config=expConfig(); end

% check data directory
% if ~exist(config.inputPath, 'dir')
%     disp(['Warning. Unreachable input path: ', config.inputPath]);
% end

%create needed directories
for k=1:length(config.stepName)
    stepPath = [config.dataPath config.stepName{k} filesep];
    if ~exist(stepPath, 'dir')
        mkdir(stepPath);
    end
    stepPath = [config.obsPath config.stepName{k} filesep];
    if ~exist(stepPath, 'dir')
        mkdir(stepPath);
    end
end



config.step.setting = [];

tic
if config.attachedMode
    [config, config.initStore] = feval([config.shortExperimentName 'Init'], config);
else
    try
        [config, config.initStore] = feval([config.shortExperimentName 'Init'], config);
    catch error
        config = expLog(config, error, 3, 1);
    end
end

if all(config.do>0) && ~isempty(config.factors)
    if sum(abs(config.parallel))
        distcomp.feature('LocalUseMpiexec',false); % handling MPI bug in 2012b
        pool = gcp('nocreate');
        if ~isempty(pool)
            nbWorkers = pool.NumWorkers;
        else
            nbWorkers = 0 ;
        end
        %         nbWorkers = parpool('size');
        
        if nbWorkers && ...
                ((max(config.parallel)>1 && nbWorkers ~= max(config.parallel)) || ...
                (max(config.parallel)==1 && nbWorkers ~= feature('numCores')))
            poolobj = gcp('nocreate');
            delete(poolobj);
        end
        if nbWorkers == 0
            if any(abs(config.parallel)>1)
                parpool('local', max(abs(config.parallel)));
            elseif nbWorkers == 0
                parpool('local');
            end
        end
        
        for k=1:length(config.do)
            config.step = config.stepSettings{config.do(k)};
            % remove reduceData
            %             reduceDataFileName = [config.obsPath config.stepName{config.step.id} filesep 'reduceData.mat'];
            %             if exist(reduceDataFileName, 'file')
            %                 delete(reduceDataFileName);
            %             end
            
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
            config.parallel = nbWorkers;
            % parpool('close');
        end
        delete([config.tmpPath config.experimentName '_' num2str(config.runId) '_*_done']);
    else
        for k=1:length(config.do)
            config.step = config.stepSettings{config.do(k)}; % remove reduceData
            %             reduceDataFileName = [config.obsPath config.stepName{config.step.id} filesep 'reduceData.mat'];
            %             if exist(reduceDataFileName, 'file')
            %                 delete(reduceDataFileName);
            %             end
            for l=1:length(config.step.sequence)
                config = expProcessOne(config, l);
            end
        end
    end
end

config.runDuration=toc/60;

function [config, settingStatus] = expProcessOne(config, sequence)



config.step.idName = config.stepName{config.step.id};

config.sequentialData = [];

for k=1:length(config.step.sequence{sequence})
    config.step.setting = expSetting(config.step, config.step.sequence{sequence}(k));
    success=1;
    if config.attachedMode && ~config.parallel(config.step.id)
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

if  config.parallel(config.step.id) > 0
    doneFileName = [config.tmpPath config.experimentName '_' num2str(config.runId) '_' num2str(config.step.id) '_' num2str(sequence) '_done'];
    fid = fopen(doneFileName,'w');
    if fid == -1, fprintf(2, ['Unable to create ' doneFileName '\n']);
    else
        fclose(fid);
    end
end

function config = expProcessOneSub(config)

functionName = [config.shortExperimentName num2str(config.step.id) config.stepName{config.step.id}];

% if ~config.resume || ~exist(expSave(config, [], 'data'), 'file') || ~exist(expSave(config, [], 'obs'), 'file')
if config.resume
    dataId = 0;
    dataUser = config.userName;
    dataOutputFile = expSave(config, [], 'data');
    if exist(dataOutputFile, 'file')
        data = expLoad(config, dataOutputFile);
        dataId = data.info.runId;
        dataUser = data.info.userName;
    end
    obsId=0;
    obsUser = config.userName;
    obsOutputFile = expSave(config, [], 'obs');
    if exist(obsOutputFile, 'file')
        data = expLoad(config, obsOutputFile);
        obsId = data.info.runId;
        obsUser = data.info.userName;
    end
    
    if strcmp(dataUser, config.userName) && strcmp(obsUser, config.userName) && dataId>=config.resume && obsId>=config.resume
        return;
    end
end

loadedData = [];
if config.store > -1
    if config.step.id>1
        data = expLoad(config, [], [], 'data');
        if ~isempty(data)
            loadedData = data;
        end
        obs = expLoad(config, [], [], 'obs');
        if ~isempty(obs)
            for k=1:length(loadedData)
            loadedData(k).obs = obs(k);
            end
        end
    else
        loadedData = config.initStore;
    end
end

if config.store < 1
    data = expLoad(config, [], config.step.id, 'data');
    if ~isempty(data)
        loadedData.store = data;
    end
end

ticId = tic;

[config, storeData, storeObs] = feval(functionName, config, config.step.setting, loadedData);

config = expProgress(config);

if config.recordTiming && ~isfield(storeObs, 'time')
    storeObs.time = toc(ticId);
end

if ~isempty(storeData)
    expSave(config, storeData, 'data');
end
if ~isempty(storeObs)
    expSave(config, storeObs, 'obs');
end

