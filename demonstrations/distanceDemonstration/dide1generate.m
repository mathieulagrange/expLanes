function [config, store, obs] = dide1generate(config, setting, data)      
% dide1generate GENERATE step of the expCode project distanceDemonstration
%    [config, store, obs] = dide1generate(config, setting, data)          
%      - config : expCode configuration state                             
%      - setting   : set of factors to be evaluated                       
%      - data   : processing data stored during the previous step         
%      -- store  : processing data to be saved for the other steps        
%      -- obs    : observations to be saved for analysis                  
                                                                          
% Copyright: Mathieu Lagrange                                             
% Date: 03-Jul-2014                                                       
                                                                          
% Set behavior for debug mode.                                            
if nargin==0, distanceDemonstration('do', 1, 'mask', {3 1 11}, 'plot', 1); return; end      
                                                                    
store=[];                                                           
obs=[];                                                             

for k=1:setting.nbRealizations
    elements = [];
    class = [];
    for m=1:setting.nbClasses
        elements = [elements; repmat(m*setting.spread/50, setting.nbElementsPerClass, setting.nbDimensions)...
            + randn(setting.nbElementsPerClass, setting.nbDimensions)];
        class = [class; m*ones(setting.nbElementsPerClass, 1)];
    end
    
    if k==1 && isfield(config, 'plot')
        scatter(elements(:, 1), elements(:, 2), 50, class, 'filled');
        axis off
        axis tight
        config = expExpose(config, '', 'save', 'scatter');
    end
    
    store.elements{k} =  elements;
    store.class{k} = class;
end