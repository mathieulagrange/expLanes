function config = expRun(projectPath, shortProjectName, commands)

beep off

config = expHistory(projectPath, shortProjectName, commands);

config.logFileName = [config.reportPath 'log_' num2str(config.runId) '.txt'];
config.errorDataFileName = {};
if exist(config.logFileName, 'file')
    delete(config.logFileName);
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
        [config.stepDesigns{config.do(k)}] = expStepDesign(config.factors, config.mask, config.do(k));
        if config.stepDesigns{config.do(k)}.nbDesigns>1
            config.runInfo{k} = sprintf(' - step %s, factors with fixed modality: %s \n     %d designs, factors: %s', config.stepName{config.do(k)}, config.stepDesigns{config.do(k)}.design.infoStringMask, config.stepDesigns{config.do(k)}.nbDesigns, config.stepDesigns{config.do(k)}.design.infoStringFactors);
        else
            config.runInfo{k} = sprintf(' - step %s, factors with fixed modality: %s', config.stepName{config.do(k)}, config.stepDesigns{config.do(k)}.design.infoStringMask);
        end
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
    [config.stepDesigns{rem(k)}] = expStepDesign(config.factors, config.mask, rem(k));
end

% if ~isfield(config, 'stepDesigns') || isempty(config.stepDesigns{length(config.stepName)})
%      [config.stepDesigns{length(config.stepName)}.designs config.stepDesigns{length(config.stepName)}.designSequence config.stepDesigns{length(config.stepName)}.parameters config.stepDesigns{length(config.stepName)}.designSet] = expDesigns(config.factors, config.mask, length(config.stepName));
% end

if isfield(config, 'serverConfig')
    if ~inputQuestion(), fprintf(' Bailing out ...\n'); return; end
    
    matConfig = config.serverConfig;
    matConfig.host = -1;
    matConfig.runInfo = config.runInfo;
    matConfig.sync = [];
    %     matConfig.obs = -1;
    %     if matConfig.report==1
    %     matConfig.report = 0; % output tex
    %     end
    matConfig.retrieve = 0; % do not retrieve on server design
    if config.serverConfig.host>1
        matConfig.localDependencies = 1;
        expConfigMatSave(config.configMatName, matConfig);
        
        expSync(config, 'c', config.serverConfig, 'up');
        if config.localDependencies == 0
            expSync(config, 'd', config.serverConfig, 'up');
        end
        expConfigMatSave(config.configMatName);
        % genpath dependencies ; addpath(ans);
        command = ['ssh ' config.hostName ' screen -m -d ''' config.serverConfig.matlabPath 'matlab -nodesktop -nosplash -r  "cd ' config.serverConfig.codePath ' ; load ' config.serverConfig.configMatName '; ' config.projectName '(config);"''']; % replace -d by -t in ssh for verbosity
    else
        matConfig.localDependencies = 0;
        expConfigMatSave(config.configMatName, matConfig);
        % genpath dependencies ; addpath(ans);
        command = ['screen -m -d ' config.matlabPath 'matlab -nodesktop -nosplash -r  "cd ' config.serverConfig.codePath ' ; load ' config.serverConfig.configMatName '; ' config.projectName '(config);"']; % replace -d by -t in ssh for verbosity
    end
    
    % if runnning with issues with ssh connection run ssh with -v and check
    % that the LC_MESSAGES and LANG encoding are available on the server
    % if not edit /var/lib/locales/supported.d/local to put the needed ones
    % and run sudo dpkg-reconfigure locales
    
    system(command);
    fprintf('\nExperiment launched.\n');
    return;
else
    config = expOperate(config);
end

if config.obs ~= -1
    %     try
    for k=1:length(config.obs)
        config.step = config.stepDesigns{config.obs(k)};
        if iscell(config.display)
            config = expExpose(config, config.display{:});
        else
            config = expExpose(config, config.display);
        end
        %         end
        %     catch error
        %         if config.host == 0
        %             rethrow(error);
        %         else
        %             expLog(config, error, 3, 1);
        %         end
    end
end

if config.report>-1
    config.step.id = length(config.stepName);
    if config.host == 0
        config = feval([config.shortProjectName 'Report'], config);
    else
        try
            config = feval([config.shortProjectName 'Report'], config);
        catch error
            config.report=-1;
            if config.host == 0
                rethrow(error);
            else
                expLog(config, error, 3, 1);
            end
        end
    end
    displayData = config.displayData; %#ok<NASGU>
    save(config.staticDataFileName, 'displayData', '-append');
else
    vars = whos('-file', config.staticDataFileName);
    if ismember('displayData', {vars.name})
        data = load(config.staticDataFileName, 'displayData');
        config.displayData = data.displayData;
    end
end


switch config.host
    case {-1, -2}
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
            message{end+1} = ['average duration per design: ' expTimeString(config.runDuration/(config.designStatus.failed+config.designStatus.success))];
            message{end+1} = '';
            message{end+1} = ['number of cores used: ' num2str(max([1 config.parallel]))];
            message{end+1} = ['number of successful designs: ' num2str(config.designStatus.success)];
            message{end+1} = ['number of failed designs: ' num2str(config.designStatus.failed)];
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
            if exist(config.logFileName, 'file')
                config.mailAttachment{end+1} = config.logFileName;
            end
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
            config.mailAttachment = expandPath(config.mailAttachment);
            sendmail(config.emailAddress, ['[expCode] ' config.projectName ' ' num2str(config.runId) ' is over on ' config.hostName], message, config.mailAttachment);
        end
        expConfigMatSave(config.configMatName);
        if config.host == -1, exit(); end
    case 0
        if config.report~=0 && abs(config.report)<3
            config = expTex(config);
        end
end

if config.waitBar
    delete(config.waitBar);
end
