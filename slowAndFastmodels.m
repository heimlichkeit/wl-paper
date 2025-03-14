function [pR] = slowAndFastmodels(pulseSeqWeightHist,bias,varsf)

% Simulation parameters
dt = 11/85;

[pR] = get_pRsf_bias_mex(bias,varsf,pulseSeqWeightHist,0,1,dt);
pR = pR';

end