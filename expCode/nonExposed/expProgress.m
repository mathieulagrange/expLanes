function config = expProgress(config)

if ~config.progress, return; end

% TODO use rewind feed
config.progressId = config.progressId+1;

progress = ceil(100*config.progressId/config.step.nbDesigns);

if config.progress == 1 && config.host == 0 && config.parallel(config.step.id) == 0
    %     waitbar(progress/100);
    if isempty(config.waitBar)
        config.waitBar = waitbar(0,config.step.design.infoString,'Name',['Step ' config.step.idName ' of ' config.projectName],...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(config.waitBar,'canceling',0);
        config.progressId = 0;
        waitbarId = config.waitBar;
        save(config.staticDataFileName, 'waitbarId', '-append');
    else
        waitbar(progress/100, config.waitBar, config.step.design.infoString);
    end
    if getappdata(config.waitBar,'canceling')
        delete(config.waitBar);
        config.waitBar = [];
        waitbarId = [];
        save(config.staticDataFileName, 'waitbarId', '-append');
        error('Stopping execution upon user request.');
    end
    if progress==100
        delete(config.waitBar);
        config.waitBar = [];
        waitbarId = [];
        save(config.staticDataFileName, 'waitbarId', '-append');
    end
elseif config.parallel(config.step.id) > 0 || config.progress == 1
      disp([config.step.idName ': ' config.step.design.infoString]);  
elseif config.progress == 2
    disp([config.step.idName '(' num2str(progress) '%): ' config.step.design.infoString]);
elseif config.progress == 3
    disp(['Step ' num2str(config.step.id) ': ' num2str(progress) '% done.']);
end