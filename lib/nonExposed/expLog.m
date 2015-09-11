function config = expLog(config, message, expInfo, codeLocation, destination, level)

% TODO varargin parameter parsing

stack = [];
if nargin<2,
    message = '';
else
    if ~ischar(message)
        if strcmp(message.message(1:7), 'expLanes')
                       stack = message.stack(2:end);
%             message = ['catchedWarning \n Debug data may be available at: ', message.message(9:end) ' \n '];
        else
            stack = message.stack;
        end
                 message = message.message;
    end
end

if nargin<3, expInfo = 0; end
if nargin<4, codeLocation = 0; end
if nargin<5
    if ~config.attachedMode
        destination = 'both';
    else
        destination = 'prompt';
    end
end
if nargin<6, level = 1; end

if config.log >= level
    switch expInfo
        case 1
            expInfoString = ['performing ' config.stepName{config.step.id} ' step with setting ' config.step.setting.infoString '.\n'];
        case 2
            expInfoString = ['performing ' config.stepName{config.step.id} ' step ' mat2str(config.step.setting.infoId) ': ' config.step.setting.infoString];
        otherwise
            expInfoString = '';
    end
    
    if codeLocation && ~isempty(stack)
        codeLocation = sprintf('in function %s, line %d of file %s\n', stack(1).name, stack(1).line, stack(1).file);
        if expInfo
            codeLocation = ['   ' codeLocation];
        end
    else
        codeLocation = '';
    end
    
    if ~isempty(message)
        if ~isempty(expInfoString) || ~isempty(codeLocation)
            message = [message '\nwhile ' expInfoString    codeLocation];
        end
    else
        message = [expInfoString codeLocation];
    end
    
    if any(strcmp({'prompt', 'both'}, destination))
        fprintf(2, message);
    end
    
    if any(strcmp({'file', 'both'}, destination))
        logFile = fopen(config.logFileName, 'a');
        if logFile == -1, error(['Unable to write to ' config.logFileName]); end
        fprintf(logFile, [message '\n\n']);
%         fprintf('%s', message);
        fclose(logFile);
    end
end