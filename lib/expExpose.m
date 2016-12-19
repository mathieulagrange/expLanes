function config = expExpose(varargin)
% expExpose display observations
%	config = expExpose(typeOfExposition, varargin)
%	- varargin: sequence of ('parameter', value) pairs where the parameter is of
%    'addSpecification': add display specification to plot directive
%    	as ('parameter' / value) pairs
%           value can be a cell array, in this case the cell array is split
%           across plot items
%    'addSettingSpecification': add display specification to plot
%           directive relative to specific settings as ('parameter' / value) pairs
%           value have to be a cell array which is split
%           across plot items aka the settings
%    'caption': caption of display as string
%    	symbol + gets replaced by a compact description of the setting
%    'color': color of line
%           1: default set of colors
%           0: black
%           {'r', ...}: user defined set of colors
%    'compactLabels': shorten labels by removing common substrings
%           (default 0)
%    'data': specify data to be stored (default empty)
%    'expand': name or index of the factor to expand
%    'fontSize': set the font size of LaTeX tables (default 'normal')
%    'highlight': highlight settings that are not significantly
%    	different from the best performing setting
%       -1: no highlight
%    	0: highlight for all observations
%    	[1, 3]: highlight for the first and third observations
%    'highlightStyle': type of highlighting
%        'best': highlight best and equivalents (default)
%        'Best': highlight only the best
%        'better': highlight the best if significantly better than
%           the others
%        'Better': highlight only the best if significantly better than
%           the others
%    'highlightColor': use color to show highlights (default 1), -1 do
%       not use * to display the best performing one
%    'integrate': factor(s) to integrate by summation
%    'label': LaTeX label of display as string (equal to the name if left empty)
%    'legendLocation': location of the legend (default 'BestOutSide', doc legend for more options)
%    'marker': specification of markers for line plot
%           1: Matlab default set of markers (default)
%           0: no markers
%           {'', ...}: user defined cell array of markers
%    'mask': selection of the settings to be displayed
%    'mergeDisplay': concatenate current display with the previous one
%        '': no merge (default)
%        'h': horizontal concatenation
%        'v': vertical concatenation
%    'multipage': activate the multipage setting to the LaTeX table
%    'name': name of exported file as string
%    	symbol + gets replaced by a compact description of the setting
%    'number': add a line number for each setting in tables
%    'noFactor' : remove setting factors
%    'noObservation': remove observations
%    'obs': name(s) or index(es) of the observations to display
%    'orderFactor': numeric array specifying the ordering of the factors
%    'orderSetting': numeric array specifying the ordering of the settings
%    'orientation': orientation of display
%    	'v': vertical (default)
%    	'h': horizontal
%       'i': as second letter invert the table for prompt and latex
%           display
%    'percent': display observations in percent
%    	selector is the same as 'highlight'
%    'plotCommand': set of commands executed after the plotting
%       directives as a cell array of commands
%    'plotAxisProperties': set of command setting the current axis after plotting
%       directives as a cell array of couple property / value (see axis properties in Matlab documentation)
%    'precision': mantissa precision of data as numeric value or array
%           -1: take value of config field tableDigitPrecision (default)
%           0: no mantissa
%    'put': specify display output
%    	0: output to command prompt
%    	1: output to figure
%    	2: output to LaTeX
%    'report': include the current exposition in the report
%       0: do not include (default for Matlab tables)
%       1: include (default for other displays)
%    'rotateAxis': rotate X axis labels (in degrees)
%    'show': display
%        'data': actual observations (default)
%        'rank': ranking among settings
%        'best': select best approaches
%        'Best': select the significantly best approach (if any)
%    'save': save the display
%    	0: no saving
%    	1: save to a file with the name of the display as filename
%    	'name': save to a file with 'name' as filename
%    'shortObservations': compact observation names
%    'shortFactors': compact factor names
%    'showMissingSetting': show missing settings (default 0)
%    'sort': sort settings acording to the specified set of observations if
%        positive or to the specified set of factors if negative
%    'step': show observations the specified processing step as name or
%    index (default last step)
%    'title': title of display as string
%    	symbol + gets replaced by a compact description of the setting
%    'tight': tighten the display
%    'total': display average  or summed values for observations
%        'v', 'V': vertical with (v) or without (V) display of settings
%        'h', 'H': horizontal with (h) or without (H) display of settings
%    'uncertainty': display uncertainty
%    	selector is the same as 'highlight'
%    'units': units of plot axis a cell array of strings
%    'visible': show the figure (default 1 except in save mode)
%	-- config: expLanes configuration

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.

