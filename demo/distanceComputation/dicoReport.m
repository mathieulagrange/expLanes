function config = dicoReport(config)                                 
% dicoReport REPORTING of the expLanes experiment distanceComputation
%    config = dicoInitReport(config)                                 
%       config : expLanes configuration state                        
                                                                     
% Copyright: Mathieu Lagrange                                        
% Date: 07-Oct-2015                                                  
                                                                     
if nargin==0, distanceComputation('report', 'rcd'); return; end        
                                                                     
config = expExpose(config, 'table', 'mask', {0 2 7 1}, 'obs', [1 2], 'percent', 0);
config = expExpose(config, 'table', 'mask', {3 0 7 1}, 'obs', [1 2], 'percent', 0);
config = expExpose(config, 'linePlot', 'mask', {3 2 0 1 0 0}, 'obs', 1, 'expand', 'spread');

config = expExpose(config, 'table', 'mask', {3 2 7}, 'obs', [1 2], 'percent', 0);