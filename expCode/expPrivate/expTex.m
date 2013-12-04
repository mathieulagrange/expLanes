function config = expTex(config, command)

if nargin<2, command= 'cv'; end

config.latexFileName = [config.reportPath 'tex/' config.projectName ]; % '.tex'


for k=1:length(config.taskName)
    copyfile([config.codePath config.shortProjectName num2str(k) config.taskName{k} '.m'], [config.reportPath 'tex/' config.shortProjectName num2str(k) config.taskName{k} '.m']);
end
copyfile([config.codePath config.shortProjectName 'Init.m'], [config.reportPath 'tex/' config.shortProjectName 'Init.m']);
copyfile([config.codePath config.shortProjectName 'Report.m'], [config.reportPath 'tex/' config.shortProjectName 'Report.m']);
copyfile([config.codePath config.projectName '.tex'], [config.latexFileName '.tex']);

config.pdfFileName = [config.reportPath config.projectName '_v' num2str(config.versionName) '_' config.userName  '_' date '_' strrep(config.message, ' ', '-') '.pdf'];

config.latex = LatexCreator([config.latexFileName '.tex'], 1, config.completeName, [config.projectName ' version ' num2str(config.versionName) '\\ ' config.message], config.projectName);

% add table
for k=1:length(config.displayData.latex)
    config.latex.addTable(config.displayData.latex(k).data, 'caption', config.displayData.latex(k).caption, 'multipage', config.displayData.latex(k).multipage, 'landscape', config.displayData.latex(k).landscape, 'label', config.displayData.latex(k).label);
end

% add figure
for k=1:length(config.displayData.figureHandles)
    if config.displayData.figureTaken(k)
        config.latex.addFigure(config.displayData.figureHandles(k), 'caption', config.displayData.figureCaption{k}, 'label', config.displayData.figureLabel{k});
    end
end

for k=1:length(command)
    switch command(k)
        case 'c'
            disp('generating latex report. Press x enter if locked for too long (use report=2 for debug info)');
            config.latex.createPDF(~(abs(config.report)-1));
            copyfile([config.latexFileName '.pdf'], config.pdfFileName);
            disp(['report available: ', config.pdfFileName])
        case 'v'
            if ismac
                cmd=['open -a Preview ', config.pdfFileName, ' &'];
            elseif isfield(config, 'pdfViewer')
                cmd=[config.pdfViewer ' ', config.pdfFileName, ' &'];
            else
                disp('Please set a pdfViewer in your config file. For example: pdfViewer = /usr/bin/acroread');
                return;
            end
            system(cmd);
    end
end
