function config=exposeBarPlot(config, data, p)

config = expDisplay(config, p);
if strcmpi(p.orientation(1), 'v')
    barCommand = 'bar';
else
    barCommand = 'barh';
end
if ~isempty(p.addSpecification)
    h = feval(barCommand, data.meanData', p.addSpecification{:});
else
    h = feval(barCommand, data.meanData');
end



if p.uncertainty>-1
    if ~isvector(data.meanData)
        fprintf(2, 'Warning, display of uncertainty with multiple observations is currently unsupported.\n');
    else
        set(h, 'faceColor', 'w')
        hold on
        errorbar(data.meanData, data.stdData, 'k.');
        hold off
    end
end

% FIXME improve this in expExpose (when this special case is needed ?)
% tmp = p.labels;
% p.labels = p.legendNames; 
% p.legendNames = 0;
% if  ~isempty(tmp)
%     p.legendNames = tmp(data.selector);
% end

expSetAxes(config, p);