function name = expGetMachineName(config, id)

name = config.machineNames{floor(id)}{max(1, floor(rem(id, 1)*10))};