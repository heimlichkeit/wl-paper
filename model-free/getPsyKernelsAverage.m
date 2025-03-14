function [] = getPsyKernelsAverage(trial,choices,keyPlotModel)
% Only data getPsyKernels(trial,[],0)
% or provide model choices getPsyKernels(trial,choices,1)
% choices are p(R) within [0 1] or discrete: 0 for Left, 1 for Right
%
% VS, 10/11/2021

uniqueDur = unique(trial.dur);
maxDur = max(uniqueDur);
nDur = numel(uniqueDur);

figure;
C = crameri('hawaii',7);
lw = 2;
if keyPlotModel
    Cm = crameri('hawaii',7);
    C = 0.5*ones(11,3); lw = 1;
end

data = trial;
if keyPlotModel
    pR = choices;
    pRpulseRm  = NaN(nDur,maxDur);
    pRpulseLm = NaN(nDur,maxDur);
end

pRpulseR  = NaN(nDur,maxDur);
pRpulseL  = NaN(nDur,maxDur);

for iDur = 1:nDur
    jDur = data.dur == uniqueDur(iDur);
    for iPulse = 1:uniqueDur(iDur)
        jR = data.pulses(:,iPulse) > 0;
        jL = data.pulses(:,iPulse) < 0;
        pRpulseR(iDur,iPulse) = nanmean(data.cR(jDur&jR));
        pRpulseL(iDur,iPulse) = nanmean(data.cR(jDur&jL));
        
        if keyPlotModel
            pRpulseRm(iDur,iPulse) = nanmean(pR(jDur&jR));
            pRpulseLm(iDur,iPulse) = nanmean(pR(jDur&jL));
        end
    end
end

psyKernel = pRpulseR - pRpulseL;



for iDur = 1:nDur
    h0(iDur) = plot(100*psyKernel(iDur,:),...
        '-','color',C(iDur,:),'LineWidth',lw); hold on;
end

legend(h0,'3','5','7','9','11','13','15'); legend(gca,'boxoff');

title('psychophysical kernels');


xlim([0 15]);
xlabel(['pulse position']);

ylabel('\Delta %Rchoices');

ylim([0 0.8]*100);
ax = gca;
ax.XTick = 1:maxDur;
ax.XTickLabels = {'2','3','4','5','6','7','8','9','10','11','12','13','14','15'};

if keyPlotModel
    psyKernel_m = pRpulseRm - pRpulseLm;
    for iDur = 1:nDur
        h1(iDur) = plot(100*psyKernel_m(iDur,:),...
            '-','color',Cm(iDur,:),'LineWidth',2);
    end
    
    legend([h0(1) h1],'data','3','5','7','9','11','13','15'); legend(gca,'boxoff');
    
    title('psychophysical kernels, data (grey) vs model (color)');
    
end