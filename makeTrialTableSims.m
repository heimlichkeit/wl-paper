function trial = makeTrialTableSims(pulseSeq,seqDur,motStr,allMD,pR)

% Correct choice
correctChoice = sign(nansum(allMD,2));

% Right and left correct
corR = correctChoice == 1;
corL = correctChoice == -1;

% % Probability leftward choice
% pL = 1 - pR;

% % Probability correct
% pCor = 0.5 * ones(size(allMDMS));
% pCor(corR) = pR(corR);
% pCor(corL) = pL(corL);

% Binary choice
cR = double(rand(size(pR))<pR);

% Correct (not computed for netMDMS=0)
cor = NaN(size(pR));
cor((corR & cR==1) | (corL & cR==0)) = 1;
cor((corR & cR==0) | (corL & cR==1)) = 0;


trial = table();

% Basic quantities
trial.pulses = pulseSeq;
trial.dur = seqDur;
trial.MS = motStr;
trial.nRight = sum(pulseSeq > 0,2);
trial.nLeft  = sum(pulseSeq < 0,2);
trial.nPulse = trial.nRight + trial.nLeft;

trial.absFrac = abs((trial.nRight - trial.nLeft)./(trial.nRight + trial.nLeft));

uniqueMS = unique(motStr);
for i = 1:numel(uniqueMS)
    trial.idxMS(motStr == uniqueMS(i)) = i;
end

trial.cR = cR;

% Net motion direction
trial.MD       = trial.nRight - trial.nLeft;
trial.absMD    = abs(trial.MD);
trial.MDxMS    = trial.MD .* trial.MS;
trial.absMDxMS = trial.absMD .* trial.MS;

% Normalize by nPulse
trial.fracpRight = trial.nRight ./ trial.nPulse;
trial.fracpLeft  = trial.nLeft  ./ trial.nPulse;
trial.fracpRight(trial.nPulse==0) = 0;
trial.fracpLeft(trial.nPulse==0)  = 0;
trial.fracpMD   = trial.fracpRight - trial.fracpLeft;
trial.absFracpMD = abs(trial.fracpMD);
trial.fracpMDxMS    = trial.fracpMD .* trial.MS;
trial.absFracpMDxMS  = trial.absFracpMD .* trial.MS;

% Normalize by dur
trial.fracdRight = trial.nRight ./ trial.dur;
trial.fracdLeft  = trial.nLeft  ./ trial.dur;
trial.fracdRight(trial.nPulse==0) = 0;
trial.fracdLeft(trial.nPulse==0)  = 0;
trial.fracdMD   = trial.fracdRight - trial.fracdLeft;
trial.absFracdMD = abs(trial.fracdMD);
trial.fracdMDxMS    = trial.fracdMD .* trial.MS;
trial.absFracdMDxMS  = trial.absFracdMD .* trial.MS;

% Correct choice
trial.corR = double(trial.MD > 0);
trial.corL = double(trial.MD < 0);

% Was participant correct (unknown for netMDMS = 0)
trial.cor = cor;

% First pulse 
pulseMDfirstMove = NaN(size(trial.MD));
for iT = 1:size(trial,1)
    iFirst = find(abs(pulseSeq(iT,:))>0,1,'first');
    if ~isempty(iFirst)
        pulseMDfirstMove(iT) = sign(pulseSeq(iT,iFirst));
    end
end
trial.pulseMDfirstMove = pulseMDfirstMove;
trial.pulseMDfirstPos  = sign(pulseSeq(:,1));

% History
nT = size(pulseSeq,1);
pulseHistory = diff(cat(2,zeros(nT,1),sign(pulseSeq)),1,2);
jElse = abs(pulseHistory) == 1 & abs(pulseSeq) > 0;
jSame = abs(pulseHistory) == 0 & abs(pulseSeq) > 0;
jOpps = abs(pulseHistory) == 2 & abs(pulseSeq) > 0;
trial.history = pulseHistory;
trial.hist_nRightElse = sum(pulseSeq > 0 & jElse,2);
trial.hist_nLeftElse  = sum(pulseSeq < 0 & jElse,2);
trial.hist_nRightSame = sum(pulseSeq > 0 & jSame,2);
trial.hist_nLeftSame  = sum(pulseSeq < 0 & jSame,2);
trial.hist_nRightOpps = sum(pulseSeq > 0 & jOpps,2);
trial.hist_nLeftOpps  = sum(pulseSeq < 0 & jOpps,2);
trial.hist_MDElse = trial.hist_nRightElse - trial.hist_nLeftElse;
trial.hist_MDSame = trial.hist_nRightSame - trial.hist_nLeftSame;
trial.hist_MDOpps = trial.hist_nRightOpps - trial.hist_nLeftOpps;
trial.hist_absMDElse = abs(trial.hist_MDElse);
trial.hist_absMDSame = abs(trial.hist_MDSame);
trial.hist_absMDOpps = abs(trial.hist_MDOpps);
trial.hist_isElse = double(jElse);
trial.hist_isSame = double(jSame);
trial.hist_isOpps = double(jOpps);

% let's also compute numSwitches
numSwitchesDontMindPauses = [];
for idx = 1:numel(trial.MD)
    numSwitchesDontMindPauses(idx) = 0;
    seq = trial.pulses(idx,~isnan(trial.pulses(idx,:)));
    seqTakeOutPauses = seq;
    seqTakeOutPauses(seqTakeOutPauses == 0) = [];
    for idx2 = 1:numel(seqTakeOutPauses)-1
        if seqTakeOutPauses(idx2) == - seqTakeOutPauses(idx2+1) && seqTakeOutPauses(idx2) ~= 0
            numSwitchesDontMindPauses(idx) = numSwitchesDontMindPauses(idx) + 1;
        end
    end
end
trial.nSwitches = numSwitchesDontMindPauses';
