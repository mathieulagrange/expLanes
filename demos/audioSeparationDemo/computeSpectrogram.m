function A = computeSpectrogram(a, fftlen, sr)

fftwin=fftlen/2;
ffthop = fftlen/4;

A = specgram(a,fftlen,sr,fftwin,(fftwin-ffthop));