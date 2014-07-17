function config = expTex(config, command)

if nargin<2, command= 'cv'; end

latexPath = [config.reportPath 'tex/'];
if ~exist(latexPath, 'dir')
    mkdir(latexPath);
end

reportName = '';
slides= 0 ;
if ~isempty(config.reportName)
    reportName = [upper(config.reportName(1)), config.reportName(2:end)];
    
    if strfind(lower(config.reportName), 'slides')
        slides = 1;
    end
end

config.latexFileName = [latexPath config.projectName reportName]; % '.tex'

% for k=1:length(config.stepName)
%     copyfile([config.codePath config.shortProjectName num2str(k) config.stepName{k} '.m'], [config.reportPath 'tex/' config.shortProjectName num2str(k) config.stepName{k} '.m']);
% end
% copyfile([config.codePath config.shortProjectName 'Init.m'], [config.reportPath 'tex/' config.shortProjectName 'Init.m']);
% copyfile([config.codePath config.shortProjectName 'Report.m'], [config.reportPath 'tex/' config.shortProjectName 'Report.m']);

if ~exist([config.reportPath config.projectName reportName '.tex'], 'file')
    config.latex = LatexCreator([config.reportPath filesep config.projectName reportName '.tex'], 0, config.completeName, [config.projectName ' version ' num2str(config.versionName) '\\ ' config.message], config.projectName, 1, 1, slides);
    copyfile([fileparts(mfilename('fullpath')) filesep 'utils/mcode.sty'], config.reportPath);
end
copyfile([config.reportPath config.projectName reportName '.tex'], [config.latexFileName '.tex']);
copyfile([fileparts(mfilename('fullpath')) filesep 'utils/mcode.sty'], [config.reportPath 'tex/']);

config.pdfFileName = [config.reportPath 'reports/' config.projectName '_' reportName '_v' num2str(config.versionName) '_' config.userName  '_' date '_' strrep(config.message, ' ', '-') '.pdf'];

config.latex = LatexCreator([config.latexFileName '.tex'], 1, config.completeName, [config.projectName ' version ' num2str(config.versionName) '\\ ' config.message], config.projectName, 1, 0, slides);

if config.showFactorsInReport
    pdfFileName = [config.reportPath 'figures/' config.shortProjectName 'Factors.pdf'];
    a=dir(pdfFileName);
    b=dir([config.codePath config.shortProjectName 'Factors.txt']);
    for k=1:length(config.stepName)
        c = dir([config.codePath config.shortProjectName num2str(k) config.stepName{k} '.m']);
        if c.datenum > b.datenum
            b=c;
        end
    end
    if ~exist(pdfFileName, 'file')  || a.datenum < b.datenum
        expDisplayFactors(config, config.showFactorsInReport, config.factorDisplayStyle, ~(abs(config.report)-1), 0);
    end
    
    if slides
        config.latex.addLine('\begin{frame}\frametitle{Factors flow graph}');       
    end
    
    config.latex.addLine('\begin{center}');
    config.latex.addLine('\begin{figure}');
    config.latex.addLine(['\includegraphics[width=\textwidth,height=0.8\textheight,keepaspectratio]{' expandHomePath(pdfFileName) '}']);
    config.latex.addLine('\label{factorFlowGraph}');
    if~slides
        config.latex.addLine('\caption{Factors flow graph for the experiment.}');
    end
    config.latex.addLine('\end{figure}');
    config.latex.addLine('\end{center}');
    if slides, config.latex.addLine('\end{frame}');end
    
end

% add table
for k=1:length(config.displayData.table)
    config.latex.addTable(config.displayData.table(k).table, 'caption', config.displayData.table(k).caption, 'multipage', config.displayData.table(k).multipage, 'landscape', config.displayData.table(k).landscape, 'label', config.displayData.table(k).label, 'fontSize', config.displayData.table(k).fontSize);
    if ~mod(k, 10)
        config.latex.addLine('\clearpage');
    end
end

% add figure
for k=1:length(config.displayData.figure)
    if config.displayData.figure(k).taken && config.displayData.figure(k).report
        config.latex.addFigure(config.displayData.figure(k).handle, 'caption', config.displayData.figure(k).caption, 'label', config.displayData.figure(k).label);
        if ~mod(k, 10)
            config.latex.addLine('\clearpage');
        end
    end
end

data = config.displayData;
save(strrep(config.pdfFileName, '.pdf', '.mat'), 'data');

for k=1:length(command)
    switch command(k)
        case 'c'
            oldFolder = cd(latexPath);
            disp('generating latex report. Press x enter if locked for too long (use report=2 for debug info)');
            res = config.latex.createPDF(~(abs(config.report)-1));
            cd(oldFolder);
            if ~res
                copyfile([config.latexFileName '.pdf'], config.pdfFileName);
                disp(['report available: ', config.pdfFileName])
            else
                return
            end
        case 'v'
           expShowPdf(config, config.pdfFileName);
    end
end

if config.deleteTexDirectory
    warning off
    rmdir(latexPath, 's');
    mkdir(latexPath);
    warning on
end


