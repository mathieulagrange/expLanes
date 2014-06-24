function config = expExpose(varargin)

% TODO display variance and highlight in every plot

oriConfig = varargin{1};
config = varargin{1};
exposeType = varargin{2};

p.order = [];
p.expand = 0;
p.obs = 0;
p.variance = 0;
p.highlight=0;
p.title='+';
p.caption='+';
p.multipage=0;
p.landscape=0;
p.sort=-1;
p.mask={};
p.step=0;
p.label='';
p.put=1;
p.save=0;
p.report=1;
p.percent=-1;
p.legend='BestOutSide';
p.integrate=0;
p.total=0;
p.add=[];
p.orientation='v';
p.shortObservations = -1;
p.type='';
p.fontSize='';

pNames = fieldnames(p);
% overwrite default factors with command line ones
for pair = reshape(varargin(3:end),2,[]) % pair is {propName;propValue}
    if ~any(strcmp(pair{1},strtrim(pNames))) % , length(pair{1})
        error(['Error: ' pair{1} ' is not a valid parameter']);
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

if ~expCheckMask(config.factors, config.mask)
    mask = cell(1, length(config.factors.names));
    [mask{:}] = deal(-1);
    config.mask = {mask};
end

config.step = expStepSetting(config.factors, config.mask, config.step.id);

config = expReduce(config);

if isempty(config.evaluation) || isempty(config.evaluation.data)  || isempty(config.evaluation.data{1})
    disp('No observations to display.');
    return
end
if ischar(p.obs)
    p.obs = find(strcmp(config.evaluation.observations, p.obs));
    if isempty(p.obs), disp(['Unable to find observation with name' p.obs]); end
end
if ~p.obs
    p.obs = 1:length(config.evaluation.observations);
end
evaluationObservations = config.evaluation.observations;
if p.percent ~= -1
    if p.percent==0
        p.percent = 1:length(evaluationObservations);
    end
    for k=1:length(p.percent)
        if p.percent(k) <= length(evaluationObservations)
            evaluationObservations{p.percent(k)} =  [evaluationObservations{p.percent(k)} ' (%)'];
        end
    end
end
if ~isempty(evaluationObservations)
    evaluationObservations = evaluationObservations(p.obs);
end

if p.shortObservations == 0
    p.shortObservations = 1:length(evaluationObservations);
end
if p.shortObservations ~= -1
    for k=1:length(p.shortObservations)
        evaluationObservations(p.shortObservations(k)) =  names2shortNames(evaluationObservations(p.shortObservations(k)), 3);
    end
end

if ~isempty(p.order) || any(p.expand ~= 0)
    if ~isempty(p.order)
        order = p.order;
    else
        order = 1:length(config.factors.names);
    end
    if any(p.expand ~= 0)
        [null expand] = expModifyExposition(config, p.expand);
        if order(end) ~= expand
            order(expand) = length(order);
            order(end) = expand;
        end
    end
    config = expOrder(config, order);
end

% if any(p.integrate) && p.expand
%    error('Cannot use intergate and expand at the same time.');
% end

% if any(p.percent)
%     for k=1:length(p.percent)
%         if p.percent(k) <= size(data.meanData, 2)
%             data.meanData(:, p.percent(k)) =  data.meanData(:, p.percent(k))*100;
%             data.varData(:, p.percent(k)) =  data.varData(:, p.percent(k))*100;
%         end
%     end
% end

if any(p.percent>0)
    observations = config.evaluation.observations;
    for k=1:length(p.percent)
        for m=1:length(config.evaluation.results)
            if ~isempty(config.evaluation.results{m}) && all(config.evaluation.results{m}.(observations{p.percent(k)})<=1) % TODO remove when done
                config.evaluation.results{m}.(observations{p.percent(k)}) = 100*config.evaluation.results{m}.(observations{p.percent(k)});
            end
        end
    end
end

data = {};
if iscell(p.integrate) || any(p.integrate ~= 0),
    [config p.integrate p.integrateName] = expModifyExposition(config, p.integrate);
    pi=p;
    pi.expand = 0;
    data = expFilter(config, pi);
elseif isnumeric(p.expand) && ~p.expand
    data = expFilter(config, p);
end

if p.expand,
    if (isnumeric(p.expand) && length(p.expand)>1) || iscell(p.expand), error('Please choose only one factor to expand.'); end
    [config p.expand p.expandName] = expModifyExposition(config, p.expand);
    
    pe=p;
    pe.integrate = 0;
    if ~isempty(data)
        data = expFilter(config, pe, data.rawData);
    else
        data = expFilter(config, pe);
    end
end

if ~p.sort && isfield(config, 'sortDisplay')
    p.sort = config.sortDisplay;
end

p.title = strrep(p.title, '+', config.step.setting.infoStringMask); % TODO not meaningful anymore
p.caption = strrep(p.caption, '=', p.title);
p.caption = strrep(p.caption, '+', config.step.setting.infoStringMask);
p.caption = strrep(p.caption, '_', '\_');

p.legendNames = evaluationObservations;

