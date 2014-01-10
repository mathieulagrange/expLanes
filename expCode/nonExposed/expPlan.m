function config = expPlan(config)

% a plan shall be a cell array of {factors, quantization,type of plan, seed}
% seed is useful for one factor at time type of plan

plan = cellifyPlan(config);
if isempty(plan)
    mask = {};
    return;
end

% select factors
factors = plan{1};
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
if isempty(plan{2})
    plan{2} = 2;
end

for k=1:length(factors)
    if plan{2}==0
        inc = 1;
    else
        inc = floor(length(config.factors.values{factors(k)})/(plan{2}-1));
    end
    steps{k} = 0:inc:(length(config.factors.values{factors(k)}));
    
    if steps{k}(2)>1
        steps{k}(1) = 1;
    else
        steps{k}(1) = [];
    end
end

%define seed
if length(plan)<4 || isempty(plan{4})
    seed = cell(1, length(config.factors.names));
else
    seed = plan{4};
end

% type of plan
if length(plan)<3
    type = 'f';
else
    type = plan{3};
end

switch type
    case {'f', 'factorial'}
        seed(:) = {0};
        mask = seed;
        for k=1:length(factors)
            mask{factors(k)} = steps{k};
        end
    case {'o', 'oneFactorAtATime'}
        seed(:) = {1};
        % one mask per factor
        for k=1:length(factors)
            m = seed;
            m{factors(k)} = steps{k};
            mask{k} = m;
        end
    otherwise
        error(['Unhandled type of plan: ' plan{3}]);
end

config.mask = expMergeMask(config.mask, mask, config.factors.values, -1);


function plan = cellifyPlan(config)

if ~isempty(config.plan)
    if iscell(config.plan)
        plan = config.plan;
    elseif ischar(config.plan)
        switch config.plan
            case 'one'
                plan = {[], 2, 'o'};
            case 'star'
                plan = {[], 0, 'o'};
        end
    elseif isnumeric(config.plan)
        plan = {[], config.plan, 'f'};
    end
else
    plan = {};
end



