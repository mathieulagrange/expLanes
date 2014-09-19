function [config, store, obs] = clde2train(config, setting, data)

if nargin==0, classificationDemo('do', 2, 'mask', {{1}}); return; end

switch setting.method
    case 'knn'
        % no obs for the knn approach
        obs = [];
        % the settingl for the knn approach is the training dataset
        store.settingl = data(1);
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
            % initialize gmm settingl using kmeans
            mix = gmminit(mix, trainingData, options);
            options(14) = setting.nbIterations;
        else
            % continuing step of the sequential run
            options(14) = setting.nbIterations-config.sequentialData.nbIterations;
            % get settingl from the sequential data of the previous run
            mix = config.sequentialData.gmm;
        end
        % EM training of the settingl
        [settingl options] = gmmem(mix, trainingData, options);
        % record training likelihood
        obs.trainLikelihood = options(8);
        % store settingl for the next step
        store.settingl = settingl;
        % save settingl and number of iterations already done for the next
        % step of the sequential run
        config.sequentialData.nbIterations = setting.nbIterations;
        config.sequentialData.gmm = settingl;       
end


