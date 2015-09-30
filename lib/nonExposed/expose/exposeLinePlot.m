function config = exposeLinePlot(config, data, p)

config = expDisplay(config, p);
colormap = varycolor(size(data.meanData, 1));
% set(gca, 'ColorOrder', colormap);

hold on
for k=1:size(data.meanData, 1)
    if sum(data.stdData(:))==0
        h = plot(data.meanData(k, :),'linewidth', 1.1);
    else
        x = (1:size(data.meanData, 2))+.04*(k-size(data.meanData, 1)/2);
        h = errorbar(x, data.meanData(k, :), data.stdData(k, :));
    end
    if ~isempty(p.marker)
        set(h, 'marker', p.marker{min(k, length(p.marker))}, 'markerSize', 10);
    end
    if iscell(p.color)
        set(h, 'color', p.color{min(k, length(p.color))});
    elseif p.color
        set(h, 'color', colormap(k, :));
    else
        set(h, 'color', 'k');
    end
    if ~isempty(p.addSpecification)
        set(h, p.addSpecification{:});
    end
    for m=1:2:length(p.addSettingSpecification)
        set(h, p.addSettingSpecification{m}, p.addSettingSpecification{m+1}{min(k, length(p.addSettingSpecification{m+1}))}); % TODO handle cell array
    end
end
hold off

axis tight

set(gca,'xtick', 1:length(p.legendNames));
set(gca, 'xticklabel', p.legendNames);

if p.rotateAxis
    b=get(gca,'XTick');
    %     c=get(gca,'YTick');
    c=axis; c=c(3:4);
    th=text(b,repmat(c(1)-.05*(c(2)-c(1)),length(b),1),p.legendNames,'HorizontalAlignment','right','rotation', p.rotateAxis);
    set(th, 'fontsize', config.displayFontSize);
    set(gca,'XTickLabel',{''});
end


% set(gca, 'xticklabel', p.legendNames);
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


