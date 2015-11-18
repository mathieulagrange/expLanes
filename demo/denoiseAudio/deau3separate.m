function [config, store, obs] = deau3separate(config, setting, data)               
% deau3separate SEPARATE step of the expLanes experiment denoiseAudio              
%    [config, store, obs] = deau3separate(config, setting, data)                   
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: Mathieu Lagrange                                                      
% Date: 04-Nov-2015                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, denoiseAudio('do', 3, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                   
% compute spectrograms
sm = computeSpectrogram(data.mixture, config.fftlen, config.samplingFrequency);
SM = abs(sm);
switch setting.method
    case 'ibm'
        % estimate the magnitude spectrogram of the source
        SE = SM.*data.mask;
    case 'nmf'
        % select the most salient components
        nbkept = floor((100-setting.pruning)/100*setting.dictionarySize);
        W = data.W(:, 1:nbkept);
        H = data.H(1:nbkept, :);
        % estimate the magnitude spectrogram of the source
        SE = W*H;
end
% generate estimated spectrogram of the source
se = SE.*exp(1i*angle(sm));
% generate estimated signal of the source
e = ispecgram(se, config.fftlen, config.samplingFrequency, config.fftlen/2, config.fftlen/4);
e = e(1:length(data.source));

% estimate the magnitude spectrogram of the noise
SN=SM-SE;
% generate estimated spectrogram of the noise
sn = SN.*exp(1i*angle(sm));
% generate estimated signal of the noise
en = ispecgram(sn, config.fftlen, config.samplingFrequency, config.fftlen/2, config.fftlen/4);
en = en(1:length(data.source));

% compute signal to (distortion, interference and artefacts) ratios
[sdr sir sar] = bss_eval_sources([e en].',[data.source data.noise].');
% record performance metrics for the isolation of the source
obs.sdr=sdr(1);
obs.sir=sir(1);
obs.sar=sar(1);

% utility function for computing the spectrogram of a given signal
function A = computeSpectrogram(a, fftlen, sr)

fftwin=fftlen/2;
ffthop = fftlen/4;
A = specgram(a,fftlen,sr,fftwin,(fftwin-ffthop));                                                                               
