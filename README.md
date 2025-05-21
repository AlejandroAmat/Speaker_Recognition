# PAV - P4: Speaker Recognition and Verification

## Overview

This project implements speaker recognition and verification systems using different speech parameterization techniques. It extracts features from audio signals, trains Gaussian Mixture Models (GMMs), and evaluates speaker recognition and verification performance.

## Feature Extraction

Three parameterization techniques were implemented and compared:

### Linear Prediction Coefficients (LPC)
- Signal processing using SPTK tools
- Implementation pipeline:
  ```
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
  $LPC -l 240 -m $lpc_order > $base.lp
  ```

### Linear Prediction Cepstral Coefficients (LPCC)
- Extension of LPC with cepstral domain transformation
- Implementation pipeline:
  ```
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
  $LPC -l 240 -m $lpc_order | $LPCC -m $lpc_order -M $lpcc_order > $base.lpcc
  ```

### Mel-Frequency Cepstral Coefficients (MFCC)
- Based on human auditory perception
- Implementation pipeline:
  ```
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
  $MFCC -l 240 -m $mfcc_order -n $filter_order -s $fq > $base.mfcc
  ```

## Feature Analysis

### Coefficient Correlation Analysis

Correlation between coefficients 2 and 3 for each parameterization:

|                        | LP   | LPCC | MFCC |
|------------------------|:----:|:----:|:----:|
| ρ[2,3]                 | -0.812152 | 0.257603 | -0.181939 |

Observations:
- LPC coefficients show high correlation (nearly linear relationship)
- LPCC and MFCC coefficients are more dispersed, indicating lower correlation
- MFCC coefficients have a wider range (-20 to 25) compared to LPCC (-1 to 1)
- Lower correlation suggests higher information content, making MFCC more suitable for recognition tasks

### Parameter Selection

Selected parameters based on theoretical considerations:
- LPCC: Order approximately 3/2 of the LP order (P=8 → Q=12)
- MFCC: 15 coefficients with 24 filters, sampling rate of 8kHz

## GMM Training and Visualization

Gaussian Mixture Models were trained to represent speaker characteristics.

![GMM visualization with 99%, 80%, and 50% confidence ellipses](./img/99.png)

## Speaker Recognition Performance

Recognition error rates for each parameterization method:

|              | LP    | LPCC  | MFCC  |
|--------------|:-----:|:-----:|:-----:|
| Error rate   | 11.08% | 1.40% | 0.76% |

MFCC achieved the best performance with only 0.76% error rate, confirming its superiority for speaker recognition tasks.

## Speaker Verification Performance

Verification results using MFCC (best performing parameterization):

| Optimal Threshold | False Alarm Rate | Miss Rate | Detection Cost |
|:-----------------:|:----------------:|:---------:|:--------------:|
| -0.00369533       | 3/1000 = 0.0030  | 13/250 = 0.0520 | 7.9 |

Verification results using LPCC:

| Optimal Threshold | False Alarm Rate | Miss Rate | Detection Cost |
|:-----------------:|:----------------:|:---------:|:--------------:|
| -0.117107544      | 9/1000 = 0.0090  | 21/250 = 0.0840 | 16.5 |

## Team Members

Pau Soler Miras
