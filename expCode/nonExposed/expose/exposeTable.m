function config = exposeTable(config, data, p)

switch p.put
    case 0
        numCell = expNumToCell(data.meanData, data.varData, config.displayDigitPrecision);
        dataCell = [p.rowNames numCell]; % config.step.factors.list(data.settingSelector, data.factorSelector)
        dataCell = expSortData(dataCell, p.sort, data.factorSelector, config);
        el = cell(1, length(p.columnNames));
        [el{:}] = deal('---');
        config.displayData.cellData = [p.columnNames; el; dataCell];
    case 1
        p.report=0;
        config = expDisplay(config, p);
        numCell = expNumToCell(data.meanData, data.varData, config.displayDigitPrecision, 0, data.highlights);
        dataCell = [p.rowNames numCell];
        dataCell = expSortData(dataCell, p.sort, data.factorSelector, config);
        
        
        if ~feature('ShowFigureWindows'), return; end
        
        fPos = get(gcf, 'position');
        margin = fPos(4)/20;
        
        clf
        hTable=uitable('Data', dataCell, 'columnName', p.columnNames, 'fontName','courier', 'fontSize', 14);
        set(hTable, 'units', get(gcf, 'units'));
        set(hTable, 'position', [margin margin fPos(3:4)-2*margin]); % , 'position', [30 30 600 600]
        
        % adjust size
        jScroll = findjobj(hTable);
        if isempty(jScroll)
            disp('Unable to get java handler for the table. Is the figure docked ?');;
        else
            jTable = jScroll.getViewport.getView;
            jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
            
            % make it sortable
            % FIXME wrong with negative values
            jTable.setSortable(true);		% or: set(jtable,'Sortable','on');
            jTable.setAutoResort(true);
            jTable.setMultiColumnSortable(true);
            jTable.setPreserveSelectionsAfterSorting(true);
            
            if size(data, 1)>700 || any(data.meanData(:)<0)
                disp('Display warning: sorting from column header may be inaccurate :(');
            end
        end
    case 2
        numCell = expNumToCell(data.meanData, data.varData, config.displayDigitPrecision, 1, data.highlights); % TODO being able to remove variance
        dataCell = [p.rowNames numCell];
        allCell = [p.columnNames; expSortData(dataCell, p.sort, data.factorSelector, config)];
        allCell = strrep(allCell, '_', '\_');
        allCell = strrep(allCell, '%', '\%');
        config.displayData.cellData = allCell;
end