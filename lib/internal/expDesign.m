function config = expDesign(config)

% a design shall be a cell array of {factors, quantization,type of design, seed}
% seed is useful for one factor at time type of design

design = cellifydesign(config);
if isempty(design), return; end

% select factors
factors = design{1};
if isempty(factors)
    for k=1:length(config.factors.names)
        if isnumeric(config.factors.values{k}{1})
            factors(end+1) = k;
        end
    end
end
for k=1:length(factors)
    if length(config.factors.values{factors(k)})<2
        factors(k) = [];
    end
end

% define quantification steps
if isempty(design{2})
    design{2} = 2;
end

for k=1:length(factors)
    if design{2}==0
        inc = 1;
    else
        inc = floor(length(config.factors.values{factors(k)})/(design{2}-1));
    end
    steps{k} = 0:inc:(length(config.factors.values{factors(k)}));
    
    if steps{k}(2)>1
        steps{k}(1) = 1;
    else
        steps{k}(1) = [];
    end
    if steps{k}(end) ~= length(config.factors.values{factors(k)})
        steps{k}(end) = length(config.factors.values{factors(k)});
    end
end

%define seed
if length(design)<4 || isempty(design{4})
    seed = cell(1, length(config.factors.names));
else
    seed = design{4};
end

% type of design
if length(design)<3
    type = 'f';
else
    type = design{3};
end

switch type
    case {'f', 'factorial'}
        if length(design)<4 || isempty(design{4})
            seed(:) = {0};
        end
        mask = seed;
        for k=1:length(factors)
            mask{factors(k)} = steps{k};
        end
        mask = {mask};
    case {'o', 'oneFactorAtATime'}
        if length(design)<4 || isempty(design{4})
            seed(:) = {1};
        end
         mask = cell(1, length(factors));
        % one mask per factor
        for k=1:length(factors)
            m = seed;
            m{factors(k)} = steps{k};
            mask{k} = m;
        end
    otherwise
        error(['Unhandled type of design: ' design{3}]);
end

config.mask = expMergeMask(config.mask{1}, mask, config.factors.values, -1);
% FIXME clash when used in start mode with seed
% config.mask = mask;

function design = cellifydesign(config)

if ~isempty(config.design)
    if iscell(config.design)
        design = config.design;
    elseif ischar(config.design)
        switch config.design
            case 'one'
                design = {[], 2, 'o'};
            case 'star'
                design = {[], 0, 'o'};
        end
    elseif isnumeric(config.design)
        design = {[], config.design, 'f'};
    end
else
    design = {};
end



