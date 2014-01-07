function [config, store, obs] = side2similarity(config, mode, data, obs)

if nargin==0, similarityDemo('do', 2, 'mask', {{}}); return; end

disp([config.currentStepName ' ' mode.infoString]);

store=[];

tic

for k=1:mode.nbRealizations
    obs = data.observations{k};
    if strcmp(mode.similarity, 'seuclidean')
        obs = bsxfun(@rdivide, obs, std(obs));
    end
    if strcmp(mode.similarity, 'cosine')
        obs = bsxfun(@rdivide, obs, sqrt(sum(obs.^2, 2)));
    end
    for m=1:size(obs, 1)
        for n=m:size(obs, 1)
            switch mode.similarity
                case {'euclidean', 'seuclidean'}
                    d(m, n) =  norm(obs(m, :)-obs(n, :));          
                case 'cosine'
                    d(m, n) = 1-sum(obs(m, :).*obs(n, :));
            end
            d(n, m) = d(m, n);
        end
    end
    p = rankingMetrics(d, data.class{k});
    obs.map(k) = p.meanAveragePrecision;
end

obs.similarityTime = toc;