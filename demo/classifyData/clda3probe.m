function [config, store, obs] = clda3probe(config, setting, data)                  
% clda3probe PROBE step of the expLanes experiment classifyData                    
%    [config, store, obs] = clda3probe(config, setting, data)                      
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: Mathieu Lagrange                                                      
% Date: 04-Nov-2015                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, classifyData('do', 3, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                   
switch setting.method
    case 'knn'
        % nothing to be done for the knn approach
    case'gmm'
        % load the output of the first step (generate data)
        load = expLoad(config, [], 1);
        % get testing samples
        samples = load.samples;
        % get ground truth for testing samples
        class = load.class;
        % conpute and store likelihood
        store.likelihood = gmmprob(data.model, samples).';
        % store ground truth
        store.class = class;
        % record likelihood
        obs.probeLikelihood = mean(store.likelihood);
end                                                                              
