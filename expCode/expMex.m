function expMex(toolPath, fileName)

[p f] = fileparts(fileName);

if ~exist([toolPath filesep f '.' mexext], 'file')
    initPath = cd(toolPath);
    mex(fileName);
    cd(initPath);
end