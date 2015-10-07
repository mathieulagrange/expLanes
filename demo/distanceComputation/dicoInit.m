function [config, store] = dicoInit(config)                             
% dicoInit INITIALIZATION of the expLanes experiment distanceComputation
%    [config, store] = dicoInit(config)                                 
%      - config : expLanes configuration state                          
%      -- store  : processing data to be saved for the other steps      
                                                                        
% Copyright: Mathieu Lagrange                                           
% Date: 07-Oct-2015                                                     
                                                                        
if nargin==0, distanceComputation(); return; else store=[];  end        
