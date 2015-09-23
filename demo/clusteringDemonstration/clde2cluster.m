function [config, store, obs] = clde2cluster(config, setting, data)
% clde2cluster CLUSTER step of the expLanes project clusteringDemo
%    [config, store, obs] = clde2cluster(config, setting, data)
%     - config : expLanes configuration state
%     - setting   : set of factors to be evaluated
%     - data   : processing data stored during the previous step
%     -- store  : processing data to be saved for the other steps
%     -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date 22-Nov-2013

% Set behavior for debug mode
if nargin==0, clusteringDemonstration('do', 2, 'mask', {{1 1 2 3 4}}); return; else store=[]; obs=[]; end

expRandomSeed();

if ~isnan(setting.kernel)
    x = data.elements;
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

for k=1:setting.nbRuns
    switch setting.method
        case 'kMeans'
            opts = statset('MaxIter', setting.nbIterations);
            clusters = kmeans(data.elements, setting.nbClasses, 'replicates', setting.nbReplicates, 'options', opts);
        case 'kernelKmeans'
            for l=1:setting.nbReplicates
                [clusters(l, :), energy(l)] = knkmeans(K, setting.nbClasses, setting.nbIterations);
            end
            [m, ind] = min(sum(energy));
            clusters = clusters(ind, :);
        case 'kMedoids'
            S = squareform(pdist(data.elements, setting.similarity));
            [clusters, energy] = kmedoids(S, setting.nbClasses, setting.nbReplicates, setting.nbIterations);
            [m, ind] = max(sum(energy));
            clusters = clusters(:, ind);
            %     case 'spectral'
            %
            %         D = diag(1 ./ sqrt(sum(K, 2)));
            %         L = D * K * D;
            %
            %         if strcmp(setting.dataType, 'gaussian')
            %             opts.tol = 1e-3;
            %         else
            %             opts.tol = eps;
            %         end
            %         warning('off');
            %         [X, D] = eigs(L, setting.nbClasses, 'lm', opts);
            %         warning('on');
            %         Y = X ./ repmat(sqrt(sum(X.^2, 2)), 1, setting.nbClasses);
            %         opts = statset('MaxIter', setting.nbIterations);
            %         clusters = kmeans(Y, setting.nbClasses, 'replicates', setting.nbRuns, 'options', opts);
        case 'chance'
            clusters = ceil(rand(1, length( data.elements))*length(unique(data.class)));
        otherwise
            error('Unknown method.');
    end
    
    metrics = clusteringMetrics(clusters, data.class);
    obs.accuracy(k) = metrics.accuracy;
    obs.nmi(k) = metrics.nmi;
end

if all(setting.infoId(1:5) == [1 1 2 3 4])
    clf
    scatter(data.elements(:, 1), data.elements(:, 2), 20, clusters, 'filled');
    axis off
    axis tight
    config = expExpose(config, '', 'save', 'clustering');
end