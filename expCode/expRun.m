function config = expRun(projectPath, shortProjectName, commands)

config = expHistory(projectPath, shortProjectName, commands);

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
if config.show == 0
    if length(config.do)>1 || config.do>0
        config.show = config.do(end);
    elseif config.do == 0
        config.show = length(config.stepName);
    else
        config.show = -1;
    end
end
rem=[];
config.runInfo=[];
if config.do>-1
    fprintf('Project %s: running on host %s: \n', config.projectName, config.hostName);
    for k=1:length(config.do)
        [config.stepModes{config.do(k)}] = expModes(config.factorSpecifications, config.mask, config.do(k));
        
        config.runInfo{k} = sprintf(' - step %s with %s (%d modes)', config.stepName{config.do(k)}, config.stepModes{config.do(k)}.modes(1).infoStringMask, length(config.stepModes{config.do(k)}.modes));
        disp(config.runInfo{k});
    end
    if config.show>0
        rem = setdiff(config.show, config.do);
    end
else
    if config.show>0
        rem = config.show;
    end
end
for k=1:length(rem)
    [config.stepModes{rem(k)}] = expModes(config.factorSpecifications, config.mask, rem(k));
end

% if ~isfield(config, 'stepModes') || isempty(config.stepModes{length(config.stepName)})
%      [config.stepModes{length(config.stepName)}.modes config.stepModes{length(config.stepName)}.modeSequence config.stepModes{length(config.stepName)}.parameters config.stepModes{length(config.stepName)}.modeSet] = expModes(config.factorSpecifications, config.mask, length(config.stepName));
% end

if isfield(config, 'serverConfig')
    if inputQuestion(), fprintf(' Bailing out ...\n'); return; end
    
    matConfig = config.serverConfig;
    matConfig.host = -1;
    matConfig.runInfo = config.runInfo;
    matConfig.sync = [];
    matConfig.show = -1;
    %     if matConfig.report==1
    %     matConfig.report = 0; % output tex
    %     end
    matConfig.retrieve = 0; % do not retrieve on server mode
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
    
    system(command);
    fprintf('\nExperiment launched.\n');
    return;
else
    config = expOperate(config);
end

if config.show ~= -1
    %     try
    for k=1:length(config.show)
        config = expSetStep(config, config.show(k));
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
    try
        config.currentStep = length(config.stepName);
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
            message = sprintf('duration: %s \nnumber of cores used: %d\n\n', expTimeString(config.runDuration), max([1 config.parallel]));
            if ~isempty(config.runInfo)
                message = [message sprintf('%s\n', config.runInfo{:})];
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
            if exist(config.configMatName, 'file')
                config.mailAttachment{end+1} = config.configMatName;
            end
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

