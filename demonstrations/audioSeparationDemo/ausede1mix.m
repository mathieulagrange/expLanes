function [config, store, display] = ausede1mix(config, mode, data)
% ausede1mix MIX step of the expCode project audioSeparationDemo
%    [config, store, display] = ausede1mix(config, mode, data)
%       config : expCode configuration state
%       mode: current set of parameters
%       data   : processing data stored during the previous step
%
%       store  : processing data to be saved for the other steps     
%       display: performance measures to be saved for display

% Copyright Mathieu Lagrange
% Date 14-Nov-2013

if nargin==0, audioSeparationDemo('do', 1, 'mask', {{}}); return; end

disp([config.currentStepName ' ' mode.infoString]);
% no display for this step
display=[];
% propagate source and and noise for the next step
store.source = data.source;
store.noise = data.noise;
% mix the source and the noise at a given snr
mixture = data.source+data.noise./10^(.05*mode.snr);
% store mix for the next step
store.mixture = mixture;


