function config = expStepRemove(config, rank)

if ~exist('rank', 'var'), rank=0; end

for k=2:length(config.stepName)
    stepFileName = [config.codePath config.shortExperimentName num2str(k) config.stepName{k} '.m'];
    previousStepFileName = [config.codePath config.shortExperimentName num2str(k-1) config.stepName{k} '.m'];
    if k>rank
        % copy first 3 lines
        newLines = expStepFile(config, config.stepName{k}, num2str(k-1), 0);
        % copy first 3 lines
        fid=fopen(stepFileName);
        C = textscan(fid, '%s', 'delimiter', '');
        fclose(fid);
        lines = C{1};
        lines(1:14) = cellstr(newLines(1:14, :));
        
        fid=fopen(stepFileName, 'w');
        for k=1:length(lines)
            fprintf(fid, '%s\n', lines{k});
        end
        fclose(fid);
        
        movefile(stepFileName, previousStepFileName);
    end
end

stepFileName = [config.codePath config.shortExperimentName num2str(rank) config.stepName{rank} '.m'];
delete(stepFileName);

config.stepName(rank) = [];

