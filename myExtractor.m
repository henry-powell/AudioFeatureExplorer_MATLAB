function [featureData, featureIndices] = myExtractor(~,N, hop)

% audioDatastore
% Initialize the audio datastore
% Create an audio datastore for batch processing
[x, Fs] = audioread("audiofile");

% make sure your signal is mono
x = x(:, 1); % x = makeMono(x);



% Create an audio feature extractor object
aFE = audioFeatureExtractor( ...
    "SampleRate", Fs, ...
    "OverlapLength", N - hop, ...
    "FFTLength", N, ...
    "Window", hann(N, "periodic"), ...
    "linearSpectrum", true, ...
    "zerocrossrate", true, ...
    "shortTimeEnergy", true ...
);  

featureIndices = info(aFE);


%extract the information
featureData = extract (aFE, x);

%transpose the the columns are frames 
featureData = featureData'; 

end

