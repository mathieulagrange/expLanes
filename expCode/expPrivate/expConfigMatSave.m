function expConfigMatSave(fileName, config)

if exist(fileName, 'file')
    delete(fileName);
end

if nargin>1
    save(fileName, 'config');
end