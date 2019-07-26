function data = expMerge(data, addition)

if isempty(data)
    data = addition;
else
    if ~isempty(addition)
        fieldNames = fieldnames(data);
        for k=1:length(fieldNames)
            if (isfield(addition, fieldNames{k}))
                data.(fieldNames{k}) = [data.(fieldNames{k}) addition.(fieldNames{k})];
            end
        end
    end
end