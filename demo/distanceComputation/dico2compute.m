function [config, store, obs] = dico2compute(config, setting, data)                       
% dico2compute COMPUTE step of the expLanes experiment distanceComputation                
%    [config, store, obs] = dico2compute(config, setting, data)                           
%      - config : expLanes configuration state                                            
%      - setting   : set of factors to be evaluated                                       
%      - data   : processing data stored during the previous step                         
%      -- store  : processing data to be saved for the other steps                        
%      -- obs    : observations to be saved for analysis                                  
                                                                                          
% Copyright: Mathieu Lagrange                                                             
% Date: 07-Oct-2015                                                                       
                                                                                          
% Set behavior for debug mode                                                             
if nargin==0, distanceComputation('do', 2, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                          
for k=1:setting.nbRealizations
    elts = data.elements{k};
    if strcmp(setting.distance, 'seuclidean')
        elts = bsxfun(@rdivide, elts, std(elts));
    end
    if strcmp(setting.distance, 'cosine')
        elts = bsxfun(@rdivide, elts, sqrt(sum(elts.^2, 2)));
    end
    for m=1:size(elts, 1)
        for n=m:size(elts, 1)
            switch setting.distance
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
    obs.precision(k) = p.precisionAt5;
end                                                                                    
