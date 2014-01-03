function [config, store, display] = clde3probe(config, variant, data)

if nargin==0, classificationDemo('do', 3, 'mask', {{2}}); return; end

switch variant.method
    case 'knn'
        % nothing to be done for the knn approach
        store=[];
        display=[];
    case'gmm'
        % load the output of the first step (generate data)
        config = expLoad(config, [], 1);
        % get testing samples
        samples = config.load.samples;
        % get ground truth for testing samples
        class = config.load.class;
        % conpute and store likelihood
        store.likelihood = gmmprob(data.model, samples).';
        % store ground truth
        store.class = class;
        % record likelihood
        display.testLikelihood = mean(store.likelihood);
end