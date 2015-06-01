function expStepRemove(config, name, rank)

if ~exist('rank', 'var'), rank=0; end

previousStepFileName = [config.codePath '/' config.shortProjectName num2str(1) name '.m'];
for k=2:stepNames
    stepFileName = [config.codePath '/' config.shortProjectName num2str(k) name '.m'];
    
    if k>rank
        if isempty(name) % delete mode
            movefile(stepFileName, previousStepFileName);
        else % addition mode
            
        end
    end
    previousStepFileName = stepFileName;
end

if ~isempty(name)
    expCreateStepFile(config, name, rank);
end

