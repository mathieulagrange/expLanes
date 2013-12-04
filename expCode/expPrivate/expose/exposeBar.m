function config=exposeBar(config, data, p)

config = expDisplay(config, p);
barh(data.meanData);
if length(p.legendNames)>1
    legend(p.legendNames);
else
    xlabel(p.legendNames);
end
set(gca,'ytick', 1:length(p.labels));
set(gca, 'yticklabel', p.labels);
set(gca, 'fontsize', config.displayFontSize);
xlabel(p.methodLabel);
title(p.title);