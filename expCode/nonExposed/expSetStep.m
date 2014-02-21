function config = expSetStep(config, step)



% config.design = config.stepDesigns{config.step.id}.design;
% config.designSequence = config.stepDesigns{config.step.id}.sequence;
% config.step.parameters = config.stepDesigns{config.step.id}.parameters; % end
% config.designSet = config.stepDesigns{config.step.id}.set; % end ????
% config.designMaskFilter = config.stepDesigns{config.step.id}.maskFilter;


config.step = config.stepDesigns{step};

% if exist('step', 'var')
%     config.step.id = step;
%     config.step.id = step;
% end
