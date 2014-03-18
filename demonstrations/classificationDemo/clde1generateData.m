function [config, store, obs] = clde1generateData(config, setting, data)

if nargin==0, classificationDemo('do', 1, 'mask', {{}}); return; end

% no obs for this step
obs = [];
% get number of classes
nbClasses = length(expParameterValues(config, 'class'));
% initialize the gmm settingl
mix = gmm(setting.nbDimensions, setting.nbGaussiansInData, 'diag');

samples = [];
class = [];
for k=1:nbClasses
    % set the centres apart for the different classes
    mix.centres = k*setting.spread/10+randn(setting.nbGaussiansInData, setting.nbDimensions);
    % set diagonal covariances randomly
    mix.covar = randn(setting.nbGaussiansInData, setting.nbDimensions);
    % sample from the gmm settingl
    samples = [samples; gmmsamp(mix, setting.nbElementsPerClass)];
    % set the ground truth
    class = [class; k*ones(setting.nbElementsPerClass, 1)];
end
% obs for better spread control
scatter(samples(:, 1), samples(:, 2), [], class);
% store samples and ground truth for the next step
store.samples = samples;
store.class = class;

