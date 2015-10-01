function expMex(config, mexPath, fileName, command, force)
% expMex handle the compilation of mex files
%   expMex(config, mexPath, fileName, command, force)
%   - config: expLanes configuration
%   - mexPath: path of the directory containing the source code files
%   - fileName: name of the source file
%   - command: name of the compilation script (optional)
%   - force: force compilation
%       0: compile only if the source files in the mexPath directory are
%       more recent (default)
%       1: compile anyway

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.

if ~exist('command', 'var')
    command = ['mex ' fileName];
end

if ~exist('force', 'var'), force=0; end

[p, f] = fileparts(fileName);
toolName = [f '.' mexext];

if exist([config.codePath mexPath], 'dir')
    initPath = cd([config.codePath mexPath]);
    
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
end
