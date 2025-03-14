
%% Initialize

clear all
rng(2);

% Speficify the directory containing this file
homedir = pwd;

%% Path

addpath(homedir);
addpath(fullfile(homedir,'mat'));
addpath(fullfile(homedir,'model-free'));
addpath(fullfile(homedir,'crameri'));
addpath(fullfile(homedir,'cbrewer'));


%% Pick simulation parameters

% We implemented a library of evidence-accumulation models, which differ in 
% the mechanisms they implement, the types of noise they implement, and the 
% simulation style (based on analytical or numerical propagation of the variance).
%
% A list of all fast noise models is provided in the file mat\bestFits_263fastSDE.mat,
% which is loaded below. The list is in the variable modelNames_263fastSDE.
% For all slow-fast noise models the full list is in mat\bestFits_sfSbias.mat
% also loaded below. The list is in the variable modelNames_sfSbias.
%
% Below are some of the main models provided in the paper.  

% PICK a model to simulate:
%
% MODEL 1: slow noise model with 4 parameters overall: slow noise
% variance, bias, history coefficients for same and opposite pulses.
% This is the model shown in Fig.3d of the paper (for example), for
% comparison with 263 fast noise SDE models.
% modelName = 'sfSbias1';

% MODEL 2: briefly describe this model
% This is one of the best-fitting 263 SDE fast noise models for quite a few
% participants. It has 11 parameters: bias, memory accumulation fast noise
% variance, initial fast noise variance, sensory fast noise variance, 3 parameters
% for polynomial gain, 2 parameters for polynomial lambda (instability or
% leakiness), history coefficients for same and opposite pulses.
% modelName = 'G2L1S0x0';

% MODEL 3: slow and fast noise model with 6 parameters overall: slow noise
% variance, memory accumulation fast noise variance, sensory fast noise variance,
% history coefficients for same and opposite pulses.
modelName = 'sfSbias123';

% Below we simulate these models based on the parameters obtained by 
% fitting the models to the data from a selected participant.
%
% PICK a participant (1-15):
whichParticipant = 15;
%
% The simulations are based either on the the actual set of stimuli used
% for the chosen participant, or for all participants.
%
% PICK which set of stimuli to use:
whichData = 0; % if 1, use the stimuli from the chosen participant
               % if 0, use the stimuli for all participants
%
% To REPRODUCE plots from the paper
keyShowPlotsFromPaper = 1; % if 1, additional 6 last figures show plots from the paper
                           % if 0, than only 6 figures for simulations are shown
keyBestFastNoiseModels = 0; % if 1, will show plots for best fast noise
                            % models (different models for participants,
                            % whichever structure fit best)
                            % if 0, will show plots for slow noise model (same
                            % model for all participants)


%% Load model parameters

% Model type
if contains(modelName,'sfSbias')
    modelType = 1;
    % models with slow and fast noise
else
    modelType = 0;
    % models with fast noise only
end

% Load parameters (best fit for the participant chosen above)
if modelType == 0 && ~contains(modelName,'sfSbias')
    load([homedir filesep 'mat' filesep 'bestFits_263fastSDE.mat'],...
    'xbest_263fastSDE','modelNames_263fastSDE');
    for im = 1:numel(modelNames_263fastSDE)
        tf = strcmp(char(modelNames_263fastSDE(im)),modelName);
        if tf
            break;
        end
    end
    modelParams = squeeze(xbest_263fastSDE(im,:,whichParticipant));
    jnan = isnan(modelParams);
    modelParams = modelParams(~jnan)';
    modelFcn = @fast263models;
    [bias,sigmas,paramsBGLS,listPars] = getParams_stochasticBGLS_263models(modelParams,modelName,[],[]);
    
