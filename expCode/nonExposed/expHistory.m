function config = expHistory(projectPath, shortProjectName, commands)

if length(commands)<1,
    config = expConfig(projectPath, shortProjectName, commands);
    showSettings(config.factorFileName);
    fprintf('---------------------------\nHistory: \n');
    fid = fopen([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt'], 'rt');
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
        config = expConfig(projectPath, shortProjectName);
    end
elseif length(commands)>1 % || isstruct(varargin{1})
    config = expConfig(projectPath, shortProjectName, commands);
elseif isnumeric(commands{1})
    config = expConfig(projectPath, shortProjectName, {});
    fid = fopen([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt'], 'rt');
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
elseif isstruct(commands{1})
    config = commands{1};
elseif ischar(commands{1})
    switch commands{1}
        case 'v'
            config = expConfig(projectPath, shortProjectName, {});
            showSettings(config.factorFileName);
        case 'c'
            
        case 'f'
            config = expConfig(projectPath, shortProjectName);
            expDisplayFactors(config);
       case 'F'
            config = expConfig(projectPath, shortProjectName);
            expDisplayFactors(config, 0);
        otherwise
            error('Unable to handle command');
    end
    return
else
    config = expConfig(projectPath, shortProjectName, commands);
end

if config.host>0
    serverConfig = config;
    config = expConfig(projectPath, shortProjectName, [commands {'host', 0}]);
    config.serverConfig=serverConfig;
    config.hostName = config.serverConfig.hostName;
end

fid = fopen([prefdir, filesep, 'history.m'],'rt');
while ~feof(fid)
    lastCommand = fgetl(fid);
end
fclose(fid);
if ~isempty(strfind(lastCommand, ''''))
    fid = fopen([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt'], 'rt');
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
    
    fid = fopen([config.codePath 'config' filesep config.shortProjectName 'History' upper(config.userName(1)) config.userName(2:end) '.txt'], 'w');
    for k=1:length(commands)
        fprintf(fid, '%s\n', commands{k});
    end
    fprintf(fid, '%s\n', lastCommand);
    fclose(fid);
end

function showSettings(fileName)

fprintf('Settings:\n');
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