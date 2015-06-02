function config = expRun(projectPath, projectName, shortProjectName, commands)

beep off
config = expInit(projectPath, projectName, shortProjectName, commands);

if isempty(config), return; end;

expToolPath(config);
if config.probe
    expProbe(config);
end
if isempty(config.factors)
    config.mask = {{}};
elseif~expCheckMask(config.factors, config.mask)
    mask = cell(1, length(config.factors.names));
    [mask{:}] = deal(-1);
    config.mask = {mask};
end

if config.generateRootFile
    expCreateRootFile(config, projectName, shortProjectName, config.expCodePath);
end

% if ~exist([config.reportPath 'logs'], 'dir')
%     mkdir([config.reportPath 'logs']);
% end
config.logFileName = [config.tmpPath 'log_' config.projectName '_' num2str(config.runId) '.txt'];
config.errorDataFileName = {};
if exist(config.logFileName, 'file')
    delete(config.logFileName);
end
if ~exist(config.reportPath, 'dir')
    mkdir(config.reportPath);
end

% logFileName = [config.reportPath 'logs/config.txt'];
% config.logFile = fopen(logFileName, 'w');
% if config.logFile == -1, error(['Unable to write to ' logFileName]); end
% fprintf(config.logFile, '\n%s\n', evalc('disp(config)'));
% fclose(config.logFile);

if config.bundle ~= 0
    expSync(config, config.bundle, -1);
    return
end

if config.clean ~= 0
    if iscell(config.clean)
        config.clean = config.clean{1};
    end
    if ischar(config.clean)
        if length(config.clean) == 1
            switch config.clean
                case 't'
                    dirPath = [config.homePath '.expCode/tmp'];
                    info = 'expCode temporary data directory';
                case 'b'
                    dirPath = config.backupPath;
                    info = 'project backup directory';
            end
            if inputQuestion(['Cleaning ' info ': ' dirPath])
                if exist(dirPath, 'dir')
                    rmdir(dirPath, 's');
                    mkdir(dirPath);
                end
            end
            return
        else
            config.clean = {config.clean 1};
        end
    elseif isnumeric(config.clean)
        config.clean = {num2str(config.clean) 1};
    end
    expSync(config, config.clean{:}, 'C');
    return
end

if ~isempty(config.sync)
    if iscell(config.sync)
        expSync(config, config.sync{:});
    else
        expSync(config, config.sync);
    end
elseif config.localDependencies == 2
    expSync(config, 'd', 0, 0, 0, 1);
    p = fileparts(mfilename('fullpath'));
    addpath(genpath(p));
end

% expPath();

waitBars = findall(0, 'Type', 'figure', 'userdata', 'expProgress');
for k=1:length(waitBars)
    delete(waitBars(k));
end

if config.do == 0
    config.do = 1:length(config.stepName);
end
if config.display == 0
    if length(config.do)>1 || config.do>0
        config.display = config.do(end);
    else
        config.display = -1;
    end
end
rem=[];
config.runInfo=[];
if ~isempty(config.factors)
    if config.do>-1
    fprintf('Project %s: run %d on host %s \n', config.projectName, config.runId, config.hostName);
    for k=1:length(config.do)
        [config.stepSettings{config.do(k)}] = expStepSetting(config.factors, config.mask, config.do(k));
        if isfield(config.stepSettings{config.do(k)}, 'setting')
            runInfo = sprintf(' - step %s, ', config.stepName{config.do(k)});
            if ~strcmp(config.stepSettings{config.do(k)}.setting.infoStringMask, 'all')
                runInfo = [runInfo sprintf('factors with fixed modalities: %s', config.stepSettings{config.do(k)}.setting.infoStringMask)];
            end
            if config.stepSettings{config.do(k)}.nbSettings>1
                runInfo = [runInfo sprintf('\n     %d settings with the factors: %s', config.stepSettings{config.do(k)}.nbSettings, config.stepSettings{config.do(k)}.setting.infoStringFactors)];
            end
            config.runInfo{k} = runInfo;
            fprintf(2, '%s \n', config.runInfo{k});
        end
    end
    if config.display>0
        rem = setdiff(config.display, config.do);
    end
else
    if config.display>0
        rem = config.display;
    end
    end
end



for k=1:length(rem)
    [config.stepSettings{rem(k)}] = expStepSetting(config.factors, config.mask, rem(k));
end

% if ~isfield(config, 'stepSettings') || isempty(config.stepSettings{length(config.stepName)})
%      [config.stepSettings{length(config.stepName)}.settings config.stepSettings{length(config.stepName)}.settingSequence config.stepSettings{length(config.stepName)}.parameters config.stepSettings{length(config.stepName)}.settingSet] = expSettings(config.factors, config.mask, length(config.stepName));
% end

