function config = exposeLinePlot(config, data, p)

config = expDisplay(config, p);
set(gca, 'ColorOrder', varycolor(size(data.meanData, 1)));
hold on

plot(data.meanData','linewidth', 1.1, p.addSpecification{:}); % TODO xAxis,

set(gca,'xtick', 1:length(p.legendNames));
set(gca, 'xticklabel', p.legendNames);
set(gca, 'fontsize', config.displayFontSize);
if any(p.legendLocation ~= 0) && ~isempty(p.labels)
    if ischar(p.legendLocation)
        legend(p.labels(data.selector), 'Location', p.legendLocation);
    else
        legend(p.labels(data.selector));
    end
end
% title(p.title);
xlabel(p.xName);
ylabel(p.methodLabel);
% axis tight â