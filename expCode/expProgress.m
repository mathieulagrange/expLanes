function config = expProgress(config, bar)

if ~exist('bar', 'var'), bar=0; end

% TODO progress bar on local host
progress = ceil(100*config.currentMode.id/length(config.modes));
if bar
    %     waitbar(progress/100);
    if isempty(config.waitBar)
        config.waitBar = waitbar(0,config.currentMode.infoString,'Name',['Step ' config.currentStepName ' of ' config.projectName],...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(config.waitBar,'canceling',0)
    else
        waitbar(progress/100, config.waitBar, config.currentMode.infoString);
    end
    if getappdata(config.waitBar,'canceling')
        delete(config.waitBar);
        error('Stopping execution upon user request.');
    end
    if progress==100
        delete(config.waitBar);
    end
else
    disp(['Step ' num2str(config.currentStep) ': ' num2str(progress) '% done.']);
end