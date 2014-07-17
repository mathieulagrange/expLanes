function expSaveTable(fileName, table)

latex = LatexCreator(fileName, 1, '', '', '', 0, 1);

dataset = mat2dataset(table.table(2:end, :));
dataset.Properties.VarNames = table.table(1, :);

save([fileName(1:end-4) 'Dataset.mat'], 'dataset');
export(dataset,'File', [fileName(1:end-4) '.csv'],'Delimiter',',');
try
    export(hospital,'XLSFile', [fileName(1:end-4) '.csv']);
catch
end

latex.addTable(table.table, 'caption', table.caption, 'multipage', table.multipage, 'landscape', table.landscape, 'label', table.label)