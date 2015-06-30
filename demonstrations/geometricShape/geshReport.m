function config = geshReport(config)
% geshReport REPORTING of the expCode experiment geometricShape
%    config = geshInitReport(config)
%       config : expCode configuration state

% Copyright: Mathieu Lagrange
% Date: 16-Jun-2015

if nargin==0, geometricShape('report', 'rcv', 'reportName', 'mathieu'); return; end

config = expExpose(config, 't', 'obs', 3, 'mask',  {1 0 1}, 'sort', 1);

exposeType = {'l', 'b', 'x'};
for k=1:length(exposeType)
    config = expExpose(config, exposeType{k}, 'obs', 3, ...
        'mask',  {1 0 1});
end