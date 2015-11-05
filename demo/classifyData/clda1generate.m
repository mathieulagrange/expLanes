function [config, store, obs] = clda1generate(config, setting, data)               
% clda1generate GENERATE step of the expLanes experiment classifyData              
%    [config, store, obs] = clda1generate(config, setting, data)                   
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: Mathieu Lagrange                                                      
% Date: 04-Nov-2015                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, classifyData('do', 1, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                   
% get number of classes
nbClasses = length(expFactorValues(config, 'class'));
% initialize the gmm setting
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

% store samples and ground truth for the next step
store.samples = samples;
store.class = class; 

% visualization
clf
scatter(samples(:, 1), samples(:, 2), 20, class, 'filled');
axis off
axis tight
config = expExpose(config, '', 'save', ['scatter' num2str(setting.infoId(3))]);
                                                                            