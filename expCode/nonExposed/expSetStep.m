function config = expSetStep(config, step)

if exist('step', 'var')
    config.currentStep = step;
end

config.designs = config.stepDesigns{config.currentStep}.designs;
config.designSequence = config.stepDesigns{config.currentStep}.sequence;
config.parameters = config.stepDesigns{config.currentStep}.parameters; % end
config.designSet = config.stepDesigns{config.currentStep}.set; % end ????