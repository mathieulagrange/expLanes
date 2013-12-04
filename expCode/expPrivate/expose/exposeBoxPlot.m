function config = exposeBoxPlot(config, data, p)

config = expDisplay(config, p);
if length(config.evaluationMetrics(data.metricSelector))>1
    error('Please select one metric');
end
set(gca, 'fontsize', config.displayFontSize);
boxplot(data.filteredData','notch','on');
ylabel(p.axisLabels{1});
title(p.title);
set(gca,'xtick', 1:length(p.labels));
set(gca, 'xticklabel', p.labels);
b=get(gca,'XTick');
c=get(gca,'YTick');
c=axis; c=c(3:4);
th=text(b,repmat(c(1)-.05*(c(2)-c(1)),length(b),1),p.labels,'HorizontalAlignment','right','rotation',45);
set(th, 'fontsize', config.displayFontSize);
set(gca,'XTickLabel',{''});