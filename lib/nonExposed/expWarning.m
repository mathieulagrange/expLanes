function [fileName, errorStruct]= expWarning(config, id, debugData)

if nargin<2, id=''; end

fileName = [];
errorStruct = [];

if nargin<3, debugData=[]; end

if isempty(id)
    msgStr='';
    msgId='';
else
 [msgStr, msgId] = lastwarn();   
end

if isempty(id) || any(strcmp(msgId, id))
    lastwarn('');
    numId = num2str(ceil(rand(1)*100000000));
    fileName = expSave(config, debugData, ['debugData_' numId]);
    errorStruct.message = ['expLanes catchedWarning: ' msgStr ' \n Debug data may be available at: !scp ' config.hostName ':' fileName ' . \n '];
    errorStruct.identifier = msgId;
end