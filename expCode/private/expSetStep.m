function config = expSetStep(config, step)

if exist('step', 'var')
    config.currentStep = step;
end

config.variants = config.stepVariants{config.currentStep}.variants;
config.variantSequence = config.stepVariants{config.currentStep}.sequence;
config.parameters = config.stepVariants{config.currentStep}.parameters; % end
config.variantSet = config.stepVariants{config.currentStep}.set; % end ????