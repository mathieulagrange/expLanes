function [config, store] = sideInit(config)                      
% sideInit INITIALIZATION of the expCode project similarityDemo  
%    [config, store] = sideInit(config)                          
%       config : expCode configuration state                     
%                                                                
%       store  : processing data to be saved for the other steps 
                                                                 
% Copyright: Mathieu Lagrange                                    
% Date: 30-Jun-2014                                              
                                                                 
if nargin==0, similarityDemo(); return; end                      
store=[];                                                        
