function expSetAxes(config, data, p)

if strcmp(lower(p.orientation(1)), 'h')
    if length(p.legendNames)>1
        legend(p.legendNames);
    else
        xlabel(p.legendNames);
    end
    set(gca,'ytick', 1:length(p.labels));
    set(gca, 'yticklabel', p.labels);
%     set(gca, 'fontsize', config.displayFontSize);
    xlabel(p.methodLabel, 'fontsize', config.displayFontSize);
    
    % title(p.title);
else
    ylabel(p.axisLabels{1}, 'fontsize', config.displayFontSize);
    %     title(p.title);
    set(gca,'xtick', 1:length(p.labels));
    set(gca, 'xticklabel', p.labels);
    b=get(gca,'XTick');
    c=get(gca,'YTick');
    c=axis; c=c(3:4);
    th=text(b,repmat(c(1)-.05*(c(2)-c(1)),length(b),1),p.labels,'HorizontalAlignment','right','rotation',45);
    set(th, 'fontsize', config.displayFontSize);
    set(gca,'XTickLabel',{''});
end
set(gca, 'fontsize', config.displayFontSize);

% axis tight