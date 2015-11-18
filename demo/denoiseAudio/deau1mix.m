function [config, store, obs] = deau1mix(config, setting, data)                    
% deau1mix MIX step of the expLanes experiment denoiseAudio                        
%    [config, store, obs] = deau1mix(config, setting, data)                        
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: Mathieu Lagrange                                                      
% Date: 04-Nov-2015                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, denoiseAudio('do', 1, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                   
% propagate source and and noise for the next step
store.source = data.source;
store.noise = data.noise;
% mix the source and the noise at a given snr
mixture = data.source+data.noise./10^(.05*setting.snr);
% store mix for the next step
store.mixture = mixture;                                                                               
