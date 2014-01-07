function [config, store, obs] = ausede2model(config, mode, data)

if nargin==0, audioSeparationDemo('do', 2, 'mask', {{2, 5, 1, 1, 5}}, 'obs', '>'); return; end

disp([config.currentStepName ' ' mode.infoString]);

% propagate source, noise and mix for the next step
store=data;
switch mode.method
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
    case 'nnma'
        % compute the spectrogram of the mixture
        sm = computeSpectrogram(data.mixture, config.fftlen, config.samplingFrequency);
        SM = abs(sm);
        % perform model computation
        [n,m]=size(SM);
        if isempty(config.sequentialData)
            % first step of the sequential run
            nbIterations = mode.nbIterations;
            % initialize dictionary and activation matrices
            W=rand(n,mode.dictionarySize);
            H=rand(mode.dictionarySize,m);
        else
            % continuing step of the sequential run
            nbIterations = mode.nbIterations-config.sequentialData.nbIterations;
            % get dictionary and activation matrices from the sequential
            % data of the previous run
            W = config.sequentialData.W;
            H = config.sequentialData.H;
        end
        % perform nnma optimization
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
        config.sequentialData.nbIterations = mode.nbIterations;
        config.sequentialData.W = W;
        config.sequentialData.H = H;        
        % record likelihood
        obs.likelihood = sum(sum((SM-W*H).^2));
end



