function [] = processSingleCommand(config, commands)

if ischar(commands{1})
    switch commands{1}
        case 'h'
            docFileName = [config.expLanesPath(1:end-3) 'doc/expLanesDocumentation.pdf'];
            fprintf('Welcome to the explanes experiment named %s\nYour configuration file is available in the config directory.\nThe documentation of expLanes is located at: %s\n', experimentName, docFileName);
            if inputQuestion('Shall it be opened now ?')
                open(docFileName);
            end
        case 'p'
            fprintf('---------------------------\nHistory: \n');
            historyFileName = expandHomePath([config.codePath 'config' filesep config.shortExperimentName 'History' upper(config.userName(1)) config.userName(2:end) '.txt']);
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
                config = expConfig(experimentPath, experimentName, shortExperimentName, commands);
                if isempty(config), return; end;
            end
        case 'v'
            config = expConfig(experimentPath, experimentName, shortExperimentName, {});
            if isempty(config), return; end;
            showFactors(config.factorFileName);
        case 'c'
            
        case 'f'
%             config = expConfig(experimentPath, experimentName, shortExperimentName);
            if isempty(config), return; end;
            expFactorDisplay(config, abs(config.showFactorsInReport), config.factorDisplayStyle);
        case 'F'
            config = expConfig(experimentPath, experimentName, shortExperimentName);
            if isempty(config), return; end;
            expFactorDisplay(config, abs(config.showFactorsInReport), config.factorDisplayStyle, 0);
        otherwise
            error('Unable to handle command');
    end
end