function config = expProgress(config)

if ~config.progress, return; end

if config.parallel(config.step.id) > 0
    config.progressId = length(dir([config.tmpPath config.experimentName '_' num2str(config.runId) '_' num2str(config.step.id)  '*' ]));
    progress = ceil(100*config.progressId/length(config.step.sequence));
else
    config.progressId = config.progressId+1;
    progress = ceil(100*config.progressId/config.step.nbSettings);

end

if config.progress == 1 && config.attachedMode && config.parallel(config.step.id) == 0
    if isempty(config.waitBar)
        config.waitBar = waitbar(0,config.step.setting.infoString,'Name',['Step ' config.step.idName ' of ' config.experimentName],...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)', 'userdata', 'expProgress');
        setappdata(config.waitBar,'canceling',0);
    else
        waitbar(progress/100, config.waitBar, config.step.setting.infoString);
    end
    if getappdata(config.waitBar,'canceling')
        delete(config.waitBar);
        config.waitBar = [];
        waitbarId = []; %#ok<*NASGU>
        save(config.staticDataFileName, 'waitbarId', '-append');
        error('Stopping execution upon user request.');
    end
    if progress==100
        config.progressId = 0;
        delete(config.waitBar);
        config.waitBar = [];
        waitbarId = []; %#ok<NASGU>
        save(config.staticDataFileName, 'waitbarId', '-append');
    end
elseif 0 %config.progress == 1 % config.parallel(config.step.id) > 0 || 
    disp([upper(config.step.idName(1)) config.step.idName(2:end) ' -> ' config.step.setting.infoString]);
elseif config.progress < 3
    disp([upper(config.step.idName(1)) config.step.idName(2:end) ' (' num2str(progress) ' %)  ->   ' config.step.setting.infoString]);
elseif config.progress == 3
    disp(['Step ' num2str(config.step.id) ': ' num2str(progress) ' % done.']);
end