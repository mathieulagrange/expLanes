function config = exposeScatter(config, data, p)

config = expDisplay(config, p);
rangeValues = (max(data.meanData) - min(data.meanData))/100;
if ~isempty(p.add)
 scatter(data.meanData(:, 1), data.meanData(:, 2),'filled', p.add{:});   
else
scatter(data.meanData(:, 1), data.meanData(:, 2),'filled');
end
text(data.meanData(:, 1)+rangeValues(1), data.meanData(:, 2)-rangeValues(2), p.labels)
set(gca, 'fontsize', config.displayFontSize);
xlabel(p.axisLabels{1});
ylabel(p.axisLabels{2});