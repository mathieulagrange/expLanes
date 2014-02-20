function [config, store, obs] = clde3probe(config, design, data)

if nargin==0, classificationDemo('do', 3, 'mask', {{2}}); return; end

switch design.method
    case 'knn'
        % nothing to be done for the knn approach
        store=[];
        obs=[];
    case'gmm'
        % load the output of the first step (generate data)
        config = expLoad(config, [], 1);
        % get testing samples
        samples = config.load.samples;
        % get ground truth for testing samples
        class = config.load.class;
        % conpute and store likelihood
        store.likelihood = gmmprob(data.designl, samples).';
        % store ground truth
        store.class = class;
        % record likelihood
        obs.testLikelihood = mean(store.likelihood);
end