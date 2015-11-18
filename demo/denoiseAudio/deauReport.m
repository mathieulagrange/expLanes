function config = deauReport(config)                          
% deauReport REPORTING of the expLanes experiment denoiseAudio
%    config = deauInitReport(config)                          
%       config : expLanes configuration state                 
                                                              
% Copyright: Mathieu Lagrange                                 
% Date: 04-Nov-2015                                           
                                                              
if nargin==0, denoiseAudio('report', 'rcv'); return; end        


% ssrr
config = expExpose(config, 'p', 'mask', {2 5 0 4 8}, 'obs', 1, 'step', 2, 'expand', 3, 'units', {'', 'dB'}, 'tight', 1, 'save', 'ssrr');
% iterations
config = expExpose(config, 'p', 'mask', {2 5 0 4 7}, 'obs', 2, 'expand', 3, 'units', {'', 'dB'}, 'tight', 1, 'save', 'iterations');
% dictionary size vs. pruning
config = expExpose(config, 'p', 'mask', {2 5 10}, 'obs', 2, 'expand', 4, 'units', {'', 'dB'}, 'save', 'versus');
% overall
config = expExpose(config, 'p', 'mask', {0 0 10 4 7}, 'obs', 2, 'expand', 2, 'units', {'dB', 'dB'}, 'tight', 1, 'color', 'k', 'save', 'overall');                              
