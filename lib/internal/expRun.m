function config = expRun(experimentPath, experimentName, shortExperimentName, commands)

beep off
config = expInit(experimentPath, experimentName, shortExperimentName, commands);

if isempty(config), return; end;

expToolPath(config);
if config.probe
    expProbe(config);
end
if isempty(config.factors)
    config.mask = {{}};
elseif~expCheckMask(config.factors, config.mask) % || strcmp(commands{1},'report')
    mask = cell(1, length(config.factors.names));
    [mask{:}] = deal(-1);
    config.mask = {mask};
end

if config.generateRootFile
    expCreateRootFile(config, experimentName, shortExperimentName, config.expLanesPath);
end


% if ~exist([config.reportPath 'logs'], 'dir')
%     mkdir([config.reportPath 'logs']);
% end
config.logFileName = [config.tmpPath 'log_' config.experimentName '_' num2str(config.runId) '.txt'];
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

if config.export ~= 0
    expSync(config, config.export, -config.host);
    return
end

if ~isempty(config.clean)
    %     if iscell(config.clean)
    %         config.clean = config.clean{1};
    %     end
    if ischar(config.clean)
        if length(config.clean) == 1
            switch config.clean
                case 't'
                    dirPath = [config.homePath '.expLanes/tmp/'];
                    info = 'expLanes temporary data directory';
                case 'b'
                    dirPath = config.backupPath;
                    info = 'experiment backup directory';
                case 'k'
                    dirPath = config.dataPath;
                    info = 'all steps directories while keeping data of reachable settings starting from';
                otherwise
                    config.clean = {config.clean config.host};
                    dirPath = [];
                    %                     fprintf(2, 'Mono letter non numeric string input for clean can be: t (expLanes temporary data directory), b (experiment backup directory), \n k (all steps directories while keeping data of reachable settings). \n');
                    %                     return
            end
            if ~isempty(dirPath) && inputQuestion(['Cleaning ' info ': ' dirPath(1:end-1)])
                switch config.clean
                    case 'k'
                        expKeepClean(config);
                    otherwise
                        if exist(dirPath, 'dir')
                            rmdir(dirPath, 's');
                            mkdir(dirPath);
                        end
                end
            end
        else
            config.clean = {config.clean config.host};
        end
    elseif isnumeric(config.clean)
        config.clean = {num2str(config.clean) config.host};
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
        config.display = length(config.stepName);
    end
end
rem=[];
config.runInfo=[];
if ~isempty(config.factors)
    if config.do>-1
        fprintf('Experiment %s: run %d on host %s \n', config.experimentName, config.runId, config.hostName);
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
    matConfig.sendMail = abs(config.sendMail);
    matConfig.runInfo = config.runInfo;
    matConfig.staticDataFileName = [config.serverConfig.codePath '/config' '/' shortExperimentName];
    matConfig.sync = [];
    
    matConfig.retrieve = -1; % do not retrieve on server setting
    
    command = [config.serverConfig.matlabPath 'matlab -nodesktop -nosplash -r  " if ispc; homePath= getenv(''USERPROFILE''); else homePath= getenv(''HOME''); end; codePath = strrep(''' ...
        config.serverConfig.codePath ''', ''~'', homePath); cd(strrep(codePath, ''\'', ''/'')) ' ...
        ';  configMatName = strrep(''' ...
        config.serverConfig.configMatName ''', ''~'', homePath); load(configMatName); delete(configMatName); ' ...
        config.experimentName '(config);"']; % replace -d by -t in ssh for verbosity
    
    %  command = [config.serverConfig.matlabPath 'matlab -nodesktop -nosplash -r expRunServer(''' config.serverConfig.configMatName ''', ''' config.serverConfig.codePath ''')'];
    
    if config.host ~= config.serverConfig.host
        matConfig.localDependencies = 1;
        expConfigMatSave(expandHomePath(config.configMatName), matConfig);
        
        expSync(config, 'c', config.serverConfig, 'up');
        if config.localDependencies == 0
            %             config.serverConfig.localDependencies = 1;
            fprintf('Hint: when the code of dependencies is not modified, the sync of dependencies can be turned off by setting ''localDependencies'' to 1 in your config.\n');
            expSync(config, 'd', config.serverConfig, 'up');
        end
        expConfigMatSave(config.configMatName);
        % genpath dependencies ; addpath(ans);
        command = ['ssh ' config.hostName ' screen -m -d ''' config.serverConfig.matlabPath 'matlab -nodesktop -nosplash -r  "cd ' config.serverConfig.codePath ' ; load ' config.serverConfig.configMatName '; ' config.experimentName '(config);"''']; % replace -d by -t in ssh for verbosity
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
    
    if system(command);
        fprintf(2, '\n Launch of experiment failed.\n');
    else
        fprintf('\nExperiment launched.\n');
    end
    return;
