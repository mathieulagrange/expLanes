function [config, store, obs] = deau2model(config, setting, data)                  
% deau2model MODEL step of the expLanes experiment denoiseAudio                    
%    [config, store, obs] = deau2model(config, setting, data)                      
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: Mathieu Lagrange                                                      
% Date: 04-Nov-2015                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, denoiseAudio('do', 2, 'mask', {2 1}); return; else store=[]; obs=[]; end
                                                                                   
% propagate source, noise and mix for the next step
store=data;
switch setting.method
    % Ideal Binary Mask (IBM)
    case 'ibm' % compute the magnitude spectrogram of the source
        SS = abs(computeSpectrogram(data.source, config.fftlen, config.samplingFrequency));
        % compute the magnitude spectrogram of the noise
        SN = abs(computeSpectrogram(data.noise, config.fftlen, config.samplingFrequency));
        % record where the source is dominant in the spectrogram
        store.mask = SN<SS;
        % no obs for this method
        obs = [];
    % Non Negative Matrix Approximation (NNMA)
    case 'nmf'
        % compute the spectrogram of the mixture
        sm = computeSpectrogram(data.mixture, config.fftlen, config.samplingFrequency);
        SM = abs(sm);
        % perform settingl computation
        [n,m]=size(SM);
        if isempty(config.sequentialData)
            % first step of the sequential run
            nbIterations = setting.nbIterations;
            % initialize dictionary and activation matrices
            W=rand(n,setting.dictionarySize);
            H=rand(setting.dictionarySize,m);
        else
            % continuing step of the sequential run
            nbIterations = setting.nbIterations-config.sequentialData.nbIterations;
            % get dictionary and activation matrices from the sequential
            % data of the previous run
            W = config.sequentialData.W;
            H = config.sequentialData.H;
        end
        % perform nmf optimization
        for k=1:nbIterations
            % Euclidean multiplicative updates 
            H = H.*(W'*SM)./((W'*W)*H+eps);
            W = W.*(H*SM')'./(W*(H*H')+eps);
        end
        
        % compute flatness of the dictionary
        flatness = (mean(W)-median(W))./mean(W);
        [null, order] = sort(flatness, 'descend');
        % sort against this measure
        W = W(:, order);
        H = H(order, :);
        % store dictionary and activation matrices for the next step
        store.W = W;
        store.H = H;
        % save dictionary and activation matrices and number of iterations 
        % already done for the next step of the sequential run
        config.sequentialData.nbIterations = setting.nbIterations;
        config.sequentialData.W = W;
        config.sequentialData.H = H;        
        % record spectral signal to reconstruction ratio
        obs.ssrr = log(sum(sum((SM).^2))/sum(sum((SM-W*H).^2)));
end
                                                                               
