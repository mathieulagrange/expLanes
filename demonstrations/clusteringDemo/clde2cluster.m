function [config, store, obs] = clde2cluster(config, setting, data)
% clde2cluster CLUSTER step of the expCode project clusteringDemo
%    [config, store, obs] = clde2cluster(config, setting, data)
%       config : expCode configuration state
%       setting: current set of parameters
%       data   : processing data stored during the previous step
%
%       store  : processing data to be saved for the other steps
%       obs: performance measures to be saved for obs

% Copyright lagrange
% Date 22-Nov-2013

if nargin==0, clusteringDemo('do', 2, 'mask', {{1, 3, 0, 3, 0, 0, 0, 0, 10}}); return; end

store=[];
obs=[];

if ~isnan(setting.kernel)
    x = data.samples;
    switch setting.kernel
        case 'linear'
            K = x*x';
        case 'polynomial'
            K = (x*x')^2;
        case 'exponential'
%             sigma = .1;
            S1S2 = -2 * (x * x');
            SS = sum(x.^2,2);
            K = exp(- (S1S2 + repmat(SS, 1, length(SS)) + repmat(SS', length(SS), 1)) / (2 * setting.sigma^2));
        otherwise
            error('Unknown kernel.');
    end
end

switch setting.method
    case 'kMeans'
        opts = statset('MaxIter', setting.nbIterations);
        clusters = kmeans(data.samples, setting.nbClasses, 'replicates', setting.nbRuns, 'options', opts);
    case 'kernelKmeans'
        
        for k=1:setting.nbRuns
            [clusters(k, :) energy(k)] = knkmeans(K, setting.nbClasses, setting.nbIterations);
        end
        [m, ind] = min(sum(energy));
        clusters = clusters(ind, :);
    case 'kMedoids'
        S = squareform(pdist(data.samples, setting.similarity));
        [clusters energy] = kmedoids(S, setting.nbClasses, setting.nbRuns, setting.nbIterations);
        [m, ind] = max(sum(energy));
        clusters = clusters(:, ind);
    case 'spectral'
        
        D = diag(1 ./ sqrt(sum(K, 2)));
        L = D * K * D;
        
        if strcmp(setting.dataType, 'gaussian')
            opts.tol = 1e-3;
        else
            opts.tol = eps;
        end
        warning('off');
        [X, D] = eigs(L, setting.nbClasses, 'lm', opts);
        warning('on');
        Y = X ./ repmat(sqrt(sum(X.^2, 2)), 1, setting.nbClasses);
        opts = statset('MaxIter', setting.nbIterations);
        clusters = kmeans(Y, setting.nbClasses, 'replicates', setting.nbRuns, 'options', opts);
        
    otherwise
        error('Unknown method.');
end



obs.nmi = nmi(clusters, data.class);

% figure();
scatter(data.samples(:, 1), data.samples(:, 2), 20, clusters, 'filled')