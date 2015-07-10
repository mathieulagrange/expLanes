function expCreateRootFile(config, experimentName, shortExperimentName, expLordPath)

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
    fileread([expLordPath '/nonExposed/utils/getUserFileName.m'])
    fileread([expLordPath '/nonExposed/expConfigParse.m'])
    fileread([expLordPath '/nonExposed/utils/getUserName.m'])
    fileread([expLordPath '/nonExposed/expDependencies.m'])
    fileread([expLordPath '/nonExposed/expUserDefaultConfig.m'])
    fileread([expLordPath '/nonExposed/utils/expandHomePath.m'])
    });

dlmwrite([config.codePath '/' experimentName '.m'], rootString,'delimiter','');
