function [config, store, obs] = ausede1mix(config, design, data)
% ausede1mix MIX step of the expCode project audioSeparationDemo
%    [config, store, obs] = ausede1mix(config, design, data)
%       config : expCode configuration state
%       design: current set of parameters
%       data   : processing data stored during the previous step
%
%       store  : processing data to be saved for the other steps     
%       obs: performance measures to be saved for obs

% Copyright Mathieu Lagrange
% Date 14-Nov-2013

if nargin==0, audioSeparationDemo('do', 1, 'mask', {{}}); return; end

% no obs for this step
obs=[];
% propagate source and and noise for the next step
store.source = data.source;
store.noise = data.noise;
% mix the source and the noise at a given snr
mixture = data.source+data.noise./10^(.05*design.snr);
% store mix for the next step
store.mixture = mixture;


