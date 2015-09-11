function [config, store, obs] = clde4test(config, setting, data)

if nargin==0, classificationDemo('do', 4, 'mask', {{1, 0, 0, 0, 0, 2}}); return; end

% no storage for this step
store=[];
% get number of classes
nbClasses = length(expFactorValues(config, 'class'));

switch setting.method
    case 'knn'
        % load the result of step 2 (train)
        config = expLoad(config, [], 2);
        % get settingl for the knn approach (the training dataset)
        settingl = config.load.settingl;
        % load the result of step 1 (generateData)
        config = expLoad(config, [], 1);
        % get testing samples
        samples = config.load.samples;
        % get ground truth
        class = config.load.class.';
        % put ground truth to the netlab format
        classMatrix = netClass(class);
        % initialize the knn
        net = knn(size(settingl.samples, 2), nbClasses, setting.nbNeighbors, settingl.samples, classMatrix);
        % get the prediction from the knn over the testing data
        [nn prediction] = knnfwd(net, samples);
        prediction = prediction.';
    case'gmm'
        % get the likelihhod of the different settingls
        for k=1:nbClasses
            likelihood(k, :) = data(k).likelihood;
        end
        % select the settingl with the highest likelihood
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
obs.confusionMatrix.classNames = expFactorValues(config, 'class');

function classMatrix = netClass(class)

nbClasses = length(unique(class));
classMatrix = [];
for k=1:nbClasses
    classVector = zeros(1, nbClasses);
    classVector(k)=1;
    classMatrix = [classMatrix; repmat(classVector, sum(class==k), 1)];
end
