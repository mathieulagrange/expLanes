function config = expStepRemove(config, rank)

if ~exist('rank', 'var'), rank=0; end

previousStepFileName = [config.codePath '/' config.shortProjectName num2str(1) config.stepName{1} '.m'];
stepFileName = previousStepFileName;
for k=2:length(config.stepName)
    stepFileName = [config.codePath '/' config.shortProjectName num2str(k) config.stepName{k} '.m'];
    if k>rank
        % copy first 3 lines
        fid=fopen(previousStepFileName);
        C = textscan(fid, '%s', 'delimiter', '');
        fclose(fid);
        previousLines = C{1};
        
        fid=fopen(stepFileName);
        C = textscan(fid, '%s', 'delimiter', '');
        fclose(fid);
        lines = C{1};
        lines(1:12) = previousLines(1:12);
        
        fid=fopen(stepFileName, 'w');
        for k=1:length(lines)
            fprintf(fid, '%s\n', lines{k});
        end
        fclose(fid);
        
        movefile(stepFileName, previousStepFileName);
    end
    previousStepFileName = stepFileName;
end
if exist(stepFileName, 'file')
    delete(stepFileName);
end

config.stepName(rank) = [];

