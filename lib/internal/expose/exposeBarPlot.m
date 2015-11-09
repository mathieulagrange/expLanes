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

set(h, 'faceColor', 'w')

if p.uncertainty>-1
    if length(p.obs)>1
        fprintf(2, 'Warning, display of uncertainty with multiple observations is currently unsupported.\n');
    else
        hold on
        errorbar(data.meanData, data.stdData, 'k.');
        hold off
    end
end

expSetAxes(config, p);