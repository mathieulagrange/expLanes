function config = expSetStep(config, step)

if exist('step', 'var')
    config.currentStep = step;
end

config.modes = config.stepModes{config.currentStep}.modes;
config.modeSequence = config.stepModes{config.currentStep}.sequence;
config.parameters = config.stepModes{config.currentStep}.parameters; % end
config.modeSet = config.stepModes{config.currentStep}.set; % end ????