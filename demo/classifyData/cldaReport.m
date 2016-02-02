function config = cldaReport(config)                          
% cldaReport REPORTING of the expLanes experiment classifyData
%    config = cldaInitReport(config)                          
%       config : expLanes configuration state                 
                                                              
% Copyright: Mathieu Lagrange                                 
% Date: 04-Nov-2015                                           
                                                              
if nargin==0, classifyData('report', 'rcv'); return; end        
                                                              
config = expExpose(config, 'p', 'mask', {2 0 2 0 5 0}, 'obs', 2, 'step', 2, 'expand', 4, 'color', 'k', 'legendLocation', 'best');  

config = expExpose(config, 'p', 'mask', {2 0 2 0 5 0}, 'obs', 1, 'expand', 4);  

config = expExpose(config, 'confusionMatrix', 'mask', {2 0 2 4 5 0}, 'save', 'confusion');  
 
config = expExpose(config, 'p', 'mask', {1}, 'expand', 6, 'obs', 1, 'color', 'k');  

config = expExpose(config, 'b', 'mask', {0 0 2 3 5 5}, 'obs', 1, 'uncertainty', -1);  
