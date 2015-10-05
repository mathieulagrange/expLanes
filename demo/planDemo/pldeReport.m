function config = pldeReport(config)                  
% pldeReport REPORTING of the expLanes project planDemo
%    config = pldeReportReport(config)                
%       config : expLanes configuration state          
                                                      
% Copyright lagrange                                  
% Date 07-Jan-2014                                    
                                                      
if nargin==0, planDemo('design', 2, 'report', 'r'); return; end      

config = expExpose(config, 'a', 'design', 2, 'save', 'anova');