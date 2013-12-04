function displayData = exposeLatexTable(config, displayData, data, p)

numCell = expNumToCell(data.meanData, data.varData, config.displayDigitPrecision, 1); % TODO being able to remove variance
if p.highlight
    numCell(data.highlights==1) = strcat('\textbf{', numCell(data.highlights==1), '}');
end

dataCell = [strrep(config.parameters.list(data.variantSelector, data.parameterSelector), '_', '\_') numCell];

dataCell = expSortData(dataCell, p.sort, data.parameterSelector, config);

displayData.latex(end+1).caption = p.caption;
displayData.latex(end).multipage = p.multipage;
displayData.latex(end).landscape = p.landscape;
displayData.latex(end).data = [p.columnNames; dataCell];
displayData.latex(end).label = p.label;