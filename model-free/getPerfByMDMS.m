function [] = getPerfByMDMS(trial,choices,keyPlotModel)
% Only data getPerfByMDMS(trial,[],0)
% or provide model choices getPerfByMDMS(trial,choices,1)
% choices are p(R) within [0 1] or discrete: 0 for Left, 1 for Right
%
% VS, 5/10/2021


xlimit = 7;
rangeNetMD = 1:xlimit;
totalTrialsNum = sum(trial.idxMS > 0 & trial.absMD <= xlimit & trial.absMD > 0);
uniqueDur = unique(trial.dur);
perf = NaN(numel(rangeNetMD),numel(uniqueDur));
sem = NaN(numel(rangeNetMD),numel(uniqueDur));
if keyPlotModel
    perf_m = NaN(numel(rangeNetMD),numel(uniqueDur));

    corR = logical(trial.corR);
    corL = logical(trial.corL);
    pCor = 0.5*ones(size(choices));
    pCor(corR) = choices(corR);
    pCor(corL) = 1 - choices(corL);
end

wasSubjCor = trial.cor;
wasSubjCor(isnan(wasSubjCor)) = 0.5;

for iMD = 1:numel(rangeNetMD)
    absMD = rangeNetMD(iMD);
    
    for iDur = 1:numel(uniqueDur)
        x = trial.dur == uniqueDur(iDur) & trial.idxMS > 0 & trial.absMD == absMD;
        perf(iMD,iDur) = mean(wasSubjCor(x));
        sem(iMD,iDur) = std(wasSubjCor(x))/sqrt(sum(x));
        
        if keyPlotModel
            perf_m(iMD,iDur) = mean(pCor(x));
        end
    end
end


% FIGURE
cmap = crameri('hawaii',numel(rangeNetMD));
figure('Renderer', 'painters', 'Position', [400 500 1000 400])
subplot(1,2,1);
for iDur = numel(uniqueDur):-1:1
    x = ~isnan(perf(:,iDur));
    y = perf(x,iDur);
    errorbar(rangeNetMD(x),y,1.96*sem(x,iDur),'color',cmap(iDur,:)); hold on;
    h1(iDur,:) = plot(rangeNetMD(x),y,...
        '-o','lineWidth',2,'color',cmap(iDur,:)); hold on;
    if keyPlotModel
        plot(rangeNetMD(x),perf_m(x,iDur),...
            ':','lineWidth',2,'color',cmap(iDur,:));
    end
end
xlim([0.5 xlimit+0.5]);
ylim([0.5 1]);
xlabel('|netMD|');
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
cmap = crameri('batlow',numel(rangeNetMD));
for iMD = 1:numel(rangeNetMD)
    x = ~isnan(perf(iMD,:));
    y = perf(iMD,x);
    errorbar(uniqueDur(x),y,1.96*sem(iMD,x),'color',cmap(iMD,:)); hold on;
    h2(iMD,:) = plot(uniqueDur(x),y,...
        '-o','lineWidth',2,'color',cmap(iMD,:)); hold on;
    if keyPlotModel
        plot(uniqueDur(x),perf_m(iMD,x),...
            ':','lineWidth',2,'color',cmap(iMD,:));
    end
end
xlim([min(uniqueDur)-2 max(uniqueDur)+0.5]);
ylim([0.5 1]);
xlabel('trial duration');
ylabel('fraction of correct choices');
ax = gca;
ax.XTick = uniqueDur;
ax.XTickLabels = string(uniqueDur + 1);

legendString = string(rangeNetMD);
hleg = legend(h2,legendString,'Location','SW');
legend(gca,'boxoff');
htitle = get(hleg,'Title');
set(htitle,'String','|netMD|')