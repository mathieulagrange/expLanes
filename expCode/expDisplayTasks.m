function expDisplayTasks(config)

p = fileparts(mfilename('fullpath'));

latexPath = [config.reportPath 'tex/'];
if ~exist(latexPath, 'dir')
    mkdir(latexPath);
end

texFileName = [latexPath config.shortProjectName 'Tasks.tex'];
pdfFileName = [config.reportPath 'figures/' config.shortProjectName 'Tasks.pdf'];

copyfile([p '/private/utils/headerVariantDisplay.tex'], texFileName);

% all tasks
allIndex = cellfun(@isempty, config.variantSpecifications.step);
allparameterIndex = config.variantSpecifications.names(allIndex);

functionCell = displayNode(config, allIndex);

% tasks
for k=1:length(config.taskName)
    taskIndex = allIndex == 0;
    mask = cell(1, size(config.variantSpecifications.values, 2));
    mask(:) = {0};
    mask = expVariantStep(config.variantSpecifications, mask, k);
    taskIndex([mask{:}]==-1) = 0;
    taskCell = displayNode(config, taskIndex, k) ;
    functionCell = [functionCell; taskCell];
end
% arrows
for k=1:length(config.taskName)-1
    functionCell{end+1} = ['\draw[taskArrow] (' num2str(k) '.east) -- (' num2str(k+1) '.west);'];
end

% footer
functionCell = [functionCell;...
    '\end{tikzpicture}'; ...
    '\end{center}'; ...
    '\end{document}]'; ...
    ];


functionString = char(functionCell);

dlmwrite(texFileName, functionString,'delimiter','', '-append');

oldFolder = cd(latexPath);
disp('generating latex figure. Press x enter if locked for too long');
res = system(['pdflatex ' texFileName ' >/dev/null']);
cd(oldFolder);
if ~res
    copyfile([texFileName(1:end-4) '.pdf'], pdfFileName);
    disp(['figure available: ', pdfFileName])
else
    return
end
if ~isempty(config.pdfViewer)
    cmd=[config.pdfViewer ' ', pdfFileName, ' &'];
else
    if ismac
        cmd=['open -a Preview ', pdfFileName, ' &'];
    else
        open(pdfFileName);
        return;
    end
end
system(cmd);

function functionCell = displayNode(config, parameterIndex, taskId)

if ~exist('taskId', 'var')
    taskId = 0;
    location = '';
    taskName = 'All tasks';
else
    location = [', right=of ' num2str(taskId-1)];
    taskName = config.taskName{taskId};
end

functionCell={...
    ['\node (' num2str(taskId) ') [task' location ']'];...
    ['{\textbf{' taskName '}'];...
    '\nodepart{two}\tabular{@{}l}  ', ...
    };

for k=1:length(parameterIndex)
    if parameterIndex(k) && length(config.variantSpecifications.values{k}) > 1
        if strcmp(config.variantSpecifications.sequentialParameter, config.variantSpecifications.names{k})
            seq = '(s)';
        else
            seq = '';
        end
            
        functionCell{end+1} = ['\texttt{' config.variantSpecifications.names{k} '} ' seq '\\'];
    end
end
functionCell{end+1} = '\endtabular';
functionCell{end+1} = ' ';
functionCell{end+1} = '\nodepart{three}\tabular{@{}l}  ';
for k=1:length(parameterIndex)
    if parameterIndex(k) && length(config.variantSpecifications.values{k}) == 1
        functionCell{end+1} = ['\texttt{' config.variantSpecifications.names{k} '} = ' config.variantSpecifications.stringValues{k}{1} '\\'];
    end
end
functionCell{end+1} = '\endtabular};';

