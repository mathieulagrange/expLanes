function config = exposeScatter(config, data, p)

config = expDisplay(config, p);
rangeValues = (max(data.meanData) - min(data.meanData))/100;

pointSize = 20*ones(size(data.meanData, 1), 1);
if size(data.meanData, 2)>2
    pointSize = pointSize+(data.meanData(:, 3)-min(data.meanData(:, 3)))/max(data.meanData(:, 3))*50;
end

switch size(data.meanData, 2)
    case 1
        error('Not enough observations to diplay a scatter');
    case 2
        specif = {data.meanData(:, 1)/10, data.meanData(:, 2)/10, pointSize};
        
    case 3
        specif = {data.meanData(:, 1), data.meanData(:, 2), pointSize};
    otherwise
        
        specif = {data.meanData(:, 1), data.meanData(:, 2), pointSize, data.meanData(:, 4)};
end

specif = [specif {'filled'} p.addSpecification];
scatter(specif{:});

for k=1:size(data.meanData, 1)
    rectangle('Position',[data.meanData(k, 1)-data.stdData(k, 1) data.meanData(k, 2)-data.stdData(k, 2) data.stdData(k, 1)*2 data.stdData(k, 2)*2], 'Curvature', [1 1]);
end

text(data.meanData(:, 1)+rangeValues(1), data.meanData(:, 2)-rangeValues(2), p.labels)
set(gca, 'fontsize', config.displayFontSize);
xlabel(p.axisLabels{1});
ylabel(p.axisLabels{2});