function expSaveTable(fileName, table)

latex = LatexCreator(fileName, 1, '', '', '', 0, 1);

latex.addTable(table.data, 'caption', table.caption, 'multipage', table.multipage, 'landscape', table.landscape, 'label', table.label)