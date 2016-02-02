function [config, store] = deauInit(config)
% deauInit INITIALIZATION of the expLanes experiment denoiseAudio
%    [config, store] = deauInit(config)
%      - config : expLanes configuration state
%      -- store  : processing data to be saved for the other steps

% Copyright: Mathieu Lagrange
% Date: 04-Nov-2015

if nargin==0, denoiseAudio(); return; else store=[];  end

% set the fft length in samples
config.fftlen = 1024;
% if not, use some recorded audio
config.samplingFrequency = 8000;

sourceFileName = 'recordedSpeech.wav';
if exist(sourceFileName, 'file')
    store.source = audioread(sourceFileName);
else
    % if not yet recorded
    if inputQuestion('Do you want to record some audio ? (if not, default audio data will be used))')
        % try to record it
        a=audiorecorder(config.samplingFrequency, 16, 1);
        disp('Please speak for two seconds...')
        recordblocking(a, 2);
        store.source = getaudiodata(a);
        disp('Thank you');
        audiowrite(sourceFileName, store.source, config.samplingFrequency);
    else
        % load audio data built in matlab
        load handel
        if exist('y', 'var')
            % if successful, use it as input data
            config.samplingFrequency = Fs;
            store.source = y/(max(abs(y))+.1);
        else
            error('Unable to load handel builtin sound, please record some audio');
        end
        audiowrite(sourceFileName, store.source, config.samplingFrequency);
    end
end

% generate perturbation noise
noise = randn(length(store.source), 1);
% store it for the next steps
store.noise = noise/std(noise);