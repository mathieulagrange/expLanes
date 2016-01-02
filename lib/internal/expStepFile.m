function functionString = expStepFile(config, name, rank, write)

if ~exist('write', 'var'), write=1; end

functionName = [config.shortExperimentName num2str(rank) name];
functionString = char({...
    ['function [config, store, obs] = ' functionName '(config, setting, data)'];
    ['% ' functionName ' ' upper(name) ' step of the expLanes experiment ' config.experimentName];
    ['%    [config, store, obs] = ' functionName '(config, setting, data)'];
    '%      - config : expLanes configuration state';
    '%      - setting   : set of factors to be evaluated';
    '%      - data   : processing data stored during the previous step';
    '%      -- store  : processing data to be saved for the other steps ';
    '%      -- obs    : observations to be saved for analysis';
    '';
    ['% Copyright: ' config.completeName];
    ['% Date: ' date()];
    '';
    '% Set behavior for debug mode';
    ['if nargin==0, ' , config.experimentName '(''do'', ' num2str(rank) ', ''mask'', {}); return; else store=[]; obs=[]; end'];
    '';
    });
if write,
    dlmwrite([config.codePath '/' functionName '.m'], functionString,'delimiter','');
end