function [config, store] = brgeshInit(config)                              
% brgeshInit INITIALIZATION of the expLanes experiment branchGeometricShape
%    [config, store] = brgeshInit(config)                                  
%      - config : expLanes configuration state                             
%      -- store  : processing data to be saved for the other steps         
                                                                           
% Copyright: Mathieu Lagrange                                              
% Date: 25-Sep-2015                                                        
                                                                           
if nargin==0, branchGeometricShape(); return; else store=[];  end          
