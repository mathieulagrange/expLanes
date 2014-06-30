function [config, store, obs] = side2similarity(config, setting, data) 
% side2similarity SIMILARITY step of the expCode project similarityDemo
%    [config, store, obs] = side2similarity(config, setting, data)     
%    - config : expCode configuration state                           
%    - setting   : set of factors to be evaluated                     
%    - data   : processing data stored during the previous step                                                                             
%    -- store  : processing data to be saved for the other steps       
%    -- obs    : observations to be saved for analysis                 
                                                                       
% Copyright: Mathieu Lagrange                                          
% Date: 30-Jun-2014                                                    
                                                                       
% Set behavior for debug mode.                                         
if nargin==0, similarityDemo('do', 2, 'mask', {}); return; end         
                                                                       
store=[];                                                              
obs=[];                                                                

for k=1:setting.nbRealizations
    elts = data.elements{k};
    if strcmp(setting.similarity, 'seuclidean')
        elts = bsxfun(@rdivide, elts, std(elts));
    end
    if strcmp(setting.similarity, 'cosine')
        elts = bsxfun(@rdivide, elts, sqrt(sum(elts.^2, 2)));
    end
    for m=1:size(elts, 1)
        for n=m:size(elts, 1)
            switch setting.similarity
                case {'euclidean', 'seuclidean'}
                    d(m, n) =  norm(elts(m, :)-elts(n, :));          
                case 'cosine'
                    d(m, n) = 1-sum(elts(m, :).*elts(n, :));
            end
            d(n, m) = d(m, n);
        end
    end
    p = rankingMetrics(d, data.class{k});
    obs.map(k) = p.meanAveragePrecision;
end