p.xName='';
p.columnNames = [config.step.factors.names(data.factorSelector)' evaluationObservations];
p.factorNames = config.step.factors.names(data.factorSelector)';
p.obsNames = evaluationObservations;
p.methodLabel = '';
p.xAxis='';
p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector);

if p.integrate
    if ~ischar(p.legendNames)
        if isnumeric(p.legendNames{1})
            p.xAxis = cell2mat(config.step.factors.set{p.expand});
        else
            p.xAxis = 1:length(p.legendNames);
        end
        p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false)';
    end
    p.columnNames = [config.step.factors.names(data.factorSelector); p.legendNames]'; % (data.factorSelector)
    p.obsNames = p.legendNames;
    p.methodLabel = config.evaluation.observations(p.obs);
    p.xName = p.integrateName;
    p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector); %config.step.oriFactors.list(data.settingSelector, data.factorSelector);
end

if p.expand
    if length(p.obs)>1
        nbModalities = length(config.step.oriFactors.values{p.expand});
        for k=1:nbModalities
            for m=1:length(p.obs)
                p.legendNames(1, (k-1)*length(p.obs)+m) = {''};
                p.legendNames(2, (k-1)*length(p.obs)+m) = evaluationObservations(m);
            end
            p.legendNames(1, (k-1)*length(p.obs)+floor(length(p.obs)/2)) = config.step.oriFactors.values{p.expand}(k);
        end
    else
        p.legendNames = config.step.oriFactors.values{p.expand};
    end
    if ~ischar(p.legendNames)
        if isnumeric(p.legendNames{1})
            p.xAxis = cell2mat(config.step.factors.set{p.expand});
        else
            p.xAxis = 1:length(p.legendNames);
        end
        p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false)';
    end
    if length(p.obs)>1
        el = cell(1, length(config.step.factors.names(data.factorSelector)));
        [el{:}] = deal('');
        p.columnNames = [[el; config.step.factors.names(data.factorSelector)'] p.legendNames']; % (data.factorSelector)
        %         p.factorNames = [el; config.step.factors.names(data.factorSelector)'];
    else
        p.columnNames = [config.step.factors.names(data.factorSelector); p.legendNames]'; % (data.factorSelector)
    end
    p.methodLabel = config.evaluation.observations(p.obs);
    p.xName = p.expandName;
    p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector); %config.step.oriFactors.list(data.settingSelector, data.factorSelector);
end

%
% if p.expand || any(p.integrate)
%     if ~p.integrate
%         p.legendNames = config.step.oriFactors.values{p.expand};
%     end
%     if ~ischar(p.legendNames)
%         if isnumeric(p.legendNames{1})
%             p.xAxis = cell2mat(config.step.factors.set{p.expand});
%         else
%             p.xAxis = 1:length(p.legendNames);
%         end
%         p.legendNames = cellfun(@num2str, p.legendNames, 'UniformOutput', false)';
%     end
%     p.columnNames = [config.step.factors.names(data.factorSelector); p.legendNames]'; % (data.factorSelector)
%    % p.columnNames = [config.step.factors.names; p.legendNames]'; % (data.factorSelector)
%     p.methodLabel = config.evaluation.observations(p.obs);
% if p.expand
%     p.xName = p.expandName;
% else
%      p.xName = p.integrateName;
% end
%     p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector); %config.step.oriFactors.list(data.settingSelector, data.factorSelector);
% else
%     p.xName='';
%     p.columnNames = [config.step.factors.names(data.factorSelector)' evaluationObservations];
%     p.methodLabel = '';
%     p.xAxis='';
%     p.rowNames = config.step.factors.list(data.settingSelector, data.factorSelector);
% end

if p.total
    for k=1:size(p.rowNames, 2)
        if k==1
            p.rowNames{end+1, k} = 'Average';
        else
            p.rowNames{end, k} = '';
        end
    end
end

for k=1:config.step.nbSettings
    d = expSetting(config.step, k);
    if ~isempty(d.infoShortStringMasked)
        p.labels{k} = strrep(d.infoShortStringMasked, '_', ' '); % (data.settingSelector)
    end
end
p.axisLabels = evaluationObservations;

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
    if any(strcmp(exposeType, config.evaluation.structObservations))
        data = config.evaluation.structResults.(exposeType);
    end
    if ~strcmp(exposeType(1:min(6, length(exposeType))), 'expose')
        exposeType = ['expose' upper(exposeType(1)) exposeType(2:end)];
        
        if exist(exposeType) ~= 2
            disp(['Unable to find ' exposeType  ' in your path. This function is needed to display the observation ' exposeType(7:end) '.']);
            if inputQuestion('Do you want to create it ?');
                functionString = char({...
                    ['function config = ' exposeType '(config, data, p)'];
                    ['% ' exposeType ' EXPOSE of the expCode project ' config.projectName];
                    ['%    config = ' exposeType '(config, data, p)'];
                    '%       config : expCode configuration state';
                    '%       data : observations as a struct array';
                    '%       p : various display information';
                    '';
                    ['% Copyright: ' config.completeName];
                    ['% Date: ' date()];
                    '';
                    'p';
                    'data';
                    '';
                    });
                dlmwrite([config.codePath '/' exposeType '.m'], functionString,'delimiter','');
            end
        end
        
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
