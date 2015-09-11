function [config, store] = dideInit(config)                           
% dideInit INITIALIZATION of the expLanes project distanceDemonstration
%    [config, store] = dideInit(config)                               
%      - config : expLanes configuration state                         
%      -- store  : processing data to be saved for the other steps    
                                                                      
% Copyright: Mathieu Lagrange                                         
% Date: 03-Jul-2014                                                   
                                                                      
if nargin==0, distanceDemonstration(); return; end                    
store=[];                                                             