elseif modelType == 1 && contains(modelName,'sfSbias')
    load([homedir filesep 'mat' filesep 'bestFits_sfSbias.mat'],...
        'xbest_sfSbias','modelNames_sfSbias');
    for im = 1:numel(modelNames_sfSbias)
        tf = strcmp(char(modelNames_sfSbias(im)),modelName);
        if tf
            break;
        end
    end
    modelParams = squeeze(xbest_sfSbias(im,:,whichParticipant));
    jnan = isnan(modelParams);
    modelParams = modelParams(~jnan)';
    modelFcn = @slowAndFastmodels;
    load(fullfile(homedir,'mat','trialData.mat'),'trialData'); 
    if whichData
        trialData = trialData(trialData.subjectId == whichParticipant,:);
    end
    allMDMS = [zeros(size(trialData.dur)) trialData.pulses];
    [bias,varsf,pulseSeqWeightHist,listPars] = getParams_sfSbias(modelParams,modelName,allMDMS);
else
    
    error('unknown model');

end


%% Load or generate stimuli

if whichData
    
    % LOAD STIMULI from the participant chosen above
    load(fullfile(homedir,'mat','trialData.mat'),'trialData');
    
    trialData = trialData(trialData.subjectId == whichParticipant,:);
    
    allMDMS = [zeros(size(trialData.dur)) trialData.pulses];
    allMD   = sign(allMDMS);
    allMS   = trialData.MS;
    
    % Net motion direction
    netMD = nansum(allMD,2);
    
    % Durations
    allDur = trialData.dur;
    
else
    
    % LOAD STIMULI from all participants
    load(fullfile(homedir,'mat','trialData.mat'),'trialData');
    
    allMDMS = [zeros(size(trialData.dur)) trialData.pulses];
    allMD   = sign(allMDMS);
    allMS   = trialData.MS;
    
    % Net motion direction
    netMD = nansum(allMD,2);
    
    % Durations
    allDur = trialData.dur;
    
end


%% Simulate the model
% The model output is the probability of choosing rightward for any given
% stimulus (i.e. motion sequence)


% Initialize
    
if  modelType == 0 && ~contains(modelName,'sfSbias')
    
    [pR] = fast263models(allMDMS,paramsBGLS,sigmas,bias);
    
elseif modelType == 1 && contains(modelName,'sfSbias')
    
    [pR] = slowAndFastmodels(pulseSeqWeightHist,bias,varsf);
    
else
    
    error('unknown model');
    
end


% Make a table
trialSim = makeTrialTableSims(allMDMS(:,2:end),allDur,allMS,allMD,pR);


%% Plot simulated and measured behavior

% Fig. 2
% a) left & middle
getPerfByMDMS(trialData,pR,1);
% a) right
getPerfByNetEvMS(trialData,pR,1)
% b) left
getPerfByFrac(trialData,pR,1)
% b) right
getPerfByMSfrac(trialData,pR,1)
% c)
getPerformance_noSwitch(trialData,pR,1)
% Fig. 3
% e - g) same as a - c) in Fig. 2
% h)
getPsyKernelsAverage(trialData,pR,1)




%% Plot simulated and measured behavior for best model by participant

% Here the behavior was first simulated for each participant separately, 
% based on the optimal parameters for that participant, and was then
% averaged over participants (as in Fig. 2-3 in the manuscript).

if keyShowPlotsFromPaper
    % PICK A MODEL
    if keyBestFastNoiseModels
        % Best fast noise model
        load(fullfile(homedir,'mat','pRbest_st263nLLcv1.mat'),'pR'); choices = pR;
    else
        % Best slow noise model
        load(fullfile(homedir,'mat','pRbest204_sfSbias1.mat'),'pRbest'); choices = pRbest;
    end
    
    % Load data
    load(fullfile(homedir,'mat','trialData.mat'));
    
    % Plot data
    keyPlotModel = 1;
    getPerfByMDMS(trialData,choices,keyPlotModel)
    getPerfByNetEvMS(trialData,choices,keyPlotModel)
    getPerfByFrac(trialData,choices,keyPlotModel)
    getPerfByMSfrac(trialData,choices,keyPlotModel)
    getPerformance_noSwitch(trialData,choices,keyPlotModel)
    getPsyKernelsAverage(trialData,choices,keyPlotModel)
    
end
%%


