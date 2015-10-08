function config=exposeBarPlot(config, data, p)

config = expDisplay(config, p);
if strcmpi(p.orientation(1), 'v')
    barCommand = 'bar';
else
    barCommand = 'barh';
end
if ~isempty(p.addSpecification)
    h = feval(barCommand, data.meanData, p.addSpecification{:});
else
    h = feval(barCommand, data.meanData);
end

if p.uncertainty>-1
    if length(p.obs)>1
        fprintf(2, 'Warning, display of uncertainty with multiple observations is currently unsupported.\n');
    end
    set(h, 'faceColor', 'w')
    hold on
    errorbar(data.meanData, data.stdData, 'k.');
    hold off
end

expSetAxes(config, p);