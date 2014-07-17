function config = exposeTable(config, data, p)

if isstruct(data)
    numeric=1;
   inputCell = expNumToCell(data.meanData, data.varData, config.tableDigitPrecision, p.put, data.highlights);
else
    numeric = 0;
    inputCell = data;
end
    
switch p.put
    case 0
        dataCell = [p.rowNames inputCell]; % config.step.factors.list(data.settingSelector, data.factorSelector)
        if numeric, dataCell = expSortData(dataCell, p, data.factorSelector, config); end
        el = cell(1, length(p.columnNames));
        [el{:}] = deal('---');
        if p.total
            e2 = cell(1, length(p.columnNames));
            [e2{:}] = deal('');
            e2{1} = '---';
            config.displayData.cellData = [p.columnNames; el; dataCell(1:end-1, :); e2; dataCell(end, :)];
        else
            config.displayData.cellData = [p.columnNames; el; dataCell];
        end
    case 1
        p.report=0;
        config = expDisplay(config, p);
        dataCell = [p.rowNames inputCell];
        if numeric, dataCell = expSortData(dataCell, p, data.factorSelector, config); end
        if p.total
            el = cell(1, length(p.columnNames));
            [el{:}] = deal('');
            dataCell = [dataCell(1:end-1, :); el;  dataCell(end, :)];
        end
        
        if ~feature('ShowFigureWindows'), return; end
        
        fPos = get(gcf, 'position');
        margin = fPos(4)/20;
        
        clf
        if size(p.columnNames, 1)>1
            dataCell = [p.columnNames(2, :); dataCell];
            p.columnNames = p.columnNames(1, :);
        end
        if ~isempty(p.addSpecification)
            hTable=uitable('Data', dataCell, 'columnName', p.columnNames, 'fontName','courier', 'fontSize', 14, p.addSpecification{:});
        else
            hTable=uitable('Data', dataCell, 'columnName', p.columnNames, 'fontName','courier', 'fontSize', 14);
        end
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
            
            if numeric && (size(data, 1)>700 || any(data.meanData(:)<0))
                disp('Display warning: sorting from column header may be inaccurate :(');
            end
        end
    case 2
        dataCell = [p.rowNames inputCell];
        if numeric, dataCell = expSortData(dataCell, p, data.factorSelector, config); end
        allCell = [p.columnNames; dataCell];
        allCell = strrep(allCell, '_', '\_');
        allCell = strrep(allCell, '%', '\%');
        config.displayData.cellData = allCell;
end