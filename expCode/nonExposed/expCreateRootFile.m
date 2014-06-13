function expCreateRootFile(config, projectName, shortProjectName, expCodePath)

rootString = char({...
    ['function config = ' projectName '(varargin)'];
    ['% Welcome to the main entry point of ' projectName];
    '% Please DO NOT modify this file unless you have a precise intent.';
    '';
    ['shortProjectName = ''' shortProjectName ''';'];
    '[p projectName] = fileparts(mfilename(''fullpath''));';
    'if nargin>0 && isstruct(varargin{1})';
    ' config = varargin{1};';
    'else';
    ' config = expConfigParse(getUserFileName(shortProjectName, projectName, p));';
    'end';
    '';
    'if ~isempty(config)';
    'expDependencies(config);';
    'config = expRun(p, projectName, shortProjectName, varargin);';
    'end';
    '';
    fileread([expCodePath '/nonExposed/utils/getUserFileName.m'])
    fileread([expCodePath '/nonExposed/expConfigParse.m'])
    fileread([expCodePath '/nonExposed/utils/getUserName.m'])
    fileread([expCodePath '/nonExposed/expDependencies.m'])
    fileread([expCodePath '/nonExposed/expUserDefaultConfig.m'])
    fileread([expCodePath '/nonExposed/utils/expandHomePath.m'])
    });

dlmwrite([config.codePath '/' projectName '.m'], rootString,'delimiter','');
