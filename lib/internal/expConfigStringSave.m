function expConfigStringSave(config, configFileName)

fid = fopen(configFileName, 'w');
if fid==-1, error(['Unable to reach ' configFileName]); end

configFields = fieldnames(config);
for k=1:length(configFields)
    if ischar(config.(configFields{k}))
        fprintf(fid, '%s = %s\n', configFields{k}, config.(configFields{k}));
    elseif isnumeric(config.(configFields{k}))
        fprintf(fid, '%s = %d\n', configFields{k}, config.(configFields{k}));
    end
end
fclose(fid);