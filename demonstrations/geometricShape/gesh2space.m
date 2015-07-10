function [config, store, obs] = gesh2space(config, setting, data)                    
% gesh2space SPACE step of the expLord experiment geometricShape                     
%    [config, store, obs] = gesh2space(config, setting, data)                        
%      - config : expLord configuration state                                        
%      - setting   : set of factors to be evaluated                                  
%      - data   : processing data stored during the previous step                    
%      -- store  : processing data to be saved for the other steps                   
%      -- obs    : observations to be saved for analysis                             
                                                                                     
% Copyright: Mathieu Lagrange                                                        
% Date: 16-Jun-2015                                                                  
                                                                                     
% Set behavior for debug mode                                                        
if nargin==0, geometricShape('do', 2, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                                                                                                      
switch setting.shape
    case 'cube'
       volume = data.baseArea*setting.width; 
    case 'cylinder'
        volume = data.baseArea*setting.height;
    case 'pyramid'
        volume = data.baseArea*setting.height/3;
end

obs.baseArea = data.baseArea;
obs.volume = volume;