oriConfig = varargin{1};
config = varargin{1};
exposeType = varargin{2};

p.orderFactor = [];
p.orderSetting = [];
p.expand = 0;
p.obs = 0;
p.uncertainty = 0;
p.highlight=0;
p.title='+';
p.name='+';
p.caption='+';
p.multipage=0;
p.sort=0;
p.mask={};
p.step=0;
p.label='+';
p.put=1;
p.save=0;
p.report=1;
p.percent=-1;
p.legendLocation='BestOutSide';
p.integrate=0;
p.total= 'none';
p.addSpecification={};
p.addSettingSpecification={};
p.orientation='v';
p.shortObservations = -1;
p.shortFactors = -1;
p.fontSize='';
p.visible = -1;
p.number = 0;
p.showMissingSettings = 0;
p.precision = -1;
p.show = 'data';
p.numericObservations = 0;
p.compactLabels = 0;
p.highlightStyle = 'best';
p.highlightColor = 1;
p.mergeDisplay = '';
p.noFactor = 0;
p.noObservation = 0;
p.data = [];
p.rotateAxis=0;
p.marker = 1;
p.color = 1;
p.plotCommand={};
p.plotAxisProperties={};
p.design = {};
p.units = {};
p.labels = [];
p.tight=0;

pNames = fieldnames(p);
% overwrite default factors with command line ones
for pair = reshape(varargin(3:end),2,[])
    if ~any(strcmp(pair{1},strtrim(pNames)))
        fprintf(2, [pair{1} ' is not a valid parameter. \n type help expExpose for available options.\n']);
        return
    end
    p.(pair{1}) = pair{2};
end

if strcmpi(p.show(1:4), 'bett')
    p.better = str2num(p.show(7:end));
    p.show = [p.show(1:2) 'st'];
else
    p.better = 0;
end

if p.precision==-1
    p.precision = config.tableDigitPrecision;
end

if any(p.save ~= 0) && p.visible ~= 1 % &&  ~strcmp(exposeType, 't')
    p.visible = 0;
elseif p.visible == -1
    p.visible = 1;
end

if ischar(p.step)
    ind = find(config.stepName, p.step);
    if isempty(p.step)
        error(['Unable to find ' p.step ' as a name of processing step.']);
    else
        p.step = ind;
    end
end

if p.step && p.step ~= length(config.stepName)
    config.step.id = p.step;
end

if ~isempty(p.mask) && ~isequal(p.mask, config.mask)
    config.mask = p.mask;
end
if ~isempty(p.design)
    config.design = p.design;
    config = expDesign(config);
end

if ~iscell(p.marker)
    if p.marker == 1
        p.marker = {'x', 'd', 'o', 's', '*', '+', '.', '^', '<', '>', 'v', 'h', 'p'};
    elseif p.marker == 0
        p.marker = [];
    end
end

if ischar(p.put)
    switch p.put
        case {'prompt', '>>'}
            p.put = 0;
        case {'figure', 'fig', 'f'}
            p.put = 1;
        case {'latex', 'tex', 'report', 't', 'r'}
            p.put = 2;
        otherwise
            error('Please specify an outut as one of those: prompt (0), figure (1), tex (2)');
    end
end

if iscell(config.mask)
    if isempty(config.mask) || ~iscell(config.mask{1})
        config.mask = {config.mask};
    end
end

if ~expCheckMask(config.factors, config.mask)
    mask = cell(1, length(config.factors.names));
    [mask{:}] = deal(-1);
    config.mask = {mask};
