function config = expRun(projectPath, projectName, shortProjectName, commands)

beep off
expCodePath = fileparts(mfilename('fullpath'));
config = expHistory(projectPath, projectName, shortProjectName, commands);

if isempty(config), return; end;

if ~exist(config.reportPath, 'dir'), mkdir(config.reportPath); end
if ~exist([config.reportPath 'figures'], 'dir'), mkdir([config.reportPath 'figures']); end
if ~exist([config.reportPath 'tables'], 'dir'), mkdir([config.reportPath 'tables']); end
if ~exist([config.reportPath 'tex'], 'dir'), mkdir([config.reportPath 'tex']); end
if ~exist([config.reportPath 'data'], 'dir'), mkdir([config.reportPath 'data']); end

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
    expCreateRootFile(config, projectName, shortProjectName, expCodePath);
end

config.logFileName = [config.reportPath 'log_' num2str(config.runId) '.txt'];
config.errorDataFileName = {};
if exist(config.logFileName, 'file')
    delete(config.logFileName);
end
if ~exist(config.reportPath, 'dir')
    mkdir(config.reportPath);
end

config.logFile = fopen([config.reportPath 'config.txt'], 'w');
fprintf(config.logFile, '\n%s\n', evalc('disp(config)'));
fclose(config.logFile);

if config.bundle ~= 0
    expSync(config, config.bundle, -1);
    return
end

if config.clean ~= 0
    if ischar(config.clean)
        config.clean = {config.clean 1};
    elseif isnumeric(config.clean)
        config.clean = {num2str(config.clean) 1};
    end
    expSync(config, config.clean{:}, 'c');
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
if config.obs == 0
    if length(config.do)>1 || config.do>0
        config.obs = config.do(end);
    else
        config.obs = -1;
    end
end
rem=[];
config.runInfo=[];
if config.do>-1
    fprintf('Project %s: running on host %s \n', config.projectName, config.hostName);
    for k=1:length(config.do)
        [config.stepSettings{config.do(k)}] = expStepSetting(config.factors, config.mask, config.do(k));
        runInfo = sprintf(' - step %s, ', config.stepName{config.do(k)});
        if ~strcmp(config.stepSettings{config.do(k)}.setting.infoStringMask, 'all')
            runInfo = [runInfo sprintf('factors with fixed modalities: %s', config.stepSettings{config.do(k)}.setting.infoStringMask)];
        end
        if config.stepSettings{config.do(k)}.nbSettings>1
            runInfo = [runInfo sprintf('\n     %d settings with the factors: %s', config.stepSettings{config.do(k)}.nbSettings, config.stepSettings{config.do(k)}.setting.infoStringFactors)];
        end
        config.runInfo{k} = runInfo;
        config = expLog(config, [config.runInfo{k} '\n']);
    end
    if config.obs>0
        rem = setdiff(config.obs, config.do);
    end
else
    if config.obs>0
        rem = config.obs;
    end
end



for k=1:length(rem)
    [config.stepSettings{rem(k)}] = expStepSetting(config.factors, config.mask, rem(k));
end

% if ~isfield(config, 'stepSettings') || isempty(config.stepSettings{length(config.stepName)})
%      [config.stepSettings{length(config.stepName)}.settings config.stepSettings{length(config.stepName)}.settingSequence config.stepSettings{length(config.stepName)}.parameters config.stepSettings{length(config.stepName)}.settingSet] = expSettings(config.factors, config.mask, length(config.stepName));
% end

