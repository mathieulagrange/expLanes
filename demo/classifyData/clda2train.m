function [config, store, obs] = clda2train(config, setting, data)                  
% clda2train TRAIN step of the expLanes experiment classifyData                    
%    [config, store, obs] = clda2train(config, setting, data)                      
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: Mathieu Lagrange                                                      
% Date: 04-Nov-2015                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, classifyData('do', 2, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                   

switch setting.method
    case 'knn'
        % no obs for the knn approach
        obs = [];
        % the model for the knn approach is the training dataset
        store.model = data(1);
    case'gmm'
        % no output for gmm training
        options(1)=-1;
        % get training data for the actual class
        trainingData = data(1).samples(data(1).class == setting.class, :);
        % usage of sequential setting
        if isempty(config.sequentialData)
            % first step of the sequential run
            mix = gmm(setting.nbDimensions, setting.nbGaussians, 'diag');
            options(14) = 100;
            % initialize gmm model using kmeans
            mix = gmminit(mix, trainingData, options);
            options(14) = setting.nbIterations;
        else
            % continuing step of the sequential run
            options(14) = setting.nbIterations-config.sequentialData.nbIterations;
            % get model from the sequential data of the previous run
            mix = config.sequentialData.gmm;
        end
        % EM training of the model
        [model options] = gmmem(mix, trainingData, options);
        % record training likelihood
        obs.trainLikelihood = options(8);
        % store model for the next step
        store.model = model;
        % save model and number of iterations already done for the next
        % step of the sequential run
        config.sequentialData.nbIterations = setting.nbIterations;
        config.sequentialData.gmm = model;       
end
                                                                               
