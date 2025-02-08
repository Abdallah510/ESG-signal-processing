clc;
clear;
close all;

load('106m.mat');

fs=360;
ecg_signal=val(1,:);
t=(0:length(ecg_signal)-1)/fs;

noiseFreq=50;
noiseAMP=50;
noiseSignal=noiseAMP*sin(2*pi*noiseFreq*t);
noisy_ecg_signal=ecg_signal+noiseSignal;

figure;
subplot(3,1,1);
plot(t,ecg_signal,'b');
xlabel('Time(S)');
ylabel('Amplitude(mV)');
title('Original ECG Signal');
grid on;

subplot(3,1,2);
plot(t,noisy_ecg_signal,'b');
xlabel('Time(S)');
ylabel('Amplitude(mV)');
title('Noisy ECG Signal');
grid on;

len=length(noisy_ecg_signal);
f=(0:len-1)*(fs/len);
noisy_signal_FT=fft(noisy_ecg_signal);

subplot(3,1,3);
plot(f(1:len/2),abs(noisy_signal_FT(1:len/2))/len,'b');
xlabel('Frequency(Hz)');
ylabel('|F(f)|');
title('Amplitude Spectrum of Noisy ECG Signal');
grid on;
%filtering
%notch filter-----------------------------------------------
q=30;
wo=50/(fs/2);
[b,a] = iirnotch(wo,wo/q);
notch_filtered_ecg=filtfilt(b,a,noisy_ecg_signal);
notch_filtered_FT=fft(notch_filtered_ecg);
% RLS Filter------------------------------------------------------
RLS_filtered_ecg = rlsFilt(noisy_ecg_signal, ecg_signal);
RLS_filtered_ecg_FT = fft(RLS_filtered_ecg);
%NLMS filter------------------------------------------------------------
filtered_nlms = nlmsFilter(noisy_ecg_signal, ecg_signal, 32, 0.9);
filtered_nlms_FT = fft(filtered_nlms);
%APA FILTER-------------------------------------------------------
filtered_apa = apaFilter(noisy_ecg_signal, ecg_signal, 50, 1, 0.9);
filtered_apa_FT = fft(filtered_apa);
% Plot Spectrogram and PSD for Noisy and Filtered ECG Signals----------------------
% Parameters
window_length = 300; % Window length for spectrogram
noverlap = window_length / 2; % Overlap for spectrogram
nfft = 500; % Number of FFT points

figure;
subplot(4,1,1);
spectrogram(noisy_ecg_signal, window_length, noverlap, nfft, fs, 'yaxis');
title('Spectrogram of Noisy ECG Signal');
colorbar;
grid on;
subplot(4,1,2);
spectrogram(notch_filtered_ecg, window_length, noverlap, nfft, fs, 'yaxis');
title('Spectrogram of Notch Filtered ECG Signal');
colorbar;
grid on;
subplot(4,1,3);
spectrogram(RLS_filtered_ecg, window_length, noverlap, nfft, fs, 'yaxis');
title('Spectrogram of RLS Filtered ECG Signal');
colorbar;
grid on;
subplot(4,1,4);
spectrogram(filtered_apa, window_length, noverlap, nfft, fs, 'yaxis');
title('Spectrogram of NLMS Filtered ECG Signal');
colorbar;
grid on;

