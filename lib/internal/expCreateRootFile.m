function expCreateRootFile(config, experimentName, shortExperimentName, expLanesPath)

rootString = char({...
    ['function ' experimentName '(varargin)'];
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
    ' expDependencies(config);';
    ' config = expRun(p, experimentName, shortExperimentName, varargin);';
    'end';
    '';
    fileread([expLanesPath '/internal/utils/getUserFileName.m'])
    fileread([expLanesPath '/internal/expConfigParse.m'])
    fileread([expLanesPath '/internal/utils/getUserName.m'])
    fileread([expLanesPath '/internal/expDependencies.m'])
    fileread([expLanesPath '/internal/expUserDefaultConfig.m'])
    fileread([expLanesPath '/internal/utils/expandHomePath.m'])
    });

dlmwrite([config.codePath '/' experimentName '.m'], rootString,'delimiter','');
