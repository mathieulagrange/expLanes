function expSendMail(config, atEnd)

if ~exist('atEnd', 'var'), atEnd=0; end

if ~config.useExpCodeSmtp
    [p, i]= regexp(config.hostName, '\.', 'split');
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

if isempty(regexp(config.emailAddress, '[a-z_]+@[a-z]+\.[a-z]+', 'match'))
    fprintf(2, 'The email address %s is not in a good format.\n', config.emailAddress);
else
    message = config.runInfo;
    message{end+1} = '';
    if ~atEnd
        message{end+1} = ['Mask: ' expMaskDisplay(config.mask)];
    else
        message{end+1} = ['total duration: ' expTimeString(config.runDuration)];
        if config.settingStatus.failed+config.settingStatus.success>0
            message{end+1} = ['average duration per setting: ' expTimeString(config.runDuration/(config.settingStatus.failed+config.settingStatus.success))];
        end
        message{end+1} = '';
        message{end+1} = ['Mask: ' expMaskDisplay(config.mask)];
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
            [content, location] = unique(lines);
            message = [message sprintf('\n\n -------------------------------------- \n')];
            for k=1:length(location)
                if isempty(strfind(lines{location(k)}, 'while'))
                    message = [message sprintf('%s\n', lines{location(k)})];
                    message = [message sprintf('%s\n', lines{location(k)+1})];
                end
            end
        end
        message = [message sprintf('\n\n -------------------------------------- \n')];
    end
    %  config.mailAttachment = {[config.reportPath 'logs/config.txt']};
    config.mailAttachment = {};
    for k=1:length(config.errorDataFileName)
        if exist(config.errorDataFileName{k}, 'file')
            config.mailAttachment{end+1} = config.errorDataFileName{k};
        end
    end
    if atEnd && ~isempty(strfind(config.report, 'c'))
        config = expTex(config, config.report);
        config.mailAttachment = [{config.pdfFileName} config.mailAttachment];
    end
    % sendMail does not like tilde
    config.mailAttachment = expandHomePath(config.mailAttachment);
    if ~atEnd
                title = ['[expLanes] ' config.experimentName ' id ' num2str(config.runId) ' is launched on ' config.hostName];
    else
        title = ['[expLanes] ' config.experimentName ' id ' num2str(config.runId) ' is over on ' config.hostName];
    end
    sendmail(config.emailAddress, title, message, config.mailAttachment);
end
% expConfigMatSave(config.configMatName);