function [store, obs] = expSystem(config, data, lang)

if ~exist('lang', 'var'), lang='python'; end

data.previousObs = [];
fileName = expSave(config, data, 'sys');

switch lang
    case 'python'
        execCommand = ['LD_LIBRARY_PATH="" /usr/bin/python3 python/main.py --expLanes='  fileName '.mat'];
    otherwise
        error('unkown language');
end

if (config.dryMode)
    disp(execCommand);
    obs = [];
    store = [];
else
    if config.attachedMode
        echo = '-echo';
    else
        echo = '-echo';
    end
    [status, cmdout] = system(execCommand, echo);
    
    if (status)
        expLog(config, cmdout);
        fprintf(2, cmdout);
        error(execCommand);
    else
        obs = load([fileName(1:end-4) '_obs']);
        obs.status = status;
        store = load([fileName(1:end-4) '_data']);
    end
end