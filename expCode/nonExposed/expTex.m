function config = expTex(config, command)

if nargin<2, command= 'cv'; end

latexPath = [config.reportPath 'tex/'];
if ~exist(latexPath, 'dir')
    mkdir(latexPath);
end

config.latexFileName = [latexPath config.projectName ]; % '.tex'

for k=1:length(config.stepName)
    copyfile([config.codePath config.shortProjectName num2str(k) config.stepName{k} '.m'], [config.reportPath 'tex/' config.shortProjectName num2str(k) config.stepName{k} '.m']);
end
copyfile([config.codePath config.shortProjectName 'Init.m'], [config.reportPath 'tex/' config.shortProjectName 'Init.m']);
copyfile([config.codePath config.shortProjectName 'Report.m'], [config.reportPath 'tex/' config.shortProjectName 'Report.m']);
copyfile([config.codePath config.projectName '.tex'], [config.latexFileName '.tex']);
copyfile([fileparts(mfilename('fullpath')) filesep 'utils/mcode.sty'], [config.reportPath 'tex/']);

config.pdfFileName = [config.reportPath config.projectName '_v' num2str(config.versionName) '_' config.userName  '_' date '_' strrep(config.message, ' ', '-') '.pdf'];

config.latex = LatexCreator([config.latexFileName '.tex'], 1, config.completeName, [config.projectName ' version ' num2str(config.versionName) '\\ ' config.message], config.projectName);

% add table
for k=1:length(config.displayData.latex)
    config.latex.addTable(config.displayData.latex(k).data, 'caption', config.displayData.latex(k).caption, 'multipage', config.displayData.latex(k).multipage, 'landscape', config.displayData.latex(k).landscape, 'label', config.displayData.latex(k).label);
end

% add figure
for k=1:length(config.displayData.figure)
    if config.displayData.figure(k).taken && config.displayData.figure(k).report
        config.latex.addFigure(config.displayData.figure(k).handles, 'caption', config.displayData.figure(k).caption, 'label', config.displayData.figure(k).label);
    end
end

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
            if ~isempty(config.pdfViewer)
                cmd=[config.pdfViewer ' ', config.pdfFileName, ' &'];
            else
                if ismac
                    cmd=['open -a Preview ', config.pdfFileName, ' &'];
                else
                    open(config.pdfFileName);
                    return;
                end
            end
            system(cmd);
    end
end
warning off
rmdir(latexPath, 's');
mkdir(latexPath);
warning on