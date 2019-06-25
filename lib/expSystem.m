function [store, obs] = expSystem(config, data)

fileName = expSave(config, data);
execCommand = ['LD_LIBRARY_PATH="" /usr/bin/python3 ../../main.py --expLanes='  fileName];
if config.attachedMode
    echo = '-echo';
else
    echo = '';
end
[status, cmdout] = system(execCommand, echo);

if (status)
    expLog(config, cmdout);
    fprintf(2, cmdout);
    error(execCommand);
else
    obs = load([fileName '_obs']);
    obs.status = status;
    store = load([fileName '_data']);
end