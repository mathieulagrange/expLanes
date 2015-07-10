function config = expStepCreate(config, name, rank)

if ~exist('rank', 'var'), rank=length(config.stepName)+1; end

tmpStepFile = [];

for k=length(config.stepName):-1:1
    stepFileName = [config.codePath config.shortExperimentName num2str(k) config.stepName{k} '.m'];
nextStepFileName = [config.codePath config.shortExperimentName num2str(k+1) config.stepName{k} '.m'];
    if k>=rank
        newLines = expStepFile(config, config.stepName{k}, num2str(k+1), 0);
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
        
        movefile(stepFileName, nextStepFileName);
    end
end

expStepFile(config, name, rank);

