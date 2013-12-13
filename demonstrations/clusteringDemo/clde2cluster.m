function [config, store, display] = clde2cluster(config, variant, data)
% clde2cluster CLUSTER task of the expCode project clusteringDemo
%    [config, store, display] = clde2cluster(config, variant, data)
%       config : expCode configuration state
%       variant: current set of parameters
%       data   : processing data stored during the previous task
%
%       store  : processing data to be saved for the other tasks
%       display: performance measures to be saved for display

% Copyright lagrange
% Date 22-Nov-2013

if nargin==0, clusteringDemo('do', 2, 'mask', {{1, 3, 0, 3, 0, 0, 0, 0, 10}}); return; end

disp([config.currentTaskName ' ' variant.infoString]);

store=[];
display=[];

if ~isnan(variant.kernel)
    x = data.samples;
    switch variant.kernel
        case 'linear'
            K = x*x';
        case 'polynomial'
            K = (x*x')^2;
        case 'exponential'
%             sigma = .1;
            S1S2 = -2 * (x * x');
            SS = sum(x.^2,2);
            K = exp(- (S1S2 + repmat(SS, 1, length(SS)) + repmat(SS', length(SS), 1)) / (2 * variant.sigma^2));
        otherwise
            error('Unknown kernel.');
    end
end

switch variant.method
    case 'kMeans'
        opts = statset('MaxIter', variant.nbIterations);
        clusters = kmeans(data.samples, variant.nbClasses, 'replicates', variant.nbRuns, 'options', opts);
    case 'kernelKmeans'
        
        for k=1:variant.nbRuns
            [clusters(k, :) energy(k)] = knkmeans(K, variant.nbClasses, variant.nbIterations);
        end
        [m, ind] = min(sum(energy));
        clusters = clusters(ind, :);
    case 'kMedoids'
        S = squareform(pdist(data.samples, variant.similarity));
        [clusters energy] = kmedoids(S, variant.nbClasses, variant.nbRuns, variant.nbIterations);
        [m, ind] = max(sum(energy));
        clusters = clusters(:, ind);
    case 'spectral'
        
        D = diag(1 ./ sqrt(sum(K, 2)));
        L = D * K * D;
        
        if strcmp(variant.dataType, 'gaussian')
            opts.tol = 1e-3;
        else
            opts.tol = eps;
        end
        warning('off');
        [X, D] = eigs(L, variant.nbClasses, 'lm', opts);
        warning('on');
        Y = X ./ repmat(sqrt(sum(X.^2, 2)), 1, variant.nbClasses);
        opts = statset('MaxIter', variant.nbIterations);
        clusters = kmeans(Y, variant.nbClasses, 'replicates', variant.nbRuns, 'options', opts);
        
    otherwise
        error('Unknown method.');
end



display.nmi = nmi(clusters, data.class);

% figure();
scatter(data.samples(:, 1), data.samples(:, 2), 20, clusters, 'filled')