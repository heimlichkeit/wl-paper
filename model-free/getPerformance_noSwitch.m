function [] = getPerformance_noSwitch(trial,choices,keyPlotModel)
% Only data and NO direction change getPerformance_noSwitch(trial,[],0)
% or provide model choices getPerformance_noSwitch(trial,choices,1)
% choices are p(R) within [0 1] or discrete: 0 for Left, 1 for Right
%
% VS, 6/9/2021


xlimit = 4;
rangeNetMD = 0:xlimit;
totalTrialsNum = sum(trial.idxMS > 0 & trial.absMD <= xlimit & trial.nSwitches == 0);
uniqueDur = unique(trial.dur);
perf = NaN(numel(rangeNetMD),max(trial.idxMS),numel(uniqueDur));
sem = NaN(numel(rangeNetMD),max(trial.idxMS),numel(uniqueDur));
if keyPlotModel
    perf_m = NaN(numel(rangeNetMD),max(trial.idxMS),numel(uniqueDur));
end
for iMD = 1:numel(rangeNetMD)
    MD = rangeNetMD(iMD);
    
    if keyPlotModel
        corR = logical(trial.corR);
        corL = logical(trial.corL);
        pCor = 0.5*ones(size(choices));
        pCor(corR) = choices(corR);
        pCor(corL) = 1 - choices(corL);
    end
    
    wasSubjCor = trial.cor;
    wasSubjCor(isnan(wasSubjCor)) = 0.5;
    
    for iMS = 1:max(trial.idxMS)
        for iDur = 1:numel(uniqueDur)
            x = trial.dur == uniqueDur(iDur) & trial.idxMS == iMS & ...
                trial.absMD == MD & trial.nSwitches == 0;
            perf(iMD,iMS,iDur) = mean(wasSubjCor(x));
            sem(iMD,iMS,iDur) = std(wasSubjCor(x))/sqrt(sum(x));
            
            if keyPlotModel
                perf_m(iMD,iMS,iDur) = mean(pCor(x));
            end
        end
    end
end


% FIGURE 2
% addpath('cbrewer');
cmap = cbrewer('seq','Greys',5);
cmap = cmap(end:-1:1,:);
figure('Renderer', 'painters', 'Position', [400 500 1200 200])
for iDur = 1:3
    subplot(1,3,iDur);
    for iMS = 1:max(trial.idxMS)
        x = ~isnan(perf(:,iMS,iDur));
        y = perf(x,iMS,iDur);
        errorbar(rangeNetMD(x),y,1.96*sem(x,iMS,iDur),'color',cmap(iMS,:)); hold on;
        h1(iMS,:) = plot(rangeNetMD(x),y,...
            '-o','lineWidth',2,'color',cmap(iMS,:)); hold on;
        if keyPlotModel
            plot(rangeNetMD(x),perf_m(x,iMS,iDur),...
                ':','lineWidth',2,'color',cmap(iMS,:));
        end
    end
    xlim([0 xlimit]);
    ylim([0.5 1]);
    xlabel('abs(netMD)');
    ylabel('fraction of correct choices');
    if iDur == 1
        legend(h1,'1x MS','2x MS','4x MS','Location','NorthEast');
        legend(gca,'boxoff');
        if numel(unique(trial.subjectId)) > 1
            title(['average across ' num2str(numel(unique(trial.subjectId)))...
                ' participants, ' num2str(totalTrialsNum) ' trials with NO switches']);
        else
            title(['for S' num2str(unique(trial.subjectId))...
                ' participant, ' num2str(totalTrialsNum) ' trials with NO switches']);
        end
    else
        title(['duration ' num2str(uniqueDur(iDur)+1)]);
    end
    box off
end