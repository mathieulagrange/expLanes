function [config, store, obs] = plde1process(config, setting, data)
% plde1process PROCESS step of the expLanes project planDemo         
%    [config, store, obs] = plde1process(config, setting, data)    
%       config : expLanes configuration state                        
%       setting: current set of parameters                             
%       data   : processing data stored during the previous step    
%                                                                   
%       store  : processing data to be saved for the other steps    
%       obs: performance measures to be saved for obs       
                                                                    
% Copyright lagrange                                                
% Date 07-Jan-2014                                                  
                                                                    
if nargin==0, planDemo('do', 1, 'mask', {{}}); return; end          
                                                                    
store=[];                                                           
obs=[]; 

obs.metric = setting.f1*setting.f2+setting.f3+randn(1);