if isfield(config, 'serverConfig')
    if ~inputQuestion(), fprintf(' Bailing out ...\n'); return; end
    
    matConfig = config.serverConfig;
    %     matConfig.host = -1;
    matConfig.attachedMode = 1;
    matConfig.exitMatlab = 1;
    matConfig.sendMail = 1;
    matConfig.runInfo = config.runInfo;
    matConfig.staticDataFileName = [config.serverConfig.codePath '/config' '/' shortProjectName];
    matConfig.sync = [];
    
    matConfig.retrieve = -1; % do not retrieve on server setting
    
    command = [config.serverConfig.matlabPath 'matlab -nodesktop -nosplash -r  " if ispc; homePath= getenv(''USERPROFILE''); else homePath= getenv(''HOME''); end; codePath = strrep(''' ...
        config.serverConfig.codePath ''', ''~'', homePath); cd(strrep(codePath, ''\'', ''/'')) ' ...
        ';  configMatName = strrep(''' ...
        config.serverConfig.configMatName ''', ''~'', homePath); load(configMatName); ' ...
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
    config = expOperate(config);
end

if config.obs ~= -1
    if config.attachedMode
        config = exposeObservations(config);
    else
        try
            config = exposeObservations(config);
        catch error
            if config.attachedMode
                rethrow(error);
            else
                explog(config, error, 3, 1);
            end
        end
    end
end

if config.report>-1
    config.step.id = length(config.stepName);
    if config.attachedMode
        config = feval([config.shortProjectName 'Report'], config);
    else
        try
            config = feval([config.shortProjectName 'Report'], config);
        catch error
            config.report=-1;
            if config.attachedMode
                rethrow(error);
            else
                expLog(config, error, 3, 1);
            end
        end
    end
    displayData = config.displayData; %#ok<NASGU>
    save(config.staticDataFileName, 'displayData', '-append');
elseif config.report>-3
    vars = whos('-file', config.staticDataFileName);
    if ismember('displayData', {vars.name})
        data = load(config.staticDataFileName, 'displayData');
        config.displayData = data.displayData;
    end
end


% switch config.host
%     case {-1, -2}
if config.sendMail
    if ~config.useExpCodeSmtp
        [p i]= regexp(config.hostName, '\.', 'split');
        if ~isempty(i)
            setpref('Internet', 'SMTP_Server', ['smtp' config.hostName(i(1):end)]);
            setpref('Internet', 'E_mail', [config.userName '@' config.hostName(i(1)+1:end)]);
        else
            expLog(config, 'Please set the domain extensions to the server names');
        end
    else
        setpref('Internet','E_mail','expcode.mailer@gmail.com');
        setpref('Internet','SMTP_Server','smtp.gmail.com');
        setpref('Internet','SMTP_Username', 'expcode.mailer@gmail.com');
        setpref('Internet','SMTP_Password', 'welovecode');
        
        props = java.lang.System.getProperties;
        props.setProperty('mail.smtp.auth','true');
        props.setProperty('mail.smtp.socketFactory.class', ...
            'javax.net.ssl.SSLSocketFactory');
        props.setProperty('mail.smtp.socketFactory.port','465');
    end
    
    
    
    if ~isempty(regexp(config.emailAddress, '[a-z_]+@[a-z]+\.[a-z]+', 'match'))
        message = config.runInfo;
        message{end+1} = '';
        
        message{end+1} = ['total duration: ' expTimeString(config.runDuration)];
        if config.settingStatus.failed+config.settingStatus.success>0
            message{end+1} = ['average duration per setting: ' expTimeString(config.runDuration/(config.settingStatus.failed+config.settingStatus.success))];
        end
        message{end+1} = '';
        message{end+1} = ['number of cores used: ' num2str(max([1 config.parallel]))];
        message{end+1} = ['number of successful settings: ' num2str(config.settingStatus.success)];
        message{end+1} = ['number of failed settings: ' num2str(config.settingStatus.failed)];
        message{end+1} = '';
        if ~isempty(config.displayData.prompt)
            prompt = evalc('disp(config.displayData.prompt)');
            prompt = regexp(prompt, '\n', 'split');
            message = [message prompt];
        end
        
        fid = fopen(config.logFileName);
        if fid>0
            C = textscan(fid, '%s', 'delimiter', '');
            fclose(fid);
            lines = C{1};
            message = [message sprintf('\n\n -------------------------------------- \n')];
            for k=1:length(lines)
                message = [message sprintf('%s\n', lines{k})];
            end
        end
        message = [message sprintf('\n\n -------------------------------------- \n')];
        config.mailAttachment = {[config.reportPath 'config.txt']};
        %             if exist(config.configMatName, 'file') % FIXME
        %                 config.mailAttachment{end+1} = config.configMatName;
        %             end
        %             if exist(config.logFileName, 'file')
        %                 config.mailAttachment{end+1} = config.logFileName;
        %             end
        for k=1:length(config.errorDataFileName)
            if exist(config.errorDataFileName{k}, 'file')
                config.mailAttachment{end+1} = config.errorDataFileName{k};
            end
        end
        if config.report~=0 && abs(config.report)<3
            config = expTex(config, 'c');
            config.mailAttachment = [{config.pdfFileName} config.mailAttachment];
        end
        % sendMail does not like tilde
        config.mailAttachment = expandHomePath(config.mailAttachment);
        sendmail(config.emailAddress, ['[expCode] ' config.projectName ' ' num2str(config.runId) ' is over on ' config.hostName], message, config.mailAttachment);
    end
    expConfigMatSave(config.configMatName);
else
    if config.report~=0 && abs(config.report)<3  % FIXME
        config = expTex(config);
    end
end
if config.waitBar
    delete(config.waitBar);
end
if config.exitMatlab
    exit();
end



function config = exposeObservations(config)

for k=1:length(config.obs)
    config.step = config.stepSettings{config.obs(k)};
    if iscell(config.display)
        config = expExpose(config, config.display{:});
    else
        config = expExpose(config, config.display);
    end
end
