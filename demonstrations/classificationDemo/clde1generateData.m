function [config, store, display] = clde1generateData(config, variant, data)

if nargin==0, classificationDemo('do', 1, 'mask', {{}}); return; end

disp([config.currentStepName ' ' variant.infoString]);

% no display for this step
display = [];
% get number of classes
nbClasses = length(expParameterValues(config, 'class'));
% initialize the gmm model
mix = gmm(variant.nbDimensions, variant.nbGaussiansInData, 'diag');

samples = [];
class = [];
for k=1:nbClasses
    % set the centres apart for the different classes
    mix.centres = k*variant.spread/10+randn(variant.nbGaussiansInData, variant.nbDimensions);
    % set diagonal covariances randomly
    mix.covar = randn(variant.nbGaussiansInData, variant.nbDimensions);
    % sample from the gmm model
    samples = [samples; gmmsamp(mix, variant.nbElementsPerClass)];
    % set the ground truth
    class = [class; k*ones(variant.nbElementsPerClass, 1)];
end
% display for better spread control
scatter(samples(:, 1), samples(:, 2), [], class);
% store samples and ground truth for the next step
store.samples = samples;
store.class = class;

