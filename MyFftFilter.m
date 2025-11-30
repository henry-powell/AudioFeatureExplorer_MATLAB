%% fftFilter (EQ)
clear, clc, 

% read file
[x, Fs] = audioread("MyQuotes_Mono.wav");

% frame/overlap
N   = 4096;      % frame length (samples)
hop = 2048;      % hop (samples) -> 50% overlap

% bands and scalars
freqRange1 = [100 250];      % Hz
freqRange2 = [500 4000];     % Hz
magScalars = [1.5 0.7];      % 150% in band1, 7  0% in band2

% run filter
y = fftFilter(x, Fs, N, hop, freqRange1, freqRange2, magScalars);

% plot original and filtered waveforms
t = (0:length(x)-1)/Fs;
t_y = (0:length(y)-1)/Fs;

figure
subplot(2,1,1)
plot(t, x)
title('Original Waveform')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(2,1,2)
plot(t_y, y)
title('Filtered Waveform (After FFT Filter)')
xlabel('Time (s)')
ylabel('Amplitude')

% listen
sound(y, Fs);



%% fftFilter (EQ) function

function y = fftFilter(x, Fs, N, hop, freqRange1, freqRange2, magScalars)
% breaks into sub-frames, FFT per frame, applies 2 band scalars to
% pos/neg bins, IFFT per frame, hann window again, assemble

% column
x = x(:);

% frames
xFrames = framesig(x, N, hop);

% analysis window
w = hann(N);
xFrames = xFrames .* w;

% multi-frame FFT
XFrames = fft(xFrames);

% bin width
binWidth = Fs / N;

% freq->bin (0-based bin numbers)
startBin1 = round(freqRange1(1) / binWidth);
endBin1   = round(freqRange1(2) / binWidth);
startBin2 = round(freqRange2(1) / binWidth);
endBin2   = round(freqRange2(2) / binWidth);

% clamp to legal positive-side range
halfN = floor(N/2);
startBin1 = max(0, min(startBin1, halfN));
endBin1   = max(0, min(endBin1,   halfN));
startBin2 = max(0, min(startBin2, halfN));
endBin2   = max(0, min(endBin2,   halfN));

% enforce start<=end
if endBin1 < startBin1, t = startBin1; startBin1 = endBin1; endBin1 = t; end
if endBin2 < startBin2, t = startBin2; startBin2 = endBin2; endBin2 = t; end

% positive-bin indices (MATLAB is 1-based: bin 0 -> idx 1)
posIdx1 = (startBin1+1):(endBin1+1);
posIdx2 = (startBin2+1):(endBin2+1);

% scale pos/neg bins
for i = 1:size(XFrames, 2)
    % positive
    XFrames(posIdx1, i) = XFrames(posIdx1, i) * magScalars(1);
    XFrames(posIdx2, i) = XFrames(posIdx2, i) * magScalars(2);

    % negative mirrors
    negIdx1 = (N - endBin1) + 1 : (N - startBin1) + 1;
    negIdx2 = (N - endBin2) + 1 : (N - startBin2) + 1;

    XFrames(negIdx1, i) = XFrames(negIdx1, i) * magScalars(1);
    XFrames(negIdx2, i) = XFrames(negIdx2, i) * magScalars(2);
end

% IFFT (real)
yFrames = real(ifft(XFrames));

% synthesis window
yFrames = yFrames .* w;

% overlap-add
y = frameAssembler(yFrames, hop);
end


%% frameSig function

function frames = framesig(x, frameLen, skip)
if frameLen <= 0 || skip < 1
    error('frameLen must be >= 1 and skip must be >= 1.');
end
if isrow(x), x = x.'; end
x = x(:);

nPossible = numel(x) - frameLen;
if nPossible < 0
    frames = zeros(frameLen, 0, 'like', x);
    return
end
numFrames = floor(nPossible/skip) + 1;

frames = zeros(frameLen, numFrames, 'like', x);
for n = 1:numFrames
    startIndex = (n-1)*skip + 1;
    endIndex   = startIndex + frameLen - 1;
    frames(:,n) = x(startIndex:endIndex);
end
end