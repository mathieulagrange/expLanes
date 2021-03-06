function [config, store] = geshInit(config)                        
% geshInit INITIALIZATION of the expLanes experiment geometricShape 
%    [config, store] = geshInit(config)                            
%      - config : expLanes configuration state                      
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: Mathieu Lagrange                                      
% Date: 16-Jun-2015                                                
                                                                   
if nargin==0, geometricShape(); return; else store=[];  end        
