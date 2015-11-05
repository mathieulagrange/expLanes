function [config, store, obs] = clda4test(config, setting, data)                   
% clda4test TEST step of the expLanes experiment classifyData                      
%    [config, store, obs] = clda4test(config, setting, data)                       
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: Mathieu Lagrange                                                      
% Date: 04-Nov-2015                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, classifyData('do', 4, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                   
% get number of classes
nbClasses = length(expFactorValues(config, 'class'));

switch setting.method
    case 'knn'
        % load the result of step 2 (train)
        load = expLoad(config, [], 2);
        % get model for the knn approach (the training dataset)
        model = load.model;
        % load the result of step 1 (generateData)
        load = expLoad(config, [], 1);
        % get testing samples
        samples = load.samples;
        % get ground truth
        class = load.class.';
        % put ground truth to the netlab format
        classMatrix = netClass(class);
        % initialize the knn
        net = knn(size(model.samples, 2), nbClasses, setting.nbNeighbors, model.samples, classMatrix);
        % get the prediction from the knn over the testing data
        [nn prediction] = knnfwd(net, samples);
        prediction = prediction.';
    case'gmm'
        % get the likelihhod of the different models
        for k=1:nbClasses
            likelihood(k, :) = data(k).likelihood;
        end
        % select the model with the highest likelihood
        [mh prediction] = max(likelihood);
        class = data(1).class.';
end
% compute agreement
agreement = prediction==class;
% record average accuracy
obs.accuracy = mean(agreement);
% record average accuracy per class
for k=1:nbClasses
    obs.(['accuracy' num2str(k)]) = mean(agreement(class==k));
end
% record information for the display of the confusion matrix
obs.confusionMatrix.prediction = prediction;
obs.confusionMatrix.class = class;
obs.confusionMatrix.classNames = expFactorValues(config, 'class');
obs.confusionMatrix.setting = setting;

function classMatrix = netClass(class)

nbClasses = length(unique(class));
classMatrix = [];
for k=1:nbClasses
    classVector = zeros(1, nbClasses);
    classVector(k)=1;
    classMatrix = [classMatrix; repmat(classVector, sum(class==k), 1)];
end                                                                              
