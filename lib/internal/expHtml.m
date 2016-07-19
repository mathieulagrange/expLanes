function config = expHtml(config, data, p, exposeType)

currentDisplay = length(config.displayData.table);
if ~isempty(config.displayData.figure)
    currentDisplay  = currentDisplay + sum([config.displayData.figure(:).taken]~=0);
end
% save data in json format
tp=p; tp.put=3;
c = exposeTable(config, data, tp);
table.rows = c.displayData.cellData;
table.cols = p.columnNames;
for k=1:length(p.columnNames)
    if ~isempty(str2num(table.cols{k}))
        table.cols{k} = ['o' table.cols{k}];
    else
        table.cols{k} = table.cols{k};
    end
end
table.p = p;
reportPath = [config.reportPath config.experimentName config.reportName '/'];

if ~exist(reportPath, 'dir')
    mkdir(reportPath);
    mkdir([reportPath '/figures']);
    mkdir([reportPath '/data']);
    copyfile([fileparts(mfilename('fullpath')) filesep 'utils/html'], [reportPath '/internal']);
    movefile([reportPath 'internal/index.html'], reportPath);
    movefile([reportPath 'internal/comments.js'], reportPath);
end

% save data in tex format
tp.put=2;
c = exposeTable(config, data, tp);
c = expDisplay(c, tp);
if ~isempty(c.displayData.table)
    currentTable = c.displayData.table(end);
    
    latex = LatexCreator([reportPath 'data/table' num2str(currentDisplay)  '.tex'], 0, '', '', '', 0, 1, 0, 1);
    latex.addTable(currentTable.table, 'caption', currentTable.caption, 'multipage', currentTable.multipage, 'landscape', currentTable.landscape, 'label', currentTable.label, 'fontSize', currentTable.fontSize, 'nbFactors', currentTable.nbFactors)
    getLatex = latex.get();
    table.tex = getLatex.tex;
    table.caption = currentTable.caption;
    % save data in matlab format
    save([reportPath 'data/table' num2str(currentDisplay) '.mat'], 'data', 'p');
    
    % save figure
    if p.put == 1 && ~strcmp(exposeType, 'exposeTable')
        expSaveFig([reportPath 'figures/' num2str(currentDisplay)], gcf);
        table.figure = [reportPath 'figures/' num2str(currentDisplay) '.png'];
        table.figureType = exposeType;
    else
        table.figure = '';
        table.figureType = '';
    end
    table.sortType = '';
    table.show = 0;
    table.caption = table.caption;
      
    config.html.tables{end+1} = table;  
end

%
% htmlPath = [config.reportPath 'html/'];
% if ~exist(htmlPath, 'dir')
%     mkdir(htmlPath);
% end
%
% reportName = '';
% if ~isempty(config.reportName)
%     reportName = [upper(config.reportName(1)), config.reportName(2:end)];
% end
%
% config.htmlFileName = [config.reportPath config.experimentName reportName '.html'];
%
% text = {['<h1>' config.experimentName reportName ' report </h1>'], ...
%     ['<h2>' config.completeName  '</h2>'], ...
%     ['<h3>' date()  '</h3>'], ...
%     };
%
% if abs(config.showFactorsInReport)
%     pdfFileName = [config.reportPath 'figures/factors.pdf'];
%     a=dir(pdfFileName);
%     b=dir([config.codePath config.shortExperimentName 'Factors.txt']);
%     for k=1:length(config.stepName)
%         c = dir([config.codePath config.shortExperimentName num2str(k) config.stepName{k} '.m']);
%         if c.datenum > b.datenum
%             b=c;
%         end
%     end
%     if ~exist(pdfFileName, 'file')  || a.datenum < b.datenum
%         expFactorDisplay(config, abs(config.showFactorsInReport), config.factorDisplayStyle, isempty(strfind(config.report, 'd')), 0);
%     end
%
%    text{end+1} = '<figure> <img src="figures/factors.png"> <figcaption>Fig.1 flow chart of the experiment.</figcaption> </figure>';
% end
%
% t=1;
% l=1;
% for k=config.displayData.style
%     if k
%         % add table
%         %        config.latex.addTable(config.displayData.table(t).table, 'caption', config.displayData.table(t).caption, 'multipage', config.displayData.table(t).multipage, 'landscape', config.displayData.table(t).landscape, 'label', config.displayData.table(t).label, 'fontSize', config.displayData.table(t).fontSize, 'nbFactors', config.displayData.table(t).nbFactors);
%         t=t+1;
%
%     else
%         % add figure
%         if config.displayData.figure(l).taken && config.displayData.figure(l).report
%             figureFileName = [htmlPath num2str(l)];
%             LocalFig2eps(config.displayData.figure(l).handle, figureFileName);
%             %             config.latex.addFigure(config.displayData.figure(l).handle, 'caption', config.displayData.figure(l).caption, 'label', config.displayData.figure(l).label);
%             text{end+1} = ['<figure> <img src="' figureFileName '.png"> <figcaption>Fig.' num2str(l+1) ' ' config.displayData.figure(l).caption '.</figcaption> </figure>'];
%         end
%         l=l+1;
%     end
% end
%
%
% dlmwrite(config.htmlFileName, char(text),'delimiter','');