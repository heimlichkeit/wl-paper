function [bias,varsf,pulseSeqWeightHist,listPars] = getParams_sfSbias(x,modelName,allMDMS)
    
    mechanisms = {'slow2';'sigma2a';'sigma2s';'bias';'same';'opps'};
    
    keyNoise = zeros(1,3);
    
    for it = 1:numel(modelName)-7 % first seven characters are 'sfSbias'
        keyNoise(str2double(modelName(it+7))) = 1;
    end
    
    listPars = mechanisms;
    if sum(keyNoise == 0) > 0
        notPresent = find(keyNoise == 0);
        for ii = numel(notPresent):-1:1
            listPars(notPresent(ii)) = [];
        end
    end
    
    varsf = zeros(1,3); % variances: alpha2 sigma2a sigma2s
    varsf(keyNoise == 1) = x(1:sum(keyNoise));
    varsf(varsf < 0) = 0;
    
    bias = x(sum(keyNoise)+1);
    hWeight = [1 x(sum(keyNoise)+2:end)']; % S
    
    % History
    pulseSeq = allMDMS(:,2:end);
    nT = size(pulseSeq,1);
    pulseHistory = diff(cat(2,zeros(nT,1),sign(pulseSeq)),1,2);
    jNew = abs(pulseHistory) == 1 & abs(pulseSeq) > 0;
    jSame = abs(pulseHistory) == 0 & abs(pulseSeq) > 0;
    jOpps = abs(pulseHistory) == 2 & abs(pulseSeq) > 0;
    isNew = double(jNew);
    isSame = double(jSame);
    isOpps = double(jOpps);

    % History
    pulseSeqWeightNew = pulseSeq .* isNew * hWeight(1);
    pulseSeqWeightSame = pulseSeq .* isSame * hWeight(2);
    pulseSeqWeightOpps = pulseSeq .* isOpps * hWeight(3);
    pulseSeqWeightHist = pulseSeqWeightNew + pulseSeqWeightSame + pulseSeqWeightOpps;
    
end