function config = expProgress(config)

if ~config.progress, return; end

% TODO use rewind feed
progress = ceil(100*config.currentDesign.id/length(config.designs));
if config.progress == 1 && config.host == 0 && config.parallel(config.currentStep) == 0
    %     waitbar(progress/100);
    if isempty(config.waitBar)
        config.waitBar = waitbar(0,config.currentDesign.infoString,'Name',['Step ' config.currentStepName ' of ' config.projectName],...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(config.waitBar,'canceling',0)
    else
        waitbar(progress/100, config.waitBar, config.currentDesign.infoString);
    end
    if getappdata(config.waitBar,'canceling')
        delete(config.waitBar);
        error('Stopping execution upon user request.');
    end
    if progress==100
        delete(config.waitBar);
    end
elseif config.parallel(config.currentStep) > 0 || config.progress == 1
      disp([config.currentStepName ': ' config.currentDesign.infoString]);  
elseif config.progress == 2
    disp([config.currentStepName '(' num2str(progress) '% done): ' design.infoString]);
elseif config.progress == 3
    disp(['Step ' num2str(config.currentStep) ': ' num2str(progress) '% done.']);
end