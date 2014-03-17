function [config, store, obs] = side2similarity(config, design, data, obs)

if nargin==0, similarityDemo('do', 2, 'mask', {{}}); return; end

store=[];
obs=[];

for k=1:design.nbRealizations
    obs = data.observations{k};
    if strcmp(design.similarity, 'seuclidean')
        obs = bsxfun(@rdivide, obs, std(obs));
    end
    if strcmp(design.similarity, 'cosine')
        obs = bsxfun(@rdivide, obs, sqrt(sum(obs.^2, 2)));
    end
    for m=1:size(obs, 1)
        for n=m:size(obs, 1)
            switch design.similarity
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
