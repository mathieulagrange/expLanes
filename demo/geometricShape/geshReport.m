function config = geshReport(config)
% geshReport REPORTING of the expLanes experiment geometricShape
%    config = geshInitReport(config)
%       config : expLanes configuration state

% Copyright: Mathieu Lagrange
% Date: 16-Jun-2015

if nargin==0, geometricShape('report', 'r'); return; end

% config = expExpose(config, 't', 'obs', 3, 'mask',  {1 0 1}, 'sort', 1, 'save', 'mtable');
% 
% config = expExpose(config, 'l', 'obs', 3, ...
%     'mask',  {1 0 1}, 'save', 'geol');
% config = expExpose(config, 'b', 'obs', 3, ...
%     'mask',  {1 0 1}, 'save', 'geob', 'orientation', 'h');
% config = expExpose(config, 'x', 'obs', 3, ...
%     'mask',  {1 0 1}, 'save', 'geox', 'orientation', 'h');

config = expExpose(config, 't', 'precision', [3 4], 'percent', [1 3]);