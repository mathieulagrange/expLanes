function config = expExpose(varargin)

% TODO display variance and highlight in every plot

oriConfig = varargin{1};
config = varargin{1};
exposeType = varargin{2};

p.order = [];
p.expand = 0;
p.metric = 0;
p.parameter = [];
p.variance = 0;
p.highlight=0;
p.title='+';
p.caption='+';
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
p.legend=1;

pNames = fieldnames(p);
% overwrite default parameters with command line ones
for pair = reshape(varargin(3:end),2,[]) % pair is {propName;propValue}
    if ~any(strcmp(pair{1},strtrim(pNames))) % , length(pair{1})
        error(['Error: ' pair{1} ' is not a parameter']);
    end
    p.(pair{1}) = pair{2};
end

if p.step && p.step ~= length(config.stepName)
    config.step.id = p.step;
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

config.step = expStepDesign(config.factors, config.mask, config.step.id);
config = expReduce(config);

if isempty(config.evaluation) || isempty(config.evaluation.data)
    disp('No observations to display.');
    return
end
if ischar(p.metric)
    p.metric = find(strcmp(config.evaluation.metrics, p.metric));
    if isempty(p.metric), disp(['Unable to find parameter with name' p.metric]); end
    
end
if ~p.metric
    evaluationMetrics = config.evaluation.metrics;
else
    evaluationMetrics = config.evaluation.metrics(p.metric);
end

if p.percent
    for k=1:length(p.percent)
        if p.percent(k) <= length(evaluationMetrics)
            evaluationMetrics{p.percent(k)} =  [evaluationMetrics{p.percent(k)} ' (%)'];
        end
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
    p.expand = find(strcmp(config.step.parameters.names, p.expandName));
    oriStep = config.step;
    config.step = expStepDesign(config.factors, mask, config.step.id);
%     config.designs = tv.designs;
%     config.sequence = tv.sequence;
          config.step.oriParameters = oriStep.parameters;
end


if ~p.sort && isfield(config, 'sortDisplay')
    p.sort = config.sortDisplay;
end


data = expFilter(config, p);

if any(p.percent) % TODO submit vector
    for k=1:length(p.percent)
        if p.percent(k) <= size(data.meanData, 2)
            data.meanData(:, p.percent(k)) =  data.meanData(:, p.percent(k))*100;
            data.varData(:, p.percent(k)) =  data.varData(:, p.percent(k))*100;
        end
    end
end

p.title = strrep(p.title, '+', config.step.design.infoStringMask);
p.caption = strrep(p.caption, '=', p.title);
p.caption = strrep(p.caption, '+', config.step.design.infoStringMask);
p.caption = strrep(p.caption, '_', '\_');

if p.expand
    p.legendNames = config.step.parameters.values{p.expand};
    if ~ischar(p.legendNames)
        if isnumeric(p.legendNames{1})
            p.xAxis = cell2mat(config.step.parameters.set{p.expand});
        else
            p.xAxis = 1:length(p.legendNames);
        end
        p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false)';
    end
    p.columnNames = [config.step.parameters.names(data.parameterSelector); p.legendNames]'; % (data.parameterSelector)
    p.methodLabel = config.evaluation.metrics{p.metric};
    p.xName = p.expandName;
    p.rowNames = config.step.oriParameters.list(data.designSelector, data.parameterSelector);
else
    p.legendNames = evaluationMetrics;
    p.xName='';
    p.columnNames = [config.step.parameters.names(data.parameterSelector)' evaluationMetrics];
    p.methodLabel = '';
    p.xAxis='';
    p.rowNames = config.step.parameters.list(data.designSelector, data.parameterSelector);
end

for k=1:config.step.nbDesigns
    d = expDesign(config.step, k);
    p.labels{k} = strrep(d.infoShortStringMasked, '_', ' '); % (data.designSelector)
end
p.axisLabels = evaluationMetrics;

% displayData = config.displayData;
if p.variance == 0
    p.variance = 1:size(data.varData, 2);
end
for k=1:size(data.varData, 2)
    if ~any(p.variance==k)
        data.varData(:, k) = 0;
    end
end

config.data = data;

config.displayData.cellData=[];
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
        name = p.save;
    else
        name = strrep(p.title, ' ', '_');
    end
    switch(p.put)
        case 1
            expSaveFig(strrep([config.reportPath 'figures/' name], ' ', '_'), gcf);
        case 2
            expSaveTable([config.reportPath 'tables/' name '.tex'], config.displayData.table(end));
    end
    save([config.reportPath 'data/' name '.mat'], 'data');
end

displayData = config.displayData;
config = oriConfig;
config.displayData = displayData;
