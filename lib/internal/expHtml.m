function config = expHtml(config)

htmlPath = [config.reportPath 'html/'];
if ~exist(htmlPath, 'dir')
    mkdir(htmlPath);
end

reportName = '';
if ~isempty(config.reportName)
    reportName = [upper(config.reportName(1)), config.reportName(2:end)];
end

config.htmlFileName = [config.reportPath config.experimentName reportName '.html'];

text = {['<h1>' config.experimentName reportName ' report </h1>'], ...
    ['<h2>' config.completeName  '</h2>'], ...
    ['<h3>' date()  '</h3>'], ...
    };

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
    
   text{end+1} = '<figure> <img src="figures/factors.png"> <figcaption>Fig.1 flow chart of the experiment.</figcaption> </figure>';
end

t=1;
l=1;
for k=config.displayData.style
    if k
        % add table
        %        config.latex.addTable(config.displayData.table(t).table, 'caption', config.displayData.table(t).caption, 'multipage', config.displayData.table(t).multipage, 'landscape', config.displayData.table(t).landscape, 'label', config.displayData.table(t).label, 'fontSize', config.displayData.table(t).fontSize, 'nbFactors', config.displayData.table(t).nbFactors);
        t=t+1;
       
    else
        % add figure
        if config.displayData.figure(l).taken && config.displayData.figure(l).report
            figureFileName = [htmlPath num2str(l)];
            LocalFig2eps(config.displayData.figure(l).handle, figureFileName);
            %             config.latex.addFigure(config.displayData.figure(l).handle, 'caption', config.displayData.figure(l).caption, 'label', config.displayData.figure(l).label);
            text{end+1} = ['<figure> <img src="' figureFileName '.png"> <figcaption>Fig.' num2str(l+1) ' ' config.displayData.figure(l).caption '.</figcaption> </figure>'];
        end
        l=l+1;
    end
end


dlmwrite(config.htmlFileName, char(text),'delimiter','');