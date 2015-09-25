function [config, store, obs] = brgesh1base(config, setting, data)                         
% brgesh1base BASE step of the expLanes experiment branchGeometricShape                    
%    [config, store, obs] = brgesh1base(config, setting, data)                             
%      - config : expLanes configuration state                                             
%      - setting   : set of factors to be evaluated                                        
%      - data   : processing data stored during the previous step                          
%      -- store  : processing data to be saved for the other steps                         
%      -- obs    : observations to be saved for analysis                                   
                                                                                           
% Copyright: Mathieu Lagrange                                                              
% Date: 25-Sep-2015                                                                        
                                                                                           
% Set behavior for debug mode                                                              
if nargin==0, branchGeometricShape('do', 1, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                           
% imported data                                                                            
data                                                                                       
