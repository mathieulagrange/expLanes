function config = exposeTable(config, data, p)

if isstruct(data)
    numeric=1;
    inputCell = expNumToCell(data.meanData, data.stdData, p.precision, p.put, data.highlights, p.highlightColor);
else
    numeric = 0;
    inputCell = data;
end

if p.noFactor
    dataCell = inputCell;
    p.columnNames = p.columnNames(size(p.rowNames, 2)+1:end);
else
    dataCell = [p.rowNames inputCell];
end

if numeric, dataCell = expSortData(dataCell, p, data.factorSelector, config, data); end % FIXME not done in put=1 ?
if ~isempty(dataCell) && p.number == 1
    dataCell = [cellstr([num2str([1:size(dataCell, 1)]')]) dataCell];
    p.columnNames = [{''} p.columnNames];
end

switch p.put
    case 0
        el = cell(1, length(p.columnNames));
        [el{:}] = deal('---');
        if lower(p.total)=='v'
            e2 = cell(1, length(p.columnNames));
            [e2{:}] = deal('');
            e2{1} = '---';
            config.displayData.cellData = [p.columnNames; el; dataCell(1:end-1, :); e2; dataCell(end, :)];
        else
            config.displayData.cellData = [p.columnNames; el; dataCell];
        end
        if length(p.orientation)>1 && strcmp(p.orientation(2), 'i')
            config.displayData.cellData = config.displayData.cellData';
        end
    case 1
        if p.visible
            p.report=0;
            config = expDisplay(config, p);
            if lower(p.total)=='v'
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
            hTable=uitable('Data', dataCell, 'columnName', p.columnNames, 'fontName','Monospaced', 'fontSize', 12, p.addSpecification{:});
            set(hTable, 'units', get(gcf, 'units'));
            set(hTable, 'position', [margin margin fPos(3:4)-2*margin]); % , 'position', [30 30 600 600]
            
            % adjust size
            jScroll = findjobj(hTable);
            if isempty(jScroll)
                disp('Unable to get java handler for the table. Is the figure docked ?');
            else
                jTable = jScroll.getViewport.getView;
                jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
                
                % make it sortable
                % FIXME wrong with negative values
                jTable.setSortable(true);		% or: set(jtable,'Sortable','on');
                jTable.setAutoResort(true);
                jTable.setMultiColumnSortable(true);
                jTable.setPreserveSelectionsAfterSorting(true);
                
                if numeric && size(data, 1)>700
                    disp('Display warning: sorting from column header may be inaccurate :(');
                end
                if  numeric && any(data.meanData(:)<0)
                    disp('Display warning: sorting from column header as some values are negative.');
                end
            end
        end
    case 2
        if p.noObservation
            allCell = dataCell;
        else
            allCell = [p.columnNames; dataCell];
        end
        allCell = strrep(allCell, '_', '\_');
        allCell = strrep(allCell, '%', '\%');
        config.displayData.cellData = allCell;
        
        if length(p.orientation)>1 && strcmp(p.orientation(2), 'i')
            config.displayData.cellData = config.displayData.cellData';
        end
    case 3
        for k=1:length(p.columnNames)
            if ~isempty(str2num(p.columnNames{k}))
                fieldNames{k} = ['o' p.columnNames{k}];
            else
                fieldNames{k} = p.columnNames{k};
            end
        end
        for k=1:size(dataCell, 1)
            for m=1:size(dataCell, 2)
                sData{k}.(fieldNames{m}) = dataCell{k, m};
            end
        end
        config.displayData.cellData = sData;
end