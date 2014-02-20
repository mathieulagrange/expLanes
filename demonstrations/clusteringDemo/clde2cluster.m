function [config, store, obs] = clde2cluster(config, design, data)
% clde2cluster CLUSTER step of the expCode project clusteringDemo
%    [config, store, obs] = clde2cluster(config, design, data)
%       config : expCode configuration state
%       design: current set of parameters
%       data   : processing data stored during the previous step
%
%       store  : processing data to be saved for the other steps
%       obs: performance measures to be saved for obs

% Copyright lagrange
% Date 22-Nov-2013

if nargin==0, clusteringDemo('do', 2, 'mask', {{1, 3, 0, 3, 0, 0, 0, 0, 10}}); return; end

disp([config.currentStepName ' ' design.infoString]);

store=[];
obs=[];

if ~isnan(design.kernel)
    x = data.samples;
    switch design.kernel
        case 'linear'
            K = x*x';
        case 'polynomial'
            K = (x*x')^2;
        case 'exponential'
%             sigma = .1;
            S1S2 = -2 * (x * x');
            SS = sum(x.^2,2);
            K = exp(- (S1S2 + repmat(SS, 1, length(SS)) + repmat(SS', length(SS), 1)) / (2 * design.sigma^2));
        otherwise
            error('Unknown kernel.');
    end
end

switch design.method
    case 'kMeans'
        opts = statset('MaxIter', design.nbIterations);
        clusters = kmeans(data.samples, design.nbClasses, 'replicates', design.nbRuns, 'options', opts);
    case 'kernelKmeans'
        
        for k=1:design.nbRuns
            [clusters(k, :) energy(k)] = knkmeans(K, design.nbClasses, design.nbIterations);
        end
        [m, ind] = min(sum(energy));
        clusters = clusters(ind, :);
    case 'kMedoids'
        S = squareform(pdist(data.samples, design.similarity));
        [clusters energy] = kmedoids(S, design.nbClasses, design.nbRuns, design.nbIterations);
        [m, ind] = max(sum(energy));
        clusters = clusters(:, ind);
    case 'spectral'
        
        D = diag(1 ./ sqrt(sum(K, 2)));
        L = D * K * D;
        
        if strcmp(design.dataType, 'gaussian')
            opts.tol = 1e-3;
        else
            opts.tol = eps;
        end
        warning('off');
        [X, D] = eigs(L, design.nbClasses, 'lm', opts);
        warning('on');
        Y = X ./ repmat(sqrt(sum(X.^2, 2)), 1, design.nbClasses);
        opts = statset('MaxIter', design.nbIterations);
        clusters = kmeans(Y, design.nbClasses, 'replicates', design.nbRuns, 'options', opts);
        
    otherwise
        error('Unknown method.');
end



obs.nmi = nmi(clusters, data.class);

% figure();
scatter(data.samples(:, 1), data.samples(:, 2), 20, clusters, 'filled')