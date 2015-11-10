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
    elseif ischar(p.color)
            set(h, 'color', p.color);
    elseif p.color == 1
        set(h, 'color', colormap(k, :));
    else
        set(h, 'color', 'k');
    end
    if ~isempty(p.addSpecification)
        set(h, p.addSpecification{:});
    end
    for m=1:2:length(p.addSettingSpecification)
        set(h, p.addSettingSpecification{m}, p.addSettingSpecification{m+1}); % TODO handle cell array {min(k, length(p.addSettingSpecification{m+1}))}
    end
end
hold off

tmp = p.labels;
p.labels = p.legendNames; % FIXME improve this in expExpose
p.legendNames = 0;
if  ~isempty(tmp)
    p.legendNames = tmp(data.selector);
end

expSetAxes(config, p);


