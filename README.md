# wl-paper
Code for paper "Weber’s law implies performance limiting slow noise in evidence accumulation"

1. Tested on operating systems: Windows 10 Education, Windows 10, Sonoma 14.5, MacOS 14.5 (23F79).
The code requires Matlab (tested in Matlab versions R2020b, R2021, R2023b).
No non-standard hardware required.

2. Run the modelSimsAndPLOTs_vm_vs.m
Does not require installation, so no install time.

3. Instructions to run on data
At the end of the section of code called "Pick simulation parameters" you will see a line:
% To REPRODUCE plots from the paper
Below this line there are two keys, that can be switched to 0 or 1:
1) keyShowPlotsFromPaper = 1;
You have to set this key to 1 to run the code on data. If set to 0, than only 6 figures for simulations are shown.

2) keyBestFastNoiseModels = 0;
When this key is set to 0 the code will produce the plots for the data (solid lines) and also show the fits of the slow noise model as dotted lines (same model for all participants; for more details see the paper and the Methods section of the paper). The slow noise model is the 4 parameters model: slow noise, bias, 2 history parameters. This is the model shown in Fig.3b,d (denoted with *).
When this key is set to 1 the code will produce the plots for the data (solid lines) and also show the fits of the best fast noise models as dotted lines (different models for participants, whichever structure fit best; for more details see the Methods section of the paper). All 263 fast noise SDE models are shown in Fig.3d in quantitative comparison with the slow noise model. Qualitative comparison of the best ones per each participant and the slow noise model is shown in Fig.3e-h.

Expected output
When keyShowPlotsFromPaper = 0 the output shows 12 plots (grouped in 6 figures), showing data in solid lines and model in dotted lines.

When keyShowPlotsFromPaper = 1 the output shows 24 plots (grouped in 12 figures), showing data in solid lines and model in dotted lines.
The last 6 figures will then reproduce the plots from the paper.

Expected runtime for demo
26 sec

4. Instructions for use 
How to run the software on our data
The same applies as in the section 3 above.

Models are specified by names. All names for 263 stochastic differential equation (SDE) fast noise models are stored in the 'modelNames_263fastSDE' variable. All names for slow-fast noise models are stored in the 'modelNames_sfSbias' variable.

For 263 SDE fast noise models the name of the model lists the augmentation mechanisms present (see Methods), where B stands for boundary, G for gain, L for leakiness or instability, and S stands for history mechanism. The number after the letter gives the order of the polynomial representing the mechanism (see Methods). The history mechanism has a specific form of "S(n_same)x(n_opp)" or "S(n_same)x(n_opp)x(n_else)". The respective parameters are the coefficient of the Legendre polynomials. All 263 SDE fast noise models also include fast sensory noise, fast memory noise and bias as parameters, which are not mentioned in the model name.

For slow-fast noise models the name always says "sfSbias", which means 'slow-fast with history and bias' followed by numbers, where 1 shows the presence of slow noise, 2 stands for the presence of fast accumulator (memory) noise and 3 for fast sensory noise.

The best-fitted parameters are given in 'xbest_263fastSDE' and 'xbest_sfSbias'.

For ease of understanding we created a variable 'listPars', explaining the meaning of each parameter.

By default, the best fit for a chosen model and chosen participant is used.
