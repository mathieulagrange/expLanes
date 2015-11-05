function [config, store] = cldaInit(config)                        
% cldaInit INITIALIZATION of the expLanes experiment classifyData  
%    [config, store] = cldaInit(config)                            
%      - config : expLanes configuration state                     
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: Mathieu Lagrange                                      
% Date: 04-Nov-2015                                                
                                                                   
if nargin==0, classifyData(); return; else store=[];  end          
