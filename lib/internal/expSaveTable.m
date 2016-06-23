function expSaveTable(fileName, table)


latex = LatexCreator([fileName(1:end-4), 'Tabular.tex'], 0, '', '', '', 0, 1, 0, 1);

latex.addTable(table.table, 'caption', '', 'multipage', table.multipage, 'landscape', table.landscape, 'label', table.label, 'fontSize', table.fontSize, 'nbFactors', table.nbFactors)


try
    dataset = mat2dataset(table.table(2:end, :));
    dataset.Properties.VarNames = table.table(1, :);
    
    save([fileName(1:end-4) 'Dataset.mat'], 'dataset');
    export(dataset,'File', [fileName(1:end-4) '.csv'],'Delimiter',',');
    try
        export(dataset,'XLSFile', [fileName(1:end-4) '.csv']);
    catch
    end
catch
    table = table.table;
    save([fileName(1:end-4) '.mat'], 'table')
%     fprintf(2, 'Unable to generate Matlab dataset for export.\n');
end

