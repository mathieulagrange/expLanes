function config = dideReport(config)                               
% dideReport REPORTING of the expCode project distanceDemonstration
%    config = dideInitReport(config)                               
%       config : expCode configuration state                       
                                                                   
% Copyright: Mathieu Lagrange                                      
% Date: 03-Jul-2014                                                
                                                                   
if nargin==0, distanceDemonstration('report', 'rc'); return; end     

config = expExpose(config, 't', 'mask', {0 2 11 1}, 'obs', [1 2], 'save', 1);

config = expExpose(config, 't', 'mask', {3 0 11 1}, 'obs', [1 2], 'save', 1);

config = expExpose(config, 'p', 'mask', {3 2 0 1 0 0}, 'obs', 1, 'expand', 'spread', 'save', 1);