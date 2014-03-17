function [config, store, obs] = clde1generateData(config, design, data)

if nargin==0, classificationDemo('do', 1, 'mask', {{}}); return; end

% no obs for this step
obs = [];
% get number of classes
nbClasses = length(expParameterValues(config, 'class'));
% initialize the gmm designl
mix = gmm(design.nbDimensions, design.nbGaussiansInData, 'diag');

samples = [];
class = [];
for k=1:nbClasses
    % set the centres apart for the different classes
    mix.centres = k*design.spread/10+randn(design.nbGaussiansInData, design.nbDimensions);
    % set diagonal covariances randomly
    mix.covar = randn(design.nbGaussiansInData, design.nbDimensions);
    % sample from the gmm designl
    samples = [samples; gmmsamp(mix, design.nbElementsPerClass)];
    % set the ground truth
    class = [class; k*ones(design.nbElementsPerClass, 1)];
end
% obs for better spread control
scatter(samples(:, 1), samples(:, 2), [], class);
% store samples and ground truth for the next step
store.samples = samples;
store.class = class;

