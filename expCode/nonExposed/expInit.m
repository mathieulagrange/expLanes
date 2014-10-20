function config = expInit(projectPath, projectName, shortProjectName, commands)

if length(commands)<1, % default config
    config = expConfig(projectPath, shortProjectName, shortProjectName, commands);
    if isempty(config), return; end;
    showFactors(config.factorFileName);
    
elseif length(commands)>1 % command line processing
    config = expConfig(projectPath, projectName, shortProjectName, commands);
    if isempty(config), return; end;
elseif isnumeric(commands{1})
    config = expConfig(projectPath, projectName, shortProjectName);
    if isempty(config), return; end;
    historyFileName = expandHomePath([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt']);
     fid = fopen(historyFileName, 'rt');
    foundCommand = '';
    if fid>0
        k=0;
        while ~feof(fid) && k~=commands{1}
            foundCommand = fgetl(fid);
            k=k+1;
        end
        fclose(fid);
    end
    if ~isempty(foundCommand)
        disp(['running: ' foundCommand]);
        eval(foundCommand);
        return
    else
        error('Command not found');
    end
elseif isstruct(commands{1}) % server mode
    config = commands{1};
elseif ischar(commands{1})
    config = expConfig(projectPath, projectName, shortProjectName);
    if isempty(config), return; end;
    switch commands{1}
        case 'h'
            % TODO display help
        case 'p'
            fprintf('---------------------------\nHistory: \n');
            historyFileName = expandHomePath([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt']);
           fid = fopen(historyfileName, 'rt');
            if fid>0
                lastCommands={};
                while ~feof(fid)
                    lastCommands{end+1} = fgetl(fid);
                end
                fclose(fid);
                for k=max([1 length(lastCommands)-10]):length(lastCommands)
                    fprintf('%d %s\n', k, lastCommands{k});
                end
                fprintf('///////////////////////////////////// \n');
                fprintf('Please enter the numeric id to rerun command\n');
                %         fprintf('Runnning %s\n', lastCommand);
                %         eval(lastCommand);
                return
            else
                config = expConfig(projectPath, projectName, shortProjectName, commands);
                if isempty(config), return; end;
            end
        case 'v'
            config = expConfig(projectPath, projectName, shortProjectName, {});
            if isempty(config), return; end;
            showFactors(config.factorFileName);
        case 'c'
            
        case 'f'
            config = expConfig(projectPath, projectName, shortProjectName);
            if isempty(config), return; end;
            expFactorDisplay(config, config.showFactorsInReport, config.factorDisplayStyle);
        case 'F'
            config = expConfig(projectPath, projectName, shortProjectName);
            if isempty(config), return; end;
            expFactorDisplay(config, config.showFactorsInReport, config.factorDisplayStyle, 0);
        otherwise
            error('Unable to handle command');
    end
    return
else
    config = expConfig(projectPath, projectName, shortProjectName, commands);
    if isempty(config), return; end;
end

if config.attachedMode==-1
    serverConfig = config;
    config = expConfig(projectPath, projectName, shortProjectName, [commands {'host', 0, 'attachedMode', -1, 'run', 0}]);
    config.serverConfig=serverConfig;
    config.hostName = config.serverConfig.hostName;
end

% fid = fopen([prefdir, filesep, 'history.m'],'rt');
% while ~feof(fid)
%     lastCommand = fgetl(fid);
% end
% fclose(fid);

hist = com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory;
if ~isempty(hist)
    lastCommand = char(hist(end));
else
    lastCommand = [];
end
if ~isempty(strfind(lastCommand, ''''))
    historyFileName = expandHomePath([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt']);
    fid = fopen(historyFileName, 'rt');
    commands = {};
    if fid>0
        while ~feof(fid)
            rLine = fgetl(fid);
            if ~strcmp(rLine, lastCommand)
                commands{end+1} = rLine;
            end
        end
        fclose(fid);
    end
    
    historyFileName = expandHomePath([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt']);
   fid = fopen(historyFileName, 'w');
   if fid == -1, error(['Unable to open ' historyFileName]); end
  
    for k=1:length(commands)
        fprintf(fid, '%s\n', commands{k});
        ends
    fprintf(fid, '%s\n', lastCommand);
    fclose(fid);
end

function showFactors(fileName)

fprintf('Factors:\n');
fid=fopen(fileName);
k=1;
while ~feof(fid)
    line = strtrim(fgetl(fid));
    if ~isempty(line) && ~strcmp(line(1), '%')
        fprintf('%d\t%s\n', k, line);
        k=k+1;
    end
end
fclose(fid);
