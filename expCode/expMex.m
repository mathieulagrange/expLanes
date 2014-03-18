function expMex(config, toolPath, fileName, command, force)

if ~exist('command', 'var')
    command = ['mex(' fileName ')'];
end

if ~exist('force', 'var'), force=0; end

[p f] = fileparts(fileName);
toolName = [f '.' mexext];

initPath = cd([config.codePath toolPath]);

if  ~exist(toolName, 'file')
    force=1;
else
    toolFile = dir(toolName);
    toolSettingDate = toolFile(1).datenum;
    codeFiles = [dir('*h'); dir('*.cpp'); dir('*.c'); dir('*.c++')];
    if isempty(codeFiles)
        codeModDate = 0;
    else
        codeModDate = max([codeFiles.datenum]);
    end
    if codeModDate>toolSettingDate
        force = 1;
    end
end

if force
    eval(command);
end

cd(initPath);
