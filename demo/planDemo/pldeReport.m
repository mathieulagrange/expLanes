function config = pldeReport(config)                  
% pldeReport REPORTING of the expLanes project planDemo
%    config = pldeReportReport(config)                
%       config : expLanes configuration state          
                                                      
% Copyright lagrange                                  
% Date 07-Jan-2014                                    
                                                      
if nargin==0, planDemo('report', 'r'); return; end      

config = expExpose(config, 'a');