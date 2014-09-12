function config=exposeBarPlot(config, data, p)

config = expDisplay(config, p);
if strcmpi(p.orientation(1), 'v')
    barCommand = 'bar';
else
    barCommand = 'barh';
end
if ~isempty(p.addSpecification)
    feval(barCommand, data.meanData, p.addSpecification{:});
else
    feval(barCommand, data.meanData);
end

expSetAxes(config, p);