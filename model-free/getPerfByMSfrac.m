function [] = getPerfByMSfrac(trial,choices,keyPlotModel)
% Only data getPerfByMSfrac(trial,[],0)
% or provide model choices getPerfByMSfrac(trial,choices,1)
% choices are p(R) within [0 1] or discrete: 0 for Left, 1 for Right
%
% VS, 11/8/2022

minNtrials = 200;
xlimit = 7;
totalTrialsNum = sum(trial.idxMS > 0 & trial.absMD <= xlimit & trial.absMD > 0);
uniqueAbsFrac = unique(trial.absFrac);
uniqueAbsFrac2 = unique(trial.absFrac.*trial.MS);
perf = NaN(numel(uniqueAbsFrac),max(trial.idxMS));
sem = NaN(numel(uniqueAbsFrac),max(trial.idxMS));
perf2 = NaN(numel(uniqueAbsFrac2),max(trial.idxMS));
sem2 = NaN(numel(uniqueAbsFrac2),max(trial.idxMS));
if keyPlotModel
    perf_m = NaN(numel(uniqueAbsFrac),max(trial.idxMS));
    perf2_m = NaN(numel(uniqueAbsFrac2),max(trial.idxMS));

    corR = logical(trial.corR);
    corL = logical(trial.corL);
    pCor = NaN(size(choices));
    pCor(corR) = choices(corR);
    pCor(corL) = 1 - choices(corL);
end

wasSubjCor = trial.cor;
wasSubjCor(isnan(wasSubjCor)) = NaN;

for iMS = 1:max(trial.idxMS)
    for iFr = 1:numel(uniqueAbsFrac)

        x = trial.idxMS == iMS & trial.absMD <= xlimit &...
            trial.absFrac == uniqueAbsFrac(iFr);
        if sum(x) > minNtrials
            perf(iFr,iMS) = nanmean(wasSubjCor(x));
            sem(iFr,iMS) = nanstd(wasSubjCor(x))/sqrt(sum(x));
            
            if keyPlotModel
                perf_m(iFr,iMS) = nanmean(pCor(x));
            end
        end
    end
    
    for iFr = 1:numel(uniqueAbsFrac2)
        
        x = trial.idxMS == iMS & trial.absMD <= xlimit &...
            trial.absFrac.*trial.MS == uniqueAbsFrac2(iFr);
        if sum(x) > minNtrials
            perf2(iFr,iMS) = nanmean(wasSubjCor(x));
            sem2(iFr,iMS) = nanstd(wasSubjCor(x))/sqrt(sum(x));
            
            if keyPlotModel
                perf2_m(iFr,iMS) = nanmean(pCor(x));
            end
        end
    end
end

sem_75 = prctile(sem(:),75); % we do not show points in the last 25% (biggest CIs due to less data)
sem_75_2 = prctile(sem2(:),75);

% FIGURE
% addpath('cbrewer');
cmap = cbrewer('seq','Greys',5);
cmap = cmap(end:-1:1,:);
figure('Renderer', 'painters', 'Position', [400 500 1000 400])
subplot(1,2,1);
for iMS = max(trial.idxMS):-1:1
    x = sem2(:,iMS) <= sem_75_2;
    y = perf2(x,iMS);
    errorbar(uniqueAbsFrac2(x),y,1.96*sem2(x,iMS),'color',cmap(iMS,:)); hold on;
    h1(iMS,:) = plot(uniqueAbsFrac2(x),y,...
        '-o','lineWidth',2,'color',cmap(iMS,:)); hold on;
    if keyPlotModel
         h1(iMS,:) = plot(uniqueAbsFrac2(x),perf2_m(x,iMS),...
            ':','lineWidth',2,'color',cmap(iMS,:)); hold on;
    end
end
xlim([0 max(uniqueAbsFrac2)+0.1]);
ylim([0.5 1]);
xlabel('|frac.ev.|*MS');
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
for iMS = max(trial.idxMS):-1:1
    x = sem(:,iMS) <= sem_75;
    y = perf(x,iMS);
    errorbar(uniqueAbsFrac(x),y,1.96*sem(x,iMS),'color',cmap(iMS,:)); hold on;
    h2(iMS,:) = plot(uniqueAbsFrac(x),y,...
        '-o','lineWidth',2,'color',cmap(iMS,:)); hold on;
    if keyPlotModel
        plot(uniqueAbsFrac(x),perf_m(x,iMS),...
            ':','lineWidth',2,'color',cmap(iMS,:)); hold on;
    end
end
xlim([0 max(uniqueAbsFrac)+0.1]);
ylim([0.5 1]);
xlabel('|frac. ev.|');
ylabel('fraction of correct choices');

legendString = 'x' + string([1 2 4]);
hleg = legend(h2,legendString,'Location','SE');
legend(gca,'boxoff');
htitle = get(hleg,'Title');
set(htitle,'String','MS')    