function config = pldeReport(config)                  
% pldeReport REPORTING of the expLord project planDemo
%    config = pldeReportReport(config)                
%       config : expLord configuration state          
                                                      
% Copyright lagrange                                  
% Date 07-Jan-2014                                    
                                                      
if nargin==0, planDemo('report', 0); return; end      

config = expExpose(config, 'a', 'put', 0);