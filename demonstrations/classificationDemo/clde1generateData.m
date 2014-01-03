function [config, store, display] = clde1generateData(config, mode, data)

if nargin==0, classificationDemo('do', 1, 'mask', {{}}); return; end

disp([config.currentStepName ' ' mode.infoString]);

% no display for this step
display = [];
% get number of classes
nbClasses = length(expParameterValues(config, 'class'));
% initialize the gmm model
mix = gmm(mode.nbDimensions, mode.nbGaussiansInData, 'diag');

samples = [];
class = [];
for k=1:nbClasses
    % set the centres apart for the different classes
    mix.centres = k*mode.spread/10+randn(mode.nbGaussiansInData, mode.nbDimensions);
    % set diagonal covariances randomly
    mix.covar = randn(mode.nbGaussiansInData, mode.nbDimensions);
    % sample from the gmm model
    samples = [samples; gmmsamp(mix, mode.nbElementsPerClass)];
    % set the ground truth
    class = [class; k*ones(mode.nbElementsPerClass, 1)];
end
% display for better spread control
scatter(samples(:, 1), samples(:, 2), [], class);
% store samples and ground truth for the next step
store.samples = samples;
store.class = class;

