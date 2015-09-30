function config = exposeImage(config, data, p)

config = expDisplay(config, p);

if p.sort
    [data.meanData, ind] = expSortData(data.meanData, p, 0, config, data);
    labels = flipud(p.rowNames(ind));
else
    labels = flipud(p.rowNames);
end

imagesc(flipud(data.meanData));

axis xy
p.orientation='v';
p.labels = p.legendNames;
p.legendNames = {};
expSetAxes(config, p);

xlabel(p.xName);
ylabel(p.methodLabel);
set(gca, 'ytick', (1:length(labels)));
set(gca, 'yticklabel', labels);
colorbar

