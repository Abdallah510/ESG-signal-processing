# ECG Power Line Interference Removal — MATLAB

A MATLAB simulation that compares four filtering techniques for removing 50 Hz power line interference from ECG signals, accompanied by a published research paper on the results.

## How It Was Made

Built in MATLAB using the Signal Processing Toolbox. A clean ECG signal from the MIT-BIH Arrhythmia Database (record 106) is loaded and artificially corrupted by adding a 50 Hz sinusoidal noise signal. Four filters are then applied and their outputs are compared across time domain, frequency domain, PSD, and spectrogram visualizations. All three adaptive filters (NLMS, RLS, APA) are implemented from scratch using their respective update equations.

## Filters Compared

- **Notch Filter** — IIR notch at 50 Hz with Q-factor of 30, applied with zero-phase `filtfilt`
- **NLMS** — Normalized Least Mean Square adaptive filter, filter length 32, step size 0.9
- **RLS** — Recursive Least Squares adaptive filter, filter order 32, forgetting factor 0.99
- **APA** — Affine Projection Algorithm, filter length 50, projection order 1, step size 0.9

## Results

| Filter | SNR (dB) | %PRD | MSE |
|---|---|---|---|
| Notch | 30.85 | 2.87 | 6.03 |
| RLS | 30.5 | 2.98 | 6.53 |
| NLMS | 38.3 | 1.22 | 1.09 |
| APA | 38.47 | 1.19 | 1.04 |

The APA filter achieved the best performance across all three metrics.
