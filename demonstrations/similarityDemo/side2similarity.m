function [config, store, display] = side2similarity(config, variant, data, display)

if nargin==0, similarityDemo('do', 2, 'mask', {{}}); return; end

if ~config.redo && expDone(config), return; end

disp([config.currentTaskName ' ' variant.infoString]);

store=[];

tic

for k=1:variant.nbRealizations
    obs = data.observations{k};
    if strcmp(variant.similarity, 'seuclidean')
        obs = bsxfun(@rdivide, obs, std(obs));
    end
    if strcmp(variant.similarity, 'cosine')
        obs = bsxfun(@rdivide, obs, sqrt(sum(obs.^2, 2)));
    end
    for m=1:size(obs, 1)
        for n=m:size(obs, 1)
            switch variant.similarity
                case {'euclidean', 'seuclidean'}
                    d(m, n) =  norm(obs(m, :)-obs(n, :));          
                case 'cosine'
                    d(m, n) = 1-sum(obs(m, :).*obs(n, :));
            end
            d(n, m) = d(m, n);
        end
    end
    p = rankingMetrics(d, data.class{k});
    display.map(k) = p.meanAveragePrecision;
end

display.similarityTime = toc;