if isfield(config, 'serverConfig')
    %     config.host
    %     config.attachedMode
    if ~inputQuestion(), fprintf(' Bailing out ...\n'); return; end
    
    matConfig = config.serverConfig;
    matConfig.host = 0;
    matConfig.attachedMode = 0;
    matConfig.exitMatlab = 1;
    matConfig.sendMail = abs(config.email);
    matConfig.runInfo = config.runInfo;
    matConfig.staticDataFileName = [config.serverConfig.codePath '/config' '/' shortProjectName];
    matConfig.sync = [];
    
    matConfig.retrieve = -1; % do not retrieve on server setting
    
    command = [config.serverConfig.matlabPath 'matlab -nodesktop -nosplash -r  " if ispc; homePath= getenv(''USERPROFILE''); else homePath= getenv(''HOME''); end; codePath = strrep(''' ...
        config.serverConfig.codePath ''', ''~'', homePath); cd(strrep(codePath, ''\'', ''/'')) ' ...
        ';  configMatName = strrep(''' ...
        config.serverConfig.configMatName ''', ''~'', homePath); load(configMatName); delete(configMatName); ' ...
        config.projectName '(config);"']; % replace -d by -t in ssh for verbosity
    
    if config.host ~= config.serverConfig.host
        matConfig.localDependencies = 1;
        expConfigMatSave(expandHomePath(config.configMatName), matConfig);
        
        expSync(config, 'c', config.serverConfig, 'up');
        if config.localDependencies == 0
            %             config.serverConfig.localDependencies = 1;
            expSync(config, 'd', config.serverConfig, 'up');
        end
        expConfigMatSave(config.configMatName);
        % genpath dependencies ; addpath(ans);
        command = ['ssh ' config.hostName ' screen -m -d ''' config.serverConfig.matlabPath 'matlab -nodesktop -nosplash -r  "cd ' config.serverConfig.codePath ' ; load ' config.serverConfig.configMatName '; ' config.projectName '(config);"''']; % replace -d by -t in ssh for verbosity
        %         command = ['ssh ' config.hostName ' screen  -m -d ''' strrep(command, '''', '"''') ''''];
    else
        matConfig.localDependencies = 0;
        expConfigMatSave(expandHomePath(config.configMatName), matConfig);
        % genpath dependencies ; addpath(ans);
        command = ['screen  -m -d ' command];
    end
    
    % if runnning with issues with ssh connection run ssh with -v and check
    % that the LC_MESSAGES and LANG encoding are available on the server (locale -a)
    % if not edit /var/lib/locales/supported.d/local to put the needed ones
    % and run sudo dpkg-reconfigure locales or locales-gen
    
    system(command);
    fprintf('\nExperiment launched.\n');
    return;
else
    if config.sendMail==2
        expSendMail(config);
    end
    config = expOperate(config);
   % delete(expandHomePath(config.configMatName)); FIXME useless ?
end

if config.display ~= -1 && ~isempty(config.factors)
    if config.attachedMode
        config = exposeObservations(config);
    else
        try
            config = exposeObservations(config);
        catch catchedError
            expLog(config, catchedError, 3, 1);
        end
    end
end

if strfind(config.report, 'r')
    config.step.id = length(config.stepName);
    if config.attachedMode
        config = feval([config.shortProjectName 'Report'], config);
    else
        try
            config = feval([config.shortProjectName 'Report'], config);
        catch catchedError
            config.report='';
            expLog(config, catchedError, 3, 1);
        end
    end
    displayData = config.displayData; %#ok<NASGU>
    save(config.staticDataFileName, 'displayData', '-append');
    if ~strcmp(config.figureCopyPath, config.codePath) && exist(config.figureCopyPath, 'dir')
        try
            copyfile([config.reportPath 'figures/*'], config.figureCopyPath);
        end
    end
    if ~strcmp(config.tableCopyPath, config.codePath) && exist(config.tableCopyPath, 'dir')
        try
            copyfile([config.reportPath 'tables/*'], config.tableCopyPath);
        end
    end
else
    vars = whos('-file', config.staticDataFileName);
    if ismember('displayData', {vars.name})
        data = load(config.staticDataFileName, 'displayData');
        config.displayData = data.displayData;
    end
end

if config.sendMail>0
 expSendMail(config, 2);
elseif strfind(config.report, 'c')
    config = expTex(config, config.report);
end
if config.waitBar
    delete(config.waitBar);
end
if config.exitMatlab
    exit();
end

function config = exposeObservations(config)

for k=1:length(config.display)
    config.step = config.stepSettings{config.display(k)};
    if iscell(config.expose)
        config = expExpose(config, config.expose{:});
    else
        config = expExpose(config, config.expose);
    end
end
