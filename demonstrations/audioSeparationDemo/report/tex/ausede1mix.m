function [config, store, display] = ausede1mix(config, variant, data)
% ausede1mix MIX task of the expCode project audioSeparationDemo
%    [config, store, display] = ausede1mix(config, variant, data)
%       config : expCode configuration state
%       variant: current set of parameters
%       data   : processing data stored during the previous task
%
%       store  : processing data to be saved for the other tasks     
%       display: performance measures to be saved for display

% Copyright Mathieu Lagrange
% Date 14-Nov-2013

if nargin==0, audioSeparationDemo('do', 1, 'mask', {{}}); return; end

if ~config.redo && expDone(config), return; end

disp([config.currentTaskName ' ' variant.infoString]);
% no display for this task
display=[];
% propagate source and and noise for the next task
store.source = data.source;
store.noise = data.noise;
% mix the source and the noise at a given snr
mixture = data.source+data.noise./10^(.05*variant.snr);
% store mix for the next task
store.mixture = mixture;


