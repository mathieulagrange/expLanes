function [config, store, obs] = clde4test(config, mode, data)

if nargin==0, classificationDemo('do', 4, 'mask', {{1, 0, 0, 0, 0, 2}}); return; end

disp([config.currentStepName ' ' mode.infoString]);

% no storage for this step
store=[];
% get number of classes
nbClasses = length(expParameterValues(config, 'class'));

switch mode.method
    case 'knn'
        % load the result of step 2 (train)
        config = expLoad(config, [], 2);
        % get model for the knn approach (the training dataset)
        model = config.load.model;
        % load the result of step 1 (generateData)
        config = expLoad(config, [], 1);
        % get testing samples
        samples = config.load.samples;
        % get ground truth
        class = config.load.class.';
        % put ground truth to the netlab format
        classMatrix = netClass(class);
        % initialize the knn
        net = knn(size(model.samples, 2), nbClasses, mode.nbNeighbors, model.samples, classMatrix);
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
% record average accuracy per class
for k=1:nbClasses
    obs.(['accuracy' num2str(k)]) = mean(agreement(class==k));
end
% record average accuracy
obs.accuracy = mean(agreement);
% record information for the obs of the confusion matrix
obs.confusionMatrix.prediction = prediction;
obs.confusionMatrix.class = class;
obs.confusionMatrix.classNames = expParameterValues(config, 'class');

function classMatrix = netClass(class)

nbClasses = length(unique(class));
classMatrix = [];
for k=1:nbClasses
    classVector = zeros(1, nbClasses);
    classVector(k)=1;
    classMatrix = [classMatrix; repmat(classVector, sum(class==k), 1)];
end