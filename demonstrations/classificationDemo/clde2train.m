function [config, store, obs] = clde2train(config, design, data)

if nargin==0, classificationDemo('do', 2, 'mask', {{1}}); return; end

switch design.method
    case 'knn'
        % no obs for the knn approach
        obs = [];
        % the designl for the knn approach is the training dataset
        store.designl = data(1);
    case'gmm'
        % no output for gmm training
        options(1)=-1;
        % get training data for the actual class
        trainingData = data(1).samples(data(1).class == design.class, :);
        % usage of sequential design
        if isempty(config.sequentialData)
            % first step of the sequential run
            mix = gmm(design.nbDimensions, design.nbGaussians, 'diag');
            options(14) = 100;
            % initialize gmm designl using kmeans
            mix = gmminit(mix, trainingData, options);
            options(14) = design.nbIterations;
        else
            % continuing step of the sequential run
            options(14) = design.nbIterations-config.sequentialData.nbIterations;
            % get designl from the sequential data of the previous run
            mix = config.sequentialData.gmm;
        end
        % EM training of the designl
        [designl options] = gmmem(mix, trainingData, options);
        % record training likelihood
        obs.trainLikelihood = options(8);
        % store designl for the next step
        store.designl = designl;
        % save designl and number of iterations already done for the next
        % step of the sequential run
        config.sequentialData.nbIterations = design.nbIterations;
        config.sequentialData.gmm = designl;       
end


