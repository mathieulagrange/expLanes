function config = expSetTask(config, task)

if exist('task', 'var')
    config.currentTask = task;
end

config.variants = config.taskVariants{config.currentTask}.variants;
config.variantSequence = config.taskVariants{config.currentTask}.sequence;
config.parameters = config.taskVariants{config.currentTask}.parameters; % end
config.variantSet = config.taskVariants{config.currentTask}.set; % end ????