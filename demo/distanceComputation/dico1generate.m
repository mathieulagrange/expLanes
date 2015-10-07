function [config, store, obs] = dico1generate(config, setting, data)                      
% dico1generate GENERATE step of the expLanes experiment distanceComputation              
%    [config, store, obs] = dico1generate(config, setting, data)                          
%      - config : expLanes configuration state                                            
%      - setting   : set of factors to be evaluated                                       
%      - data   : processing data stored during the previous step                         
%      -- store  : processing data to be saved for the other steps                        
%      -- obs    : observations to be saved for analysis                                  
                                                                                          
% Copyright: Mathieu Lagrange                                                             
% Date: 07-Oct-2015                                                                       
                                                                                          
% Set behavior for debug mode                                                             
if nargin==0, distanceComputation('do', 1, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                          
for k=1:setting.nbRealizations
    elements = [];
    class = [];
    for m=1:setting.nbClasses
        elements = [elements; repmat(m, setting.nbElementsPerClass, setting.nbDimensions)...
            + randn(setting.nbElementsPerClass, setting.nbDimensions)*(setting.spread/100)];
        class = [class; m*ones(setting.nbElementsPerClass, 1)];
    end
    
    if all(setting.infoId(1:3) == [3 1 7]) && k==1
        clf
        scatter(elements(:, 1), elements(:, 2), 50, class, 'filled');
        axis off
        axis tight
        config = expExpose(config, '', 'save', 'scatter');
    end
    
    store.elements{k} =  elements;
    store.class{k} = class;
end