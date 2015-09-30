function hTable = expTable(data, columnNames, fPos)

if ~feature('ShowFigureWindows'), return; end

if nargin<3, fPos = get(gcf, 'position'); end
margin = 30;

hTable=uitable('Data', data, 'columnName', columnNames, 'fontName','courier', 'fontSize', 14);
set(hTable, 'position', [margin margin fPos(3:4)-2*margin]); % , 'position', [30 30 600 600]

% adjust size
jScroll = findjobj(hTable);
jTable = jScroll.getViewport.getView;
jTable.setAutoResizeSetting(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

% make it sortable
jTable.setSortable(true);		% or: set(jtable,'Sortable','on');
jTable.setAutoResort(true);
jTable.setMultiColumnSortable(true);
jTable.setPreserveSelectionsAfterSorting(true);