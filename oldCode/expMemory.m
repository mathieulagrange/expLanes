function config = expMemory(config, neededSize)

if isstruct(neededSize)
    neededSize =  getMemory(neededSize);
end

[availableMemory, totalMemory] = vmStatCall(neededSize);


if neededSize>totalMemory
    error('Your memory budget is larger than the physical memory of this host: %d requested for %d available (in double precision)', neededSize, totalMemory);
end

if config.probe && neededSize<availableMemory/8
    suggestedNumberOfCores = ceil(availableMemory/(8*neededSize));
   if config.suggestedNumberOfCores > suggestedNumberOfCores
        config.suggestedNumberOfCores = suggestedNumberOfCores;
   end
   expLog(config, sprintf('Suggested number of cores %d (max %d).\n', suggestedNumberOfCores, config.suggestedNumberOfCores), 0, 1);
end

waitCount=1;
while neededSize>availableMemory/8
    if config.probe
        expLog(config, sprintf('Warning: there may be not enough memory to run task %s on variant %s.\nNeeded: %d Available %d (in double)\n', config.taskName{config.currentTask}, config.currentVariant.infoString, neededSize, availableMemory/8), 2);
        return;
    else
        expLog(config, sprintf('Not enough memory to run task %s on variant %s.\n Needed: %d Available %d (in double)\n Attempting to resume in 1 minute...\n', config.taskName{config.currentTask}, config.currentVariant.infoString, neededSize, availableMemory/8), 2);
        pause(60);
        availableMemory = vmStatCall(neededSize);
        waitCount = waitCount+1;
        if waitCount > 60*6
            % todo sendMail
            s=sprintf('Not enough memory to run task %s on variant %s.\n Needed: %d Available %d (in double)\n', config.taskName{config.currentTask}, config.currentVariant.infoString, neededSize, availableMemory/8);
            error(s);
        end
    end
end

function [availableMemory, totalMemory] = vmStatCall(neededSize)

if isunix
    if ismac
        [null, r1] = system('vm_stat | egrep ''inactive|free|active|wired'' | awk ''{ print $3 }'' | sed ''s/\.//''');
        v=sscanf(r1, '%d\n');
        availableMemory = (v(1)+v(3))*4096;
        [null, r4] = system('vm_stat | grep wired | awk ''{ print $4 }'' | sed ''s/\.//''');
        totalMemory = (sum(v)+str2double(r4))*4096;
    else
        [null, r] = system('vmstat -s -S K | egrep ''inactive|free|total'' | awk ''{ print $1 }'' | sed ''s/\.//''');
        v=sscanf(r, '%d\n');
        availableMemory = (v(2)+v(3))*1024;
        totalMemory = v(1)*1024;
    end
end
