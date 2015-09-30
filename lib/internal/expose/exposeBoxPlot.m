function config = exposeBoxPlot(config, data, p)

config = expDisplay(config, p);
if length(p.obs)>1
    error('Please select one observation');
end
if strcmpi(p.orientation(1), 'h')
    p.addSpecification = [p.addSpecification {'orientation', 'horizontal'}];
end
boxplot(data.filteredData','notch','on', p.addSpecification{:}); % , 'plotstyle', 'compact' % TODO ability to add something to the matlabplot command

expSetAxes(config, p);