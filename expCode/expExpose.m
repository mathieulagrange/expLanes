function config = expExpose(varargin)

% TODO display variance and highlight in every plot

oriConfig = varargin{1};
config = varargin{1};
exposeType = varargin{2};

p.order = [];
p.expand = 0;
p.metric = 0;
p.parameter = [];
p.variance = 1;
p.highlight=1;
p.title='+';
p.caption='=';
p.multipage=0;
p.landscape=0;
p.sort=0;
p.mask={};
p.step=0;
p.label='';
p.put=1;
p.save=0;
p.report=1;
p.percent=0;

pNames = fieldnames(p);
% overwrite default parameters with command line ones
for pair = reshape(varargin(3:end),2,[]) % pair is {propName;propValue}
    if ~any(strcmp(pair{1},strtrim(pNames))) % , length(pair{1})
        error(['Error: ' pair{1} ' is not a parameter']);
    end
    p.(pair{1}) = pair{2};
end

if p.step && p.step ~= length(config.stepName)
    config.currentStep = p.step;
end

if ~isempty(p.mask) && ~isequal(p.mask, config.mask)
    config.mask = p.mask;
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

config.stepModes{config.currentStep} = expModes(config.factors, config.mask, config.currentStep);
config = expSetStep(config);
config = expReduce(config);

if isempty(config.evaluation)
    return
end
if ischar(p.metric)
    p.metric = find(strcmp(config.evaluation.metrics, p.metric));
    if isempty(p.metric), disp(['Unable to find parameter with name' p.metric]); end
    
elseif ~p.metric
    evaluationMetrics = config.evaluation.metrics;
else
evaluationMetrics = config.evaluation.metrics(p.metric);
end

if p.percent
    for k=1:length(p.percent)
        evaluationMetrics{p.percent(k)} =  [evaluationMetrics{p.percent(k)} ' (%)'];
    end
end

if ~isempty(p.order),
    config = expOrder(config, p.order);
end
if p.expand,
    if ~isnumeric(p.expand)
        p.expand = find(strcmp(config.factors.names, p.expand));
        if isempty(p.expand)
            error('Unable to find expand parameter.');
        end
    end
    p.expandName = config.factors.names{p.expand};
    mask = config.mask;
    for k=1:length(mask)
        if sum(size(mask{k}))<p.expand
            mask{k} = [mask{k} num2cell(zeros(1,  p.expand-length(mask{k})))];
        end
        mask{k}{p.expand} = -1;
    end
    tv = expModes(config.factors, mask, config.currentStep);
    config.modes = tv.modes;
    config.sequence = tv.sequence;
    %      config.parameters = tv.parameters;
    p.expand = find(strcmp(config.parameters.names, p.expandName));
end


if ~p.sort && isfield(config, 'sortDisplay')
    p.sort = config.sortDisplay;
end

data = expFilter(config, p.expand, p.metric);

if any(p.percent) % TODO submit vector
    for k=1:length(p.percent)
        data.meanData(:, k) =  data.meanData(:, k)*100;
        data.varData(:, k) =  data.varData(:, k)*100;
    end
end

p.title = strrep(p.title, '+', config.modes(1).infoStringMask);
p.caption = strrep(p.caption, '=', p.title);
p.caption = strrep(p.caption, '+', config.modes(1).infoStringMask);
p.caption = strrep(p.caption, '_', '\_');

if data.parameterExpand
    p.legendNames = config.parameters.values{data.parameterExpand};
    if ~ischar(p.legendNames)
        if isnumeric(p.legendNames{1})
            p.xAxis = cell2mat(config.parameters.set{data.parameterExpand});
        else
            p.xAxis = 1:length(p.legendNames);
        end
        p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false)';
    end
    p.columnNames = [config.parameters.names(data.parameterSelector); p.legendNames]'; % (data.parameterSelector)
    p.methodLabel = config.evaluation.metrics{data.metricSelector};
    p.xName = p.expandName;
    p.rowNames = config.parameters.list(data.modeSelector, data.parameterSelector);
else
    p.legendNames = evaluationMetrics;
    p.xName='';
    p.columnNames = [config.parameters.names(data.parameterSelector)' evaluationMetrics];
    p.methodLabel = '';
    p.xAxis='';
    p.rowNames = config.parameters.list(data.modeSelector, data.parameterSelector);
end

for k=1:length(config.modes)
    p.labels{k} = strrep(config.modes(k).infoShortStringMasked, '_', ' '); % (data.modeSelector)
end
p.axisLabels = evaluationMetrics;

% displayData = config.displayData;

if p.variance==0
    data.varData = 0;
end

config.displayData.data=[];
if length(exposeType)==1
    switch exposeType
        case '>'
            exposeType = 'exposeTable';
            p.put=0;
        case 'l'
            exposeType = 'exposeTable';
            p.put=2;
        case 't'
            exposeType = 'exposeTable';
        case 'b'
            exposeType = 'exposeBar';
        case 'p'
            exposeType = 'exposeLinePlot';
        case 's'
            exposeType = 'exposeScatter';
        case 'x'
            exposeType = 'exposeBoxPlot';
        case 'a'
            exposeType = 'exposeAnova';
        otherwise
            error(['unknown display type: ' exposeType]);
    end
else
    if any(strcmp(exposeType, config.evaluation.structMetrics))
        data = config.evaluation.structResults.(exposeType);
    end
    if ~strcmp(exposeType(1:6), 'expose')
        exposeType = ['expose' upper(exposeType(1)) exposeType(2:end)];
    end
    
end
% config = expDisplay(config, p);
config = feval(exposeType, config, data, p);

if any(p.put==[0 2])
    config = expDisplay(config, p);
end
if p.save ~= 0
    if ischar(p.save)
        if p.put==1
            expSaveFig([config.reportPath 'figures/' p.save], gcf);
        elseif p.put==2
           expSaveTable([config.reportPath 'tables/' p.save '.tex'], config.displayData.latex(end)); 
        end
    else
        if p.put==1
            expSaveFig(strrep([config.reportPath 'figures/' p.title], ' ', '_'), gcf);
        elseif p.put==2
              expSaveTable([config.reportPath 'tables/' p.save '.tex'], config.displayData.latex(end));          
        end
    end 
end

displayData = config.displayData;
config = oriConfig;
config.displayData = displayData;
