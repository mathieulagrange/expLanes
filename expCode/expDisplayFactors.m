function expDisplayFactors(config, infoType, style, silent, show)
% style 0: no propagation, 1: propagation, 2: all steps node

if ~exist('silent', 'var'), silent=1; end
if ~exist('show', 'var'), show=1; end
if ~exist('style', 'var'), style=0; end
if ~exist('infoType', 'var') || infoType==0, infoType=4; end

p = fileparts(mfilename('fullpath'));

latexPath = [config.reportPath 'tex/'];
if ~exist(latexPath, 'dir')
    mkdir(latexPath);
end

texFileName = [latexPath config.shortProjectName 'Factors.tex'];
pdfFileName = [config.reportPath 'figures/' config.shortProjectName 'Factors.pdf'];

copyfile([p '/nonExposed/utils/headerFactorDisplay.tex'], texFileName);


if style > 1
    % all steps
    allIndex = cellfun(@isempty, config.factors.step);
%     allfactorIndex = config.factors.names(allIndex);
    functionCell = displayNode(config, allIndex);
else
    functionCell = {};
end

% steps
for k=1:length(config.stepName)
    if style > 1
        stepIndex = allIndex == 0;
    else
        stepIndex = ones(1, size(config.factors.values, 2));
    end
    mask = cell(1, size(config.factors.values, 2));
    mask(:) = {0};
    mask = expSettingStepMask(config.factors, {mask}, k);
    stepIndex([mask{:}{:}]==-1) = 0;
    if ~style
        for m=1:k-1
            stepIndex(stepIndexes{m} == 1) = 0;
        end
    end
    stepIndexes{k} = stepIndex;
end

for k=1:length(config.stepName)
    stepCell = displayNode(config, stepIndexes{k}, k, style, infoType) ;
    functionCell = [functionCell; stepCell];
end

% arrows
for k=1:length(config.stepName)-1
    if infoType == 2 || infoType  == 4
        storeNames = expGetStepVariables(config, k, 'store');
    storeNames(2, :) = {'\\'};storeNames(2, end) = {''};
    storeNames = [storeNames{:}];
   
    functionCell{end+1} = ['\draw[stepArrow]   (' num2str(k) '.east) -- (' num2str(k+1) '.west) node[midway,text width=3cm,text centered,below] {\textbf{' storeNames '}} ;'];    
    else
    functionCell{end+1} = ['\draw[stepArrow]   (' num2str(k) '.east) -- (' num2str(k+1) '.west) ;'];
    end
end
if infoType == 2 || infoType  == 4
    storeNames = expGetStepVariables(config, length(config.stepName), 'store');
    storeNames(2, :) = {'\\'};storeNames(2, end) = {''};
    storeNames = [storeNames{:}];
    if ~isempty(storeNames)
        functionCell{end+1}=['\node (' num2str(length(config.stepName)+1) ') [right=of ' num2str(length(config.stepName)) ']{};'];

        functionCell{end+1} = ['\draw[stepArrow]   (' num2str(length(config.stepName)) '.east) -- (' num2str(length(config.stepName)+1) '.west) node[midway, text width=3cm,text centered,below] {\textbf{' storeNames '}} ;'];
    end
% else
%     functionCell{end+1} = ['\draw[stepArrow]   (' num2str(length(config.stepName)) '.east) -- (' num2str(length(config.stepName)) '.east) ;'];
end

% footer
functionCell = [functionCell;...
    '\end{tikzpicture}'; ...
    '\end{center}'; ...
    '\end{document}]'; ...
    ];

silentString = '';
if silent
    silentString = ' >/dev/null';
end

functionString = char(functionCell);

dlmwrite(texFileName, functionString,'delimiter','', '-append');

oldFolder = cd(latexPath);
disp('generating latex figure. Press x enter if locked for too long');
res = system(['pdflatex ' texFileName silentString]); %
cd(oldFolder);
if ~res
    copyfile([texFileName(1:end-4) '.pdf'], pdfFileName);
    disp(['figure available: ', pdfFileName])
else
    return
end
if show
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
end

function functionCell = displayNode(config, factorIndex, stepId, style, infoType)

if ~exist('stepId', 'var')
    stepId = 0;
    location = '';
    stepName = 'All steps';
else
    if style==2 || stepId > 1
        location = [', right=of ' num2str(stepId-1)];
    else
        location = '';
    end
    stepName = config.stepName{stepId};
end

functionCell={...
    ['\node (' num2str(stepId) ') [stepBlock' location ']'];...
    ['{\textbf{' stepName '}'];...
    '\nodepart{two}\tabular{@{}l}  ', ...
    };

for k=1:length(factorIndex)
    if factorIndex(k) && length(config.factors.values{k}) > 1
        if strcmp(config.factors.sequentialFactor, config.factors.names{k})
            seq = '(s)';
        else
            seq = '';
        end
        
        functionCell{end+1} = ['\texttt{' config.factors.names{k} '} ' seq '\\'];
    end
end
functionCell{end+1} = '\endtabular';
functionCell{end+1} = ' ';
functionCell{end+1} = '\nodepart{three}\tabular{@{}l}  ';

for k=1:length(factorIndex)
    if factorIndex(k) && length(config.factors.values{k}) == 1
        functionCell{end+1} = ['\texttt{' config.factors.names{k} '} = ' config.factors.stringValues{k}{1} '\\'];
    end
end
functionCell{end+1} = '\endtabular};';
if infoType>2
    [obsNames structId] = expGetStepVariables(config, stepId, 'obs');
    for k=1:length(obsNames)
        if structId(k)
            obsNames{k} = ['\textbf{' obsNames{k} '}'];
        end
    end
    obsNames(2, :) = {'\\'};obsNames(2, end) = {''};
    obsNames = [obsNames{:}];
    if ~isempty(obsNames)
        
    functionCell{end+1} = ['\draw[obsArrow]   (' num2str(stepId) '.south) -- (' num2str(stepId) '.south) node[midway,text width=3cm,text centered,below] {\textit{' obsNames '}} ;'];
    end
end
