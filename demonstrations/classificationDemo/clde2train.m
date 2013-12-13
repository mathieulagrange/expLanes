function [config, store, display] = clde2train(config, variant, data)

if nargin==0, classificationDemo('do', 2, 'mask', {{1}}); return; end

switch variant.method
    case 'knn'
        % no display for the knn approach
        display = [];
        % the model for the knn approach is the training dataset
        store.model = data(1);
    case'gmm'
        % no output for gmm training
        options(1)=-1;
        % get training data for the actual class
        trainingData = data(1).samples(data(1).class == variant.class, :);
        % usage of sequential mode
        if isempty(config.sequentialData)
            % first step of the sequential run
            mix = gmm(variant.nbDimensions, variant.nbGaussians, 'diag');
            options(14) = 100;
            % initialize gmm model using kmeans
            mix = gmminit(mix, trainingData, options);
            options(14) = variant.nbIterations;
        else
            % continuing step of the sequential run
            options(14) = variant.nbIterations-config.sequentialData.nbIterations;
            % get model from the sequential data of the previous run
            mix = config.sequentialData.gmm;
        end
        % EM training of the model
        [model options] = gmmem(mix, trainingData, options);
        % record training likelihood
        display.trainLikelihood = options(8);
        % store model for the next task
        store.model = model;
        % save model and number of iterations already done for the next
        % step of the sequential run
        config.sequentialData.nbIterations = variant.nbIterations;
        config.sequentialData.gmm = model;       
end


