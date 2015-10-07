function [config, store] = deofexInit(config)                             
% deofexInit INITIALIZATION of the expLanes experiment designOfExperiments
%    [config, store] = deofexInit(config)                                 
%      - config : expLanes configuration state                            
%      -- store  : processing data to be saved for the other steps        
                                                                          
% Copyright: Mathieu Lagrange                                             
% Date: 06-Oct-2015                                                       
                                                                          
if nargin==0, designOfExperiments(); return; else store=[];  end          
