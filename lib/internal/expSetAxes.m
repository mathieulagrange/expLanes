function expSetAxes(config, p)

if p.tight && strcmp(p.legendLocation, 'BestOutSide')
  p.legendLocation = 'Best' ;
end

if  length(p.legendNames)>1
    if any(p.legendLocation ~= 0)
        if ischar(p.legendLocation)
            legend(p.legendNames, 'Location', p.legendLocation);
        else
            legend(p.legendNames);
        end
    end
end

if ~isempty(p.xName) && length(p.units)>0 && ~isempty(p.units{1})
    p.xName = [p.xName{1} ' (' p.units{1} ')'];
end

if ~isempty(p.methodLabel) && length(p.units)>1 && ~isempty(p.units{2})
    p.methodLabel = [p.methodLabel{1} ' (' p.units{2} ')'];
end

xlabel(p.xName, 'fontsize', config.displayFontSize);
if length(p.axisLabels)>1
    ylabel(p.methodLabel, 'fontsize', config.displayFontSize);
end

if strcmpi(p.orientation(1), 'h')
    set(gca,'ytick', 1:length(p.labels));
    set(gca, 'yticklabel', p.labels);
else
    set(gca,'xtick', 1:length(p.labels));
    set(gca, 'xticklabel', p.labels);
    b=get(gca,'XTick');
    if p.rotateAxis
        c=axis; c=c(3:4);
        th=text(b,repmat(c(1)-.05*(c(2)-c(1)),length(b),1),p.labels,'HorizontalAlignment','right','rotation', p.rotateAxis);
        set(th, 'fontsize', config.displayFontSize);
        set(gca,'XTickLabel',{''});
    end
end
set(gca, 'fontsize', config.displayFontSize);
% title(p.title);
if p.tight
 axis tight
end