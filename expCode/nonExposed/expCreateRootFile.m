function expCreateRootFile(config, experimentName, shortExperimentName, expCodePath)

rootString = char({...
    ['function config = ' experimentName '(varargin)'];
    ['% Welcome to the main entry point of ' experimentName];
    '% Please DO NOT modify this file unless you have a precise intent.';
    '';
    ['shortExperimentName = ''' shortExperimentName ''';'];
    '[p, experimentName] = fileparts(mfilename(''fullpath''));';
    'if nargin>0 && isstruct(varargin{1})';
    ' config = varargin{1};';
    'else';
    ' config = expConfigParse(getUserFileName(shortExperimentName, experimentName, p));';
    'end';
    '';
    'if ~isempty(config)';
    'expDependencies(config);';
    'config = expRun(p, experimentName, shortExperimentName, varargin);';
    'end';
    '';
    fileread([expCodePath '/nonExposed/utils/getUserFileName.m'])
    fileread([expCodePath '/nonExposed/expConfigParse.m'])
    fileread([expCodePath '/nonExposed/utils/getUserName.m'])
    fileread([expCodePath '/nonExposed/expDependencies.m'])
    fileread([expCodePath '/nonExposed/expUserDefaultConfig.m'])
    fileread([expCodePath '/nonExposed/utils/expandHomePath.m'])
    });

dlmwrite([config.codePath '/' experimentName '.m'], rootString,'delimiter','');
