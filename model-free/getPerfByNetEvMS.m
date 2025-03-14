function [] = getPerfByNetEvMS(trial,choices,keyPlotModel)
% Only data getPerfByNetEvMS(trial,[],0)
% or provide model choices getPerfByNetEvMS(trial,choices,1)
% choices are p(R) within [0 1] or discrete: 0 for Left, 1 for Right
%
% VS, 3/06/2022


xlimit = 7;
rangeNetMD = 1:xlimit;
totalTrialsNum = sum(trial.idxMS > 0 & trial.absMD <= xlimit & trial.absMD > 0);
uniqueMS = unique(trial.idxMS);
uniqueMS(uniqueMS == 0) = [];
perf = NaN(numel(rangeNetMD),numel(uniqueMS));
sem = NaN(numel(rangeNetMD),numel(uniqueMS));
if keyPlotModel
    perf_m = NaN(numel(rangeNetMD),numel(uniqueMS));

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
    
    for iMS = 1:numel(uniqueMS)
        x = trial.idxMS == uniqueMS(iMS) & trial.absMD == absMD;
        perf(iMD,iMS) = mean(wasSubjCor(x));
        sem(iMD,iMS) = std(wasSubjCor(x))/sqrt(sum(x));
        
        if keyPlotModel
            perf_m(iMD,iMS) = mean(pCor(x));
        end
    end
end


% FIGURE
% addpath('cbrewer');
cmap = cbrewer('seq','Greys',5);
cmap = cmap(end:-1:1,:);
figure('Renderer', 'painters', 'Position', [400 500 1000 400])
subplot(1,2,1);
for iMS = max(uniqueMS):-1:1
    x = ~isnan(perf(:,iMS));
    y = perf(x,iMS);
    errorbar(rangeNetMD(x),y,1.96*sem(x,iMS),'color',cmap(iMS,:)); hold on;
    h1(iMS,:) = plot(rangeNetMD(x),y,...
        '-o','lineWidth',2,'color',cmap(iMS,:)); hold on;
    if keyPlotModel
        plot(rangeNetMD(x),perf_m(x,iMS),...
            ':','lineWidth',2,'color',cmap(iMS,:));
    end
end
xlim([0.5 xlimit+0.5]);
ylim([0.5 1]);
xlabel('|netMD|');
ylabel('fraction of correct choices');

legendString = 'x' + string([1 2 4]);
hleg = legend(h1,legendString,'Location','SE');
legend(gca,'boxoff');
htitle = get(hleg,'Title');
set(htitle,'String','MS')
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
    errorbar(uniqueMS(x),y,1.96*sem(iMD,x),'color',cmap(iMD,:)); hold on;
    h2(iMD,:) = plot(uniqueMS(x),y,...
        '-o','lineWidth',2,'color',cmap(iMD,:)); hold on;
    if keyPlotModel
        plot(uniqueMS(x),perf_m(iMD,x),...
            ':','lineWidth',2,'color',cmap(iMD,:));
    end
end
xlim([min(uniqueMS)-1 max(uniqueMS)+0.5]);
ylim([0.5 1]);
xlabel('MS');
ylabel('fraction of correct choices');
ax = gca;
ax.XTick = uniqueMS;
ax.XTickLabels = ['x1';'x2';'x4'];

legendString = string(rangeNetMD);
hleg = legend(h2,legendString,'Location','SW');
legend(gca,'boxoff');
htitle = get(hleg,'Title');
set(htitle,'String','|netMD|')