else
    if config.sendMail==2
        expSendMail(config);
    end
    config = expOperate(config);
    % delete(expandHomePath(config.configMatName)); FIXME useless ?
end

if config.display ~= -1 && ~isempty(config.factors) && isempty(config.report) && sum(config.do) > -1
    if config.attachedMode
        config = exposeObservations(config);
    else
        try
            config = exposeObservations(config);
        catch catchedError
            config = expLog(config, catchedError, 3, 1);
        end
    end
end

if strfind(config.report, 'r')
    config.step.id = length(config.stepName);
    if config.attachedMode
        config = feval([config.shortExperimentName 'Report'], config);
    else
        try
            config = feval([config.shortExperimentName 'Report'], config);
        catch catchedError
            config.report='';
            config = expLog(config, catchedError, 3, 1);
        end
    end
    if strfind(config.report, 'h')
        if isempty(config.reportName)
            reportName = config.experimentName;
        else
            reportName = config.reportName;
        end
        config.html.title = [upper(reportName(1)), reportName(2:end)];
        config.html.author = config.completeName;
        config.html.date = date();
        data = config.html;
        htmlDataName = [config.reportPath config.experimentName config.reportName '/data/data.js'];
        savejson('', data, htmlDataName);
        
        jsFile=fopen(htmlDataName);
        jsCell = {'var data = '};
        while ~feof(jsFile)
            jsCell{end+1} = fgetl(jsFile);
        end
        fclose(jsFile);
        dlmwrite(htmlDataName, jsCell,'delimiter','');
        htmlReportName = [config.reportPath config.experimentName config.reportName '/index.html'];
        fprintf('The html report is available: %s\n', htmlReportName);
        if strfind(config.report, 'v')
            web(htmlReportName, '-browser');
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
    if exist(config.staticDataFileName, 'file')
        vars = whos('-file', config.staticDataFileName);
        if ismember('displayData', {vars.name})
            data = load(config.staticDataFileName, 'displayData');
            prompt = [];
            if ~isempty(config.displayData.prompt)
                prompt = config.displayData.prompt;
            end
            config.displayData = data.displayData;
            if ~isempty(prompt)
                config.displayData.prompt = prompt ;
            end
        end
    end
end

if config.readMe
    toolboxes = license('inuse');
    command = config.command;
    command(ismember(command,' ')) = [];
    command = strrep(command, '''readMe'',1', '');
    fid = fopen([config.codePath 'README.txt'], 'a');
    fprintf(fid, '-------------------------\n Replication informations for the experiment as of %s\nCommand: %s\nMatlab version: %s\nLoaded toolboxes:\n', date(), command, version());
    for k=1:length(toolboxes)
        fprintf(fid, '   - %s\n', toolboxes(k).feature);
    end
    fclose(fid);
    fprintf('The README.txt file has been updated with information about replication of this experiment.\n');
end

if config.sendMail>0
    expSendMail(config, 2);
elseif strfind(config.report, 'c')
    config = expTex(config, config.report);
end
if ~isempty(config.waitBar)
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
