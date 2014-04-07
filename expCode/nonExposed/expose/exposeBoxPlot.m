function config = exposeBoxPlot(config, data, p)

config = expDisplay(config, p);
if length(p.metric)>1
    error('Please select one metric');
end
if strcmpi(p.orientation(1), 'h')
   p.add = [ p.add {'orientation', 'horizontal'}]; 
end
if ~isempty(p.add)
boxplot(data.filteredData','notch','on', p.add{:}); % , 'plotstyle', 'compact' % TODO ability to add something to the matlabplot command
else
boxplot(data.filteredData','notch','on'); % , 'plotstyle', 'compact' % TODO ability to add something to the matlabplot command    
end

expSetAxes(config, data, p);