function expMex(config, toolPath, fileName, command, force)

if ~exist('command', 'var')
    command = ['mex(' fileName ')'];
end

if ~exist('force', 'var'), force=0; end

[p f] = fileparts(fileName);
toolName = [toolPath filesep f '.' mexext];

initPath = cd([config.codePath toolPath]);

if  ~exist(toolName, 'file')
    force=1;
else
    toolFile = dir(toolName);
    toolModeDate = toolFile.datenum;
    codeFiles = [dir('*h'); dir('*.cpp'); dir('*.c'); dir('*.c++')];
    if isempty(codeFiles)
        codeModDate = 0;
    else
        codeModDate = max([codeFiles.datenum]);
    end
    if codeModDate>toolModeDate
        force = 1;
    end
end

if force
    eval(command);
end

cd(initPath);
