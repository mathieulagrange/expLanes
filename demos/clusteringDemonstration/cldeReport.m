function config = cldeReport(config)
% cldeReport REPORTING of the expLanes project clusteringDemo
%    config = cldeReportReport(config)
%       config : expLanes configuration state

% Copyright lagrange
% Date 22-Nov-2013  

if nargin==0, clusteringDemonstration('report', 'rcv'); return; end

for k=length(expFactorValues(config, 'dataType')):-1:1
    config=expExpose(config, 't', 'mask', {k 1}, 'obs', [1 2], ...
        'fontSize', 'small', 'percent', 0, 'variance', 1);
end

config=expExpose(config, 't', 'obs', 3, 'integrate', [1 2 4 5 6], 'highlight', -1, 'sort', 1, ...
    'caption', 'Execution time in seconds');


