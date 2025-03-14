function [] = getPerfByFrac(trial,choices,keyPlotModel)
% Only data getPerfByFrac(trial,[],0)
% or provide model choices getPerfByFrac(trial,choices,1)
% choices are p(R) within [0 1] or discrete: 0 for Left, 1 for Right
%
% VS, 5/06/2022

minNtrials = 30;
xlimit = 7;
totalTrialsNum = sum(trial.idxMS > 0 & trial.absMD <= xlimit & trial.absMD > 0);
uniqueDur = unique(trial.dur);
uniqueAbsFrac = unique(trial.absFrac);
perf = NaN(numel(uniqueAbsFrac),numel(uniqueDur));
sem = NaN(numel(uniqueAbsFrac),numel(uniqueDur));
if keyPlotModel
    perf_m = NaN(numel(uniqueAbsFrac),numel(uniqueDur));

    corR = logical(trial.corR);
    corL = logical(trial.corL);
    pCor = NaN(size(choices));
    pCor(corR) = choices(corR);
    pCor(corL) = 1 - choices(corL);
end
    
wasSubjCor = trial.cor;
wasSubjCor(isnan(wasSubjCor)) = NaN;
    
for iFr = 1:numel(uniqueAbsFrac)   
    for iDur = 1:numel(uniqueDur)
        x = trial.dur == uniqueDur(iDur) & trial.idxMS > 0 & trial.absMD <= xlimit &...
            trial.absFrac == uniqueAbsFrac(iFr);
        if sum(x) > minNtrials
            perf(iFr,iDur) = nanmean(wasSubjCor(x));
            sem(iFr,iDur) = nanstd(wasSubjCor(x))/sqrt(sum(x));

            if keyPlotModel
                perf_m(iFr,iDur) = nanmean(pCor(x));
            end
        end
    end
end

sem_75 = prctile(sem(:),75); % we do not show points in the last 25% (biggest CIs due to less data)

% FIGURE
cmap = crameri('hawaii',7);
figure('Renderer', 'painters', 'Position', [400 500 1000 400])
subplot(1,2,1);
for iDur = numel(uniqueDur):-1:1
    x = sem(:,iDur) <= sem_75;
    y = perf(x,iDur);
    errorbar(uniqueAbsFrac(x),y,1.96*sem(x,iDur),'color',cmap(iDur,:)); hold on;
    h1(iDur,:) = plot(uniqueAbsFrac(x),y,...
        '-o','lineWidth',2,'color',cmap(iDur,:)); hold on;
    if keyPlotModel
       h1(iDur,:) = plot(uniqueAbsFrac(x),perf_m(x,iDur),...
            ':','lineWidth',2,'color',cmap(iDur,:)); hold on;
    end
end
xlim([0 max(uniqueAbsFrac)+0.1]);
ylim([0.5 1]);
xlabel('|frac. ev.|');
ylabel('fraction of correct choices');

legendString = string(uniqueDur+1);
hleg = legend(h1,legendString,'Location','SE');
legend(gca,'boxoff');
htitle = get(hleg,'Title');
set(htitle,'String','duration')
if numel(unique(trial.subjectId)) > 1
    title(['average across ' num2str(numel(unique(trial.subjectId)))...
        ' participants, ' num2str(totalTrialsNum) ' trials']);
else
    title(['for S' num2str(unique(trial.subjectId))...
        ' participant, ' num2str(totalTrialsNum) ' trials']);
end

subplot(1,2,2);
cmap = crameri('roma',numel(uniqueAbsFrac));
j = find(sum(sem <= sem_75,2) > 1); % have at least 2 points
for i = 1:numel(j)
    idx = j(i);
    x = sem(idx,:) <= sem_75;
    y = perf(idx,x);
    errorbar(uniqueDur(x),y,1.96*sem(idx,x),'color',cmap(idx,:)); hold on;
    h2(i,:) = plot(uniqueDur(x),y,...
        '-o','lineWidth',2,'color',cmap(idx,:)); hold on;
    if keyPlotModel
        plot(uniqueDur(x),perf_m(idx,x),...
            ':','lineWidth',2,'color',cmap(idx,:));
    end
end
xlim([min(uniqueDur)-2 max(uniqueDur)+0.5]);
ylim([0.5 1]);
xlabel('duration');
ylabel('fraction of correct choices');
ax = gca;
ax.XTick = uniqueDur;
ax.XTickLabels = string(uniqueDur + 1);
legendString = string(uniqueAbsFrac(j));
hleg = legend(h2,legendString,'Location','SW');
legend(gca,'boxoff');
htitle = get(hleg,'Title');
set(htitle,'String','fraction')
title(['min ' num2str(minNtrials) ' trials per point']);
pbaspect([1 1 1]);