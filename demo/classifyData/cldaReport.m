function config = cldaReport(config)                          
% cldaReport REPORTING of the expLanes experiment classifyData
%    config = cldaInitReport(config)                          
%       config : expLanes configuration state                 
                                                              
% Copyright: Mathieu Lagrange                                 
% Date: 04-Nov-2015                                           
                                                              
if nargin==0, classifyData('report', 'r'); return; end        
                                                              
config = expExpose(config, 'p', 'mask', {2 0 2 0 5 0}, 'obs', 1, 'expand', 4);  

% config = expExpose(config, 'confusionMatrix', 'mask', {2 0 2 4 5 0});  
