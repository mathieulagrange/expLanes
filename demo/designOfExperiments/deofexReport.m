function config = deofexReport(config)                                 
% deofexReport REPORTING of the expLanes experiment designOfExperiments
%    config = deofexInitReport(config)                                 
%       config : expLanes configuration state                          
                                                                       
% Copyright: Mathieu Lagrange                                          
% Date: 06-Oct-2015                                                    
                                                                       
if nargin==0, designOfExperiments('design', 2, 'report', 'r'); return; end          
                                                                       
config = expExpose(config, 'a', 'design', 2, 'save', 'anova');                                  
