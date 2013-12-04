function [config store] = ausedeInit(config)

if nargin==0, audioSeparationDemo('do', 0); return; end

% set the fft length in samples
config.fftlen = 1024;
% load audio data built in matlab
load handel
if exist('y', 'var')
    % if successful, use it as input data
    config.samplingFrequency = Fs;
    store.source = y/std(y);
else
    % if not, use some recorded audio
    config.samplingFrequency = 8000;
    sourceFileName = 'recordedSpeech.wav';
    if exist(sourceFileName, 'file')
        store.source = wavread(sourceFileName);
    else
        % if not yet recorded
        if ~inputQuestion('Are you ready to record some audio ?')
            % try to record it
            a=audiorecorder(config.samplingFrequency, 16, 1);
            disp('Please speak for two seconds...')
            recordblocking(a, 2);
            store.source = getaudiodata(a);
            disp('Thank you');
            wavwrite(store.source, config.samplingFrequency, sourceFileName);
        else
            error('Unable to load audio data.');
        end
    end
end
% generate perturbation noise
noise = randn(length(y), 1);
% store it for the next tasks
store.noise = noise/std(noise);