function expMex(toolPath, fileName)

initPath = cd;

[p f] = fileparts(fileName);

if ~exist([toolPath filesep f '.' mexext], 'file')
    cd(toolPath)
    mex(fileName)
    cd(initPath)
end