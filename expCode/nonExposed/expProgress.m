function config = expProgress(config)

if ~config.progress, return; end

% TODO use rewind feed
progress = ceil(100*config.currentDesign.id/length(config.step.nbDesigns));
if config.progress == 1 && config.host == 0 && config.parallel(config.step.id) == 0
    %     waitbar(progress/100);
    if isempty(config.waitBar)
        config.waitBar = waitbar(0,config.currentDesign.infoString,'Name',['Step ' config.step.idName ' of ' config.projectName],...
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
elseif config.parallel(config.step.id) > 0 || config.progress == 1
      disp([config.step.idName ': ' config.currentDesign.infoString]);  
elseif config.progress == 2
    disp([config.step.idName '(' num2str(progress) '% done): ' design.infoString]);
elseif config.progress == 3
    disp(['Step ' num2str(config.step.id) ': ' num2str(progress) '% done.']);
end