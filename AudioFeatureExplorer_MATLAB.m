%% Audio Feature Extraction 

clear; clc; close all;

%% audio file, N = frame length, hop = sample skip
fileName = "MelodyLoop.wav";   % mono audio file
N        = 4096;               % frame length in samples
hop      = 1024;               % hop size in samples

%% run myExtractor
[featureData, featureIndices] = myExtractor(fileName, N, hop);

%% linear spectrum 
figure
mesh(featureData(featureIndices.linearSpectrum, :))
title('Linear Spectrum')
xlabel('Frame index')
ylabel('Frequency bin')
zlabel('Magnitude')

%% spectral centroid
figure
plot(featureData(featureIndices.spectralCentroid, :))
title('Spectral Centroid')
xlabel('Frame index')
ylabel('Hz')

%% spectral flux
figure
plot(featureData(featureIndices.spectralFlux, :))
title('Spectral Flux')
xlabel('Frame index')
ylabel('Flux')

%% zero-crossing rate
figure
plot(featureData(featureIndices.zerocrossrate, :))
title('Zero-Crossing Rate')
xlabel('Frame index')
ylabel('Rate')

%% short-time energy
figure
plot(featureData(featureIndices.shortTimeEnergy, :))
title('Short-Time Energy')
xlabel('Frame index')
ylabel('Energy')


