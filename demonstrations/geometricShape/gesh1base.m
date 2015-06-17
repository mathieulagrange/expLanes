function [config, store, obs] = gesh1base(config, setting, data)
% gesh1base BASE step of the expCode experiment geometricShape
%    [config, store, obs] = gesh1base(config, setting, data)
%      - config : expCode configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 16-Jun-2015

% Set behavior for debug mode
if nargin==0, geometricShape('do', 1, 'mask', {}); return; else store=[]; obs=[]; end

uncertainty = randn(1, 100);
switch setting.shape
    case 'cylinder'
        baseArea = (pi+uncertainty)*setting.radius^2;
    otherwise
        baseArea  = setting.width^2;
end
store.baseArea = baseArea;
obs.area = baseArea;