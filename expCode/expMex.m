function expMex(toolPath, fileName, command, force)

if ~exist('command', 'var')
    command = ['mex(' fileName ')'];
end

if ~exist('force', 'var'), force=0; end

[p f] = fileparts(fileName);

if force || ~exist([toolPath filesep f '.' mexext], 'file')
    initPath = cd(toolPath);
    eval(command);
    cd(initPath);
end