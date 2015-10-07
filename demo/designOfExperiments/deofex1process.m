function [config, store, obs] = deofex1process(config, setting, data)                     
% deofex1process PROCESS step of the expLanes experiment designOfExperiments              
%    [config, store, obs] = deofex1process(config, setting, data)                         
%      - config : expLanes configuration state                                            
%      - setting   : set of factors to be evaluated                                       
%      - data   : processing data stored during the previous step                         
%      -- store  : processing data to be saved for the other steps                        
%      -- obs    : observations to be saved for analysis                                  
                                                                                          
% Copyright: Mathieu Lagrange                                                             
% Date: 06-Oct-2015                                                                       
                                                                                          
% Set behavior for debug mode                                                             
if nargin==0, designOfExperiments('do', 1, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                           
obs.metric = setting.f1*setting.f2+setting.f3+randn(1);                                                                                     
