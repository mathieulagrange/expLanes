function expCreateStepFile(config, name, rank)

functionName = [config.shortProjectName num2str(rank) name];
functionString = char({...
    ['function [config, store, obs] = ' functionName '(config, setting, data)'];
    ['% ' functionName ' ' upper(name) ' step of the expCode project ' config.projectName];
    ['%    [config, store, obs] = ' functionName '(config, setting, data)'];
    '%      - config : expCode configuration state';
    '%      - setting   : set of factors to be evaluated';
    '%      - data   : processing data stored during the previous step';
    '%      -- store  : processing data to be saved for the other steps ';
    '%      -- obs    : observations to be saved for analysis';
    '';
    ['% Copyright: ' config.completeName];
    ['% Date: ' date()];
    '';
    '% Set behavior for debug mode';
    ['if nargin==0, ' , config.projectName '(''do'', ' num2str(rank) ', ''mask'', {}); return; else store=[]; obs=[]; end'];
   '';
    '% imported data';
   'data';
    });
dlmwrite([config.codePath '/' functionName '.m'], functionString,'delimiter','');