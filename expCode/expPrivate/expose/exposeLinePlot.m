function config = exposeLinePlot(config, data, p)

config = expDisplay(config, p);
plot(data.meanData'); % TODO xAxis,
set(gca,'xtick', 1:length(p.legendNames));
set(gca, 'xticklabel', p.legendNames);
set(gca, 'fontsize', config.displayFontSize);
legend(p.labels);
title(p.title);
xlabel(p.xName);
ylabel(p.methodLabel);