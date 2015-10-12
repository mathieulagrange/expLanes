function [config, store] = cldaInit(config)                        
% cldaInit INITIALIZATION of the expLanes experiment clusteringData
%    [config, store] = cldaInit(config)                            
%      - config : expLanes configuration state                     
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: Mathieu Lagrange                                      
% Date: 08-Oct-2015                                                
                                                                   
if nargin==0, clusteringData(); return; else store=[];  end        
