function config = expTex(config, command)

if ~exist('command', 'var'), command= 'cv'; end

latexPath = [config.reportPath 'tex/'];
if ~exist(latexPath, 'dir')
    mkdir(latexPath);
end

reportName = '';
slides= 0 ;
if ~isempty(config.reportName)
    reportName = [upper(config.reportName(1)), config.reportName(2:end)];
    
    if strfind(lower(config.reportName), 'slides')
        config.latexDocumentClass = 'beamer';
        slides = 1;
    end
end

config.latexFileName = [latexPath config.experimentName reportName];
if ~exist([config.reportPath config.experimentName reportName '.tex'], 'file')
    config.latex = LatexCreator([config.reportPath filesep config.experimentName reportName '.tex'], 0, config.completeName, [config.experimentName reportName], config.experimentName, 1, 1, config.latexDocumentClass);
end
if ~exist([config.reportPath 'mcode.sty'], 'file')
    copyfile([fileparts(mfilename('fullpath')) filesep 'utils/mcode.sty'], config.reportPath);
end
if ~exist([config.reportPath 'bib.bib'], 'file')
    fid=fopen([config.reportPath 'bib.bib'], 'w');
    fclose(fid);
end

% copy any tex related files
files = [dir([config.reportPath, '*tex']); dir([config.reportPath, '*bib']); dir([config.reportPath, '*sty']); dir([config.reportPath, '*cls'])   ];
for k=1:length(files)
    if ~files(k).isdir
        copyfile([config.reportPath files(k).name], [config.reportPath 'tex/']);
    end
end

if  ~isempty(reportName), reportName(end+1) = '_'; end
config.pdfFileName = [config.reportPath 'reports/' reportName config.experimentName   upper(config.userName(1)) config.userName(2:end)   date  '.pdf'];

keep=1;
if isempty(strfind(command, 'r'))
    keep = 2;
end
config.latex = LatexCreator([config.latexFileName '.tex'], keep, config.completeName, [config.experimentName reportName], config.experimentName, 1, 0, config.latexDocumentClass);
config.latex.addLine(''); % mandatory

if abs(config.showFactorsInReport)
    pdfFileName = [config.reportPath 'figures/factors.pdf'];
    a=dir(pdfFileName);
    b=dir([config.codePath config.shortExperimentName 'Factors.txt']);
    for k=1:length(config.stepName)
        c = dir([config.codePath config.shortExperimentName num2str(k) config.stepName{k} '.m']);
        if c.datenum > b.datenum
            b=c;
        end
    end
    if ~exist(pdfFileName, 'file')  || a.datenum < b.datenum
        expFactorDisplay(config, abs(config.showFactorsInReport), config.factorDisplayStyle, isempty(strfind(config.report, 'd')), 0);
    end
   if  config.showFactorsInReport > 0 
    if slides
        config.latex.addLine('\begin{frame}\frametitle{Factors flow graph}');
    end
    
    config.latex.addLine('\begin{center}');
    config.latex.addLine('\begin{figure}');
    config.latex.addLine('\includegraphics[width=\textwidth,height=0.8\textheight,keepaspectratio]{../figures/factors.pdf}');
    config.latex.addLine('\label{factorFlowGraph}');
    if~slides
        config.latex.addLine('\caption{Factors flow graph for the experiment.}');
    end
    config.latex.addLine('\end{figure}');
    config.latex.addLine('\end{center}');
    if slides, config.latex.addLine('\end{frame}');end
   end
end

t=1;
l=1;
for k=config.displayData.style
    if k
        % add table
        config.latex.addTable(config.displayData.table(t).table, 'caption', config.displayData.table(t).caption, 'multipage', config.displayData.table(t).multipage, 'landscape', config.displayData.table(t).landscape, 'label', config.displayData.table(t).label, 'fontSize', config.displayData.table(t).fontSize, 'nbFactors', config.displayData.table(t).nbFactors);
        if ~mod(t, 10)
            config.latex.addLine('\clearpage');
        end
        t=t+1;
    else
        % add figure
        if config.displayData.figure(l).taken && config.displayData.figure(l).report
            config.latex.addFigure(config.displayData.figure(l).handle, 'caption', config.displayData.figure(l).caption, 'label', config.displayData.figure(l).label);
            if ~mod(l, 10)
                config.latex.addLine('\clearpage');
            end
        end
        l=l+1;
    end
end

data = config.displayData; %#ok<NASGU>
save(strrep(config.pdfFileName, '.pdf', '.mat'), 'data');

for k=1:length(command)
    switch command(k)
        case 'c'
            oldFolder = cd(latexPath);
            disp('generating latex report. Press x enter if locked for too long (use report with ''d'' option for debug info)');
            if strfind(config.report, 'd')
                silent = 0;
            else
                silent = 1;
            end
            res = config.latex.createPDF(silent);
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

% if config.deleteTexDirectory
%     warning('off', 'MATLAB:RMDIR:NoDirectoriesRemoved');
%     warning('off', 'MATLAB:RMDIR:RemovedFromPath');
%     rmdir(latexPath, 's');
%     mkdir(latexPath);
%         warning('on', 'MATLAB:RMDIR:RemovedFromPath');
%     warning('on', 'MATLAB:RMDIR:NoDirectoriesRemoved');
% end


