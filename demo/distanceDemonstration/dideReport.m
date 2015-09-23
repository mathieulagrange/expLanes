function config = dideReport(config)
% dideReport REPORTING of the expLanes project distanceDemonstration
%    config = dideInitReport(config)
%       config : expLanes configuration state

% Copyright: Mathieu Lagrange
% Date: 03-Jul-2014

if nargin==0, distanceDemonstration('report', 'rc'); return; end

config = expExpose(config, 'table', 'mask', {0 2 7 1}, 'obs', [1 2], 'percent', 0);
config = expExpose(config, 'table', 'mask', {3 0 7 1}, 'obs', [1 2], 'percent', 0);
config = expExpose(config, 'linePlot', 'mask', {3 2 0 1 0 0}, 'obs', 1, 'expand', 'spread');

config = expExpose(config, 'table', 'mask', {3 2 7}, 'obs', [1 2], 'percent', 0);