end

if ~isempty(exposeType)
    config.step = expStepSetting(config.factors, config.mask, config.step.id);
    
    config = expReduce(config);
end

if ~p.percent
    p.percent = 1:length(p.obs);
end

if  ~isfield(config, 'evaluation') || isempty(config.evaluation) || isempty(config.evaluation.data)  || sum(cellfun(@isempty,config.evaluation.data))== length(config.evaluation.data)
    if ~isempty(exposeType)
        disp('No observations to display.');
    end
else
    if ischar(p.obs)
        p.obs = find(strcmp(config.evaluation.observations, p.obs));
        if isempty(p.obs), disp(['Unable to find observation with name' p.obs]); end
    end
    if ~p.obs
        p.obs = 1:length(config.evaluation.observations);
    end
    %     if length(p.obs) > length(p.precision)
    p.precision = [p.precision*ones(1, length(config.evaluation.observations))];
    %     end
    evaluationObservations = config.evaluation.observations;
    
    if ~isempty(evaluationObservations)
        evaluationObservations = evaluationObservations(p.obs);
    end
    if p.percent ~= -1
        for k=1:length(p.percent)
            p.precision(p.percent(k)) = max(p.precision(p.percent(k))-2, 0);
        end
        if p.percent==0
            p.percent = 1:length(evaluationObservations);
        end
        
    end
    
    if p.shortObservations == 0
        p.shortObservations = 1:length(evaluationObservations);
    end
    if p.shortObservations ~= -1
        for k=1:length(p.shortObservations)
            evaluationObservations(p.shortObservations(k)) =  names2shortNames(evaluationObservations(p.shortObservations(k)), 3);
        end
    end
    if p.numericObservations
        evaluationObservations = num2cell(1:length(evaluationObservations));
        evaluationObservations = cellfun(@num2str, evaluationObservations, 'UniformOutput', false);
    end
    
    if ~isempty(p.orderFactor) || any(p.expand ~= 0)
        if ~isempty(p.orderFactor)
            order = p.orderFactor;
        else
            order = 1:length(config.factors.names);
        end
        if any(p.expand ~= 0)
            [null, expand, expandName] = expModifyExposition(config, p.expand);
            if order(end) ~= expand
                order(expand) = length(order);
                order(end) = expand;
            end
            p.expand = expandName{1};
        end
        config = expOrder(config, order);
        %         p.orderFactor = order;
        % sort data and settings
    end
    
    if any(p.percent>0)
        %         observations = config.evaluation.observations;
        for k=1:length(p.percent)
            for m=1:length(config.evaluation.results)
                if ~isempty(config.evaluation.results{m}) && all(config.evaluation.results{m}.(evaluationObservations{p.percent(k)})<=1)
                    config.evaluation.results{m}.(evaluationObservations{p.percent(k)}) = 100*config.evaluation.results{m}.(evaluationObservations{p.percent(k)});
                end
            end
        end
        
        for k=1:length(p.percent)
            if p.percent(k) <= length(evaluationObservations)
                evaluationObservations{p.percent(k)} =  [evaluationObservations{p.percent(k)} ' (%)'];
            end
        end
    end
    
    
    
    if strcmp(p.show, 'Best')
        p.highlight = 0;
    end
    
    data = {};
    if iscell(p.integrate) || any(p.integrate ~= 0),
        [config, p.integrate, p.integrateName] = expModifyExposition(config, p.integrate);
        pi=p;
        pi.expand = 0;
        data = expFilter(config, pi);
    elseif isnumeric(p.expand) && ~p.expand
        data = expFilter(config, p);
    end
    
    if p.expand,
        if p.integrate,
            fprintf(2, 'Combined use of integrate and expand is currently not supported.\n');
            return,
        end
        if (isnumeric(p.expand) && length(p.expand)>1) || iscell(p.expand), fprintf(2, 'Please choose only one factor to expand.\n'); return; end
        [config, p.expand, p.expandName] = expModifyExposition(config, p.expand);
        if (isnumeric(p.obs) && length(p.obs)>1) || iscell(p.obs), fprintf(2, 'Please choose only one observation for factor expansion.\n'); return; end
        
        pe=p;
        pe.integrate = 0;
        if ~isempty(data)
            data = expFilter(config, pe, data.rawData);
        else
            data = expFilter(config, pe);
        end
        evaluationObservations = [ evaluationObservations p.expandName(1)];
    end
    
    if ~isempty(p.orderSetting) && length(p.orderSetting) == config.step.nbSettings
        data.settingSelector = data.settingSelector(p.orderSetting);
        data.highlights = data.highlights(p.orderSetting, :);
        data.rawData = data.rawData(p.orderSetting);
        data.stdData = data.stdData(p.orderSetting, :);
        data.meanData = data.meanData(p.orderSetting, :);
        data.filteredData = data.filteredData(p.orderSetting, :);
    end
    
    totalName = 'Average';
    if ~strcmp(p.show, 'data')
        data.stdData(:)=0;
        p.precision = 0;
        switch p.show
            case 'rank'
                data.meanData  = tiedrank(-data.meanData);
            case 'best'
                for k=1:size(data.meanData, 2)
                    if p.better
                        totalName = 'better';
                        index = or(data.meanData(:, k)>data.meanData(p.better, k), data.highlights(:, k)>0);
                    else
                        totalName = 'best';
                        [null, index] = max(data.meanData(:, k));
                    end
                    data.meanData(:, k) = 0;
                    data.meanData(index, k) = 1;
                end
                data = expShowBest(data, p);
                
            case 'Best'
                if p.better
                    totalName = 'Better';
                else
                    totalName = 'Best';
                end
                %             [null, index] = max(data.meanData);
                %             for k=1:size(data.meanData, 2)
                %                 data.meanData(:, k) = 0;
                %                 if sum(data.highlights(:, k))==2
                %                     data.meanData(index(k), k) = 1;
                %                 end
                %             end
                data.meanData = double(data.highlights==2);
                data = expShowBest(data, p);
        end
    end
    
    if ~p.sort && isfield(config, 'sortDisplay')
        p.sort = config.sortDisplay;
    end
    
    infoString = '';
    infoShortString = '';
    if isfield(config.step, 'setting')
        infoString = config.step.setting.infoStringMask;
        infoShortString = config.step.setting.infoShortStringMask;
    end
    
    p.title = strrep(p.title, '+', infoString);
    p.name = strrep(p.name, '+', infoShortString);
    p.label = strrep(p.label, '+', infoShortString);
    p.caption = strrep(p.caption, '=', p.title);
    p.caption = strrep(p.caption, '+', infoString);
    p.caption = strrep(p.caption, '_', '\_');
    
    p.legendNames = evaluationObservations;
    
    if p.shortFactors == 0
        p.shortFactors = 1:length(data.factorSelector);
    end
    
    p.xName='';
    factorNames = '';
    p.rowNames='';
    if isfield(config.step, 'factors')
        factorNames =  config.step.factors.names(data.factorSelector) ;
        p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector);
    end
    if p.shortFactors == -1
        p.columnNames = [factorNames' evaluationObservations];
    else
        p.columnNames = [names2shortNames(factorNames', 3) evaluationObservations];
    end
    p.factorNames = factorNames';
    p.obsNames = evaluationObservations;
    p.methodLabel = '';
    p.xAxis='';
    
    if p.integrate
        if ~ischar(p.legendNames)
            if isnumeric(p.legendNames{1})
                p.xAxis = cell2mat(config.step.factors.set{p.expand});
            else
                p.xAxis = 1:length(p.legendNames);
            end
            p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false)';
        end
        if p.shortFactors == -1
            p.columnNames = [config.step.factors.names(data.factorSelector); p.legendNames]';
        else
            p.columnNames = [names2shortNames(config.step.factors.names(data.factorSelector)', 3); p.legendNames]';
        end
        %         p.columnNames = [config.step.factors.names(data.factorSelector); p.legendNames]'; % (data.factorSelector)
        p.obsNames = p.legendNames;
        p.methodLabel = config.evaluation.observations(p.obs);
        p.xName = p.integrateName;
        p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector); %config.step.oriFactors.list(data.settingSelector, data.factorSelector);
    end
    
    if p.expand
        nbModalities = length(config.step.oriFactors.values{p.expand});
        
        if length(p.obs)>1
            for k=1:nbModalities
                for m=1:length(p.obs)
                    p.legendNames(1, (k-1)*length(p.obs)+m) = {''};
                    p.legendNames(2, (k-1)*length(p.obs)+m) = evaluationObservations(m);
                end
                if p.numericObservations
                    p.legendNames(1, (k-1)*length(p.obs)+floor(length(p.obs)/2)) = k;
                else
                    p.legendNames(1, (k-1)*length(p.obs)+floor(length(p.obs)/2)) = config.step.oriFactors.values{p.expand}(k);
                end
            end
        else
            if p.numericObservations
                p.legendNames = num2cell(1:nbModalities);
                p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false);
            else
                p.legendNames = config.step.oriFactors.values{p.expand};
            end
        end
        %     if ~ischar(p.legendNames)
        %         if isnumeric(p.legendNames{1})
        %             p.xAxis = cell2mat(config.step.oriFactors.values{p.expand}); % FIXME use to be set instead of values
        %         else
        %             p.xAxis = 1:length(p.legendNames);
        %         end
        %         p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false)';
        %     end
        if length(p.obs)>1
            el = cell(1, length(config.step.factors.names(data.factorSelector)));
            [el{:}] = deal('');
            %             p.columnNames = [[el; config.step.factors.names(data.factorSelector)'] p.legendNames']; % (data.factorSelector)
            
            if p.shortFactors == -1
                p.columnNames = [[el; config.step.factors.names(data.factorSelector)'] p.legendNames']
            else
                p.columnNames = [[el; names2shortNames(config.step.factors.names(data.factorSelector))'] p.legendNames']
            end
            
            %         p.factorNames = [el; config.step.factors.names(data.factorSelector)'];
        else
            %     p.columnNames = [config.step.factors.names(data.factorSelector)' p.legendNames]; % (data.factorSelector)
            if p.shortFactors == -1
                
                p.columnNames = [factorNames' p.legendNames];
            else
                p.columnNames = [names2shortNames(factorNames', 3) p.legendNames];
            end
            
        end
        p.methodLabel = config.evaluation.observations(p.obs);
        p.xName = p.expandName;
        p.rowNames = '';
        if isfield(config.step, 'factors')
            p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector); %config.step.oriFactors.list(data.settingSelector, data.factorSelector);
        end
    end
    
    
    switch p.total
        case 'v'
            for k=1:size(p.rowNames, 2)
                if k==1
                    %                     if p.total == 1
                    %                         p.rowNames{end+1, k} = 'Average';
                    %                     else
                    %                         p.rowNames{end+1, k} = 'Count';
                    % end
                    p.rowNames{end+1, k} = 'Total';
                else
                    p.rowNames{end, k} = '';
                end
            end
        case 'V'
            p.rowNames = {totalName};
        case 'h'
            p.columnNames{end+1} = totalName;
        case 'H'
            p.columnNames = [p.factorNames totalName]; % TODO recall observation name
    end
    
    if config.step.nbSettings == 1
        p.labels = '';
    else
        for k=1:config.step.nbSettings
            d = expSetting(config.step, k);
            if ~isempty(d.infoShortStringMasked)
                if isempty(strfind(d.infoShortStringMasked, '_'))
                    if isnumeric(d.(d.infoStringFactors))
                        p.labels{k} = d.infoStringMasked;
                    else
                        p.labels{k} = d.(d.infoStringFactors);
                    end
                else
                    p.labels{k} = strrep(d.infoShortStringMasked, '_', ' '); % (data.settingSelector)
                end
            end
        end
    end
    
    p.axisLabels = evaluationObservations;
    
    if p.uncertainty == 0
        p.uncertainty = 1:size(data.stdData, 2);
    end
    for k=1:size(data.stdData, 2)
        if ~any(p.uncertainty==k)
            data.stdData(:, k) = 0;
        end
    end
    
    if p.compactLabels
        p = expCompactLabels(p);
    end
    
    config.data = data;
    
    config.displayData.cellData=[];
    if length(exposeType)<=1
        switch exposeType
            case '>'
                exposeType = 'exposeTable';
                p.put=0;
            case 'l'
                exposeType = 'exposeTable';
                p.put=2;
            case 't'
                exposeType = 'exposeTable';
                %             if strfind(config.report, 'c')
                %                 p.put=2;
                %             end
            case 'b'
                exposeType = 'exposeBarPlot';
            case 'p'
                exposeType = 'exposeLinePlot';
            case 's'
                exposeType = 'exposeScatter';
            case 'x'
                exposeType = 'exposeBoxPlot';
            case 'a'
                exposeType = 'exposeAnova';
            case 'i'
                exposeType = 'exposeImage';
            case ''
            otherwise
                error(['unknown display type: ' exposeType]);
        end
    else
        if any(strcmp(exposeType, config.evaluation.structObservations))
            data = config.evaluation.structResults.(exposeType);
        end
        if ~strcmp(exposeType(1:min(6, length(exposeType))), 'expose')
            exposeType = ['expose' upper(exposeType(1)) exposeType(2:end)];
            
            if ~exist(exposeType, 'file')
                disp(['Unable to find the function ' exposeType  ' in your path. This function is needed to display the observations with the ' exposeType(7:end) ' type of display.']);
                if inputQuestion('Do you want to create it ?');
                    functionString = char({...
                        ['function config = ' exposeType '(config, data, p)'];
                        ['% ' exposeType ' EXPOSE of the expLanes experiment ' config.experimentName];
                        ['%    config = ' exposeType '(config, data, p)'];
                        '%       config : expLanes configuration state';
                        '%       data : observations as a struct array';
                        '%       p : exposition parameters';
                        '';
                        ['% Copyright: ' config.completeName];
                        ['% Date: ' date()];
                        '';
                        'p';
                        'data';
                        '';
                        });
                    dlmwrite([config.codePath '/' exposeType '.m'], functionString,'delimiter','');
                else
                    exposeType = '';
                end
            end
            
        end
        
    end
    
    if ~isempty(exposeType)
        if p.put==1 && (strcmp(exposeType, 'exposeTable') || strcmp(exposeType, 'exposeAnova')) %% TODO raise a flag
            put = p.put;
            p.put = 2;
            config = feval(exposeType, config, data, p);
            config = expDisplay(config, p);
            p.put=put;
        end
        config = feval(exposeType, config, data, p);
    end
end

if ~isempty(p.plotAxisProperties)
    set(gca, p.plotAxisProperties{:});
end
for k=1:length(p.plotCommand)
    eval(p.plotCommand{k});
end

if any(p.put==[0 2])
    config = expDisplay(config, p);
end

if exist('data', 'var') && any(strfind(config.report, 'h'))
 config = expHtml(config, data, p, exposeType);
end

if p.save ~= 0
    if ischar(p.save)
        name = p.save;
    else
        name = strrep(p.name, ' ', '_');
    end
    if ~exist('data', 'var')
        data = p.data;
    else
        data.pData = p.data;
    end
    if p.put == 1
        expSaveFig(strrep([config.reportPath 'figures/' name], ' ', '_'), gcf);
        save([config.reportPath 'figures/' name '.mat'], 'data');
    end
    if p.put ==  2 || strcmp(exposeType, 'exposeTable')
        expSaveTable([config.reportPath 'tables/' name '.tex'], config.displayData.table(end));
        save([config.reportPath 'tables/' name '.mat'], 'data');
    end
    
end

html = config.html;
displayData = config.displayData;
config = oriConfig;
config.displayData = displayData;
config.html = html;