figure;
subplot(5, 1, 1);
pwelch(noisy_ecg_signal, window_length, noverlap, nfft, fs);
title('PSD of Noisy ECG Signal');
xlabel('Frequency (Hz)');
ylabel('P/F.(dB/Hz)');
grid on;
subplot(5, 1, 2);
pwelch(notch_filtered_ecg, window_length, noverlap, nfft, fs);
title('PSD of Notch Filtered ECG Signal');
xlabel('Frequency (Hz)');
ylabel('P/F.(dB/Hz)');
grid on;
subplot(5, 1, 3);
pwelch(RLS_filtered_ecg, window_length, noverlap, nfft, fs);
title('PSD of RLS Filtered ECG Signal');
xlabel('Frequency (Hz)');
ylabel('P/F.(dB/Hz)');
grid on;
subplot(5, 1, 4);
pwelch(filtered_nlms, window_length, noverlap, nfft, fs);
title('PSD of NLMS Filtered ECG Signal');
xlabel('Frequency (Hz)');
ylabel('P/F.(dB/Hz)');
grid on;
subplot(5, 1, 5);
pwelch(filtered_apa, window_length, noverlap, nfft, fs);
title('PSD of APA Filtered ECG Signal');
xlabel('Frequency (Hz)');
ylabel('P/F.(dB/Hz)');
grid on;
% Performance metrics---------------------------------------------
[snr_notch, prd_notch, mse_notch] = performanceMetrics(ecg_signal, notch_filtered_ecg);
[snr_rls, prd_rls, mse_rls] = performanceMetrics(ecg_signal, RLS_filtered_ecg);
[snr_nlms, prd_nlms, mse_nlms] = performanceMetrics(ecg_signal, filtered_nlms);
[snr_APA, prd_APA, mse_APA] = performanceMetrics(ecg_signal, filtered_apa);
fprintf('Notch Filter - SNR: %.2f dB, PRD: %.2f %%, MSE: %.2e\n', snr_notch, prd_notch, mse_notch);
fprintf('RLS Filter - SNR: %.2f dB, PRD: %.2f %%, MSE: %.2e\n', snr_rls, prd_rls, mse_rls);
fprintf('NLMS Filter - SNR: %.2f dB, PRD: %.2f %%, MSE: %.2e\n', snr_nlms, prd_nlms, mse_nlms);
fprintf('APA Filter - SNR: %.2f dB, PRD: %.2f %%, MSE: %.2e\n', snr_APA, prd_APA, mse_APA);
%figures-------------------------------------------------------
figure;
subplot(3,1,1);
plot(t,notch_filtered_ecg,'r');
xlabel('Time(S)');
ylabel('Amplitude(mV)');
title('Notch Filtered ECG');
grid on;
subplot(3,1,2);
plot(t, RLS_filtered_ecg, 'g');
xlabel('Time(S)');
ylabel('Amplitude(mV)');
title('RLS Filtered ECG');
grid on;
subplot(3,1,3);
plot(t, filtered_nlms, 'r');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('NLMS Filtered ECG');
grid on;
figure;
subplot(3,1,1);
plot(f(1:len/2),abs(notch_filtered_FT(1:len/2))/len,'r');
xlabel('Frequency(Hz)');
ylabel('|F(f)|');
title('Amplitude Spectrum of Notch Filtered ECG Signal');
grid on;
subplot(3,1,2);
plot(f(1:len/2), abs(RLS_filtered_ecg_FT(1:len/2)) / len, 'g');
xlabel('Frequency(Hz)');
ylabel('|F(f)|');
title('Amplitude Spectrum of RLS Filtered ECG Signal');
grid on;
subplot(3,1,3);
plot(f(1:len/2), abs(filtered_nlms_FT(1:len/2)) / len, 'r');
xlabel('Frequency (Hz)');
ylabel('|F(f)|');
title('Amplitude Spectrum of NLMS Filtered ECG Signal');
grid on;
figure;
subplot(3,1,1);
plot(t, filtered_apa, 'm');
xlabel('Time(S)');
ylabel('Amplitude(mV)');
title('APA Filtered ECG Signal');
grid on;
subplot(3,1,2);
plot(f(1:len/2), abs(filtered_apa_FT(1:len/2)) / len, 'm');
xlabel('Frequency (Hz)');
ylabel('|F(f)|');
title('Amplitude Spectrum of APA Filtered ECG Signal');
grid on;
subplot(3,1,3);
spectrogram(filtered_apa, window_length, noverlap, nfft, fs, 'yaxis');
title('Spectrogram of APA Filtered ECG Signal');
colorbar;
grid on;
%functions------------------------------------------------------
function filtered_signal = nlmsFilter(noisy_signal, desired_signal, filter_length, step_size)
    num_samples = length(noisy_signal);
    
    % Initialization
    w = zeros(filter_length, 1); % Filter coefficients
    filtered_signal = zeros(1, num_samples);
    
    % Padding for input signal
    noisy_signal = [zeros(1, filter_length - 1), noisy_signal];
    
    for n = 1:num_samples
        x = noisy_signal(n + filter_length - 1:-1:n).'; % Input vector
        e = desired_signal(n) - w' * x; % Error
        mu = step_size / (x' * x + 1e-6); % Normalized step size
        w = w + mu * e * x; % Update coefficients
        filtered_signal(n) = w' * x; % Filtered output
    end
end
function filtered_signal = rlsFilt(noisy_signal, desired_signal)
    % Parameters for RLS
    filter_order = 32; % Number of coefficients
    lambda = 0.99;     % Forgetting factor
    delta = 1e3;       % Initial value for P matrix
    
    % Initialization
    num_samples = length(noisy_signal);
    w = zeros(filter_order, 1); % Filter coefficients
    P = delta * eye(filter_order); % Inverse covariance matrix
    
    % Pad noisy signal for filter length
    noisy_signal = [zeros(1, filter_order - 1), noisy_signal];
    
    % Adaptive filtering
    filtered_signal = zeros(1, num_samples);
    for n = 1:num_samples
        x = noisy_signal(n + filter_order - 1:-1:n).'; % Input vector
        k = (P * x) / (lambda + x' * P * x); % Gain vector
        e = desired_signal(n) - w' * x; % Error
        w = w + k * e; % Update coefficients
        P = (P - k * x' * P) / lambda; % Update inverse covariance
        filtered_signal(n) = w' * x; % Filtered output
    end
end
function [snr_value, prd_value, mse_value] = performanceMetrics(original, filtered)
% SNR Calculation
    signal_power = sum(original.^2);
    noise_power = sum((original - filtered).^2);
    snr_value = 10 * log10(signal_power / noise_power);

    % PRD Calculation
    prd_value = (sqrt(sum((original - filtered).^2)) / sqrt(signal_power)) * 100;

    % MSE Calculation
    mse_value = mean((original - filtered).^2);
end
function filtered_signal = apaFilter(noisy_signal, desired_signal, filter_length, projection_order, step_size)
    num_samples = length(noisy_signal);
    w = zeros(filter_length, 1);
    filtered_signal = zeros(1, num_samples);
    noisy_signal = [zeros(1, filter_length - 1), noisy_signal];
    for n = 1:num_samples
        x = noisy_signal(n + filter_length - 1:-1:n).';
        X = repmat(x, 1, projection_order); % Create projection matrix
        E = desired_signal(n) - w' * X(:, 1); % Compute error
        mu = step_size / (trace(X' * X) + 1e-6);
        w = w + mu * E * X(:, 1); % Update weights
        filtered_signal(n) = w' * X(:, 1);
    end
end