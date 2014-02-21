function displayData = exposeLatexTable(config, displayData, data, p)

numCell = expNumToCell(data.meanData, data.varData, config.displayDigitPrecision, 1); % TODO being able to remove variance
if p.highlight
    numCell(data.highlights==1) = strcat('\textbf{', numCell(data.highlights==1), '}');
end

dataCell = [strrep(config.step.parameters.list(data.modeSelector, data.parameterSelector), '_', '\_') numCell];

dataCell = expSortData(dataCell, p.sort, data.parameterSelector, config);

displayData.table(end+1).caption = p.caption;
displayData.table(end).multipage = p.multipage;
displayData.table(end).landscape = p.landscape;
displayData.table(end).data = [p.columnNames; dataCell];
displayData.table(end).label = p.label;