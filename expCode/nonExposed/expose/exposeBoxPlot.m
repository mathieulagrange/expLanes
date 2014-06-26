function config = exposeBoxPlot(config, data, p)

config = expDisplay(config, p);
if length(p.observation)>1
    error('Please select one observation');
end
if strcmpi(p.orientation(1), 'h')
   p.addSpecification = [ p.addSpecification {'orientation', 'horizontal'}]; 
end
if ~isempty(p.addSpecification)
boxplot(data.filteredData','notch','on', p.addSpecification{:}); % , 'plotstyle', 'compact' % TODO ability to add something to the matlabplot command
else
boxplot(data.filteredData','notch','on'); % , 'plotstyle', 'compact' % TODO ability to add something to the matlabplot command    
end

expSetAxes(config, data, p);