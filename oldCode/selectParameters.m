function config = selectParameters(config, mode)

config.selectParameters =  config.factors.selectParameters;
config= selectParametersRecursive(config, mode);
config = rmfield(config, 'selectParameters');

function config = selectParametersRecursive(config, mode)

if ~isempty(config.selectParameters)
    
    c = regexp(config.selectParameters{1}, '/', 'split');
    if length(c)==3
        c{4} = '0';
    end
    p = eval(c{1});
    ps = eval(c{4});
    s = eval(c{2});
    ss = eval(c{3});
    
    for k=1:length(config.factors.names)
        s1mask{k} = 0;
        s2mask{k} = 0;
    end
    
    s1mask{p}=ps;
    s1mask{s}=ss;
    
    s2mask{p} = -1;
    s2mask{s} = setxor(ss, 1:length(config.factors.values{s}));
    
    c1=config;
    c2=config;
    
    c1mask = c1.mask;
    c2mask = c2.mask;
    
    c1.mask = mergeMask(c1mask, s1mask, config.factors.values, mode);
    c2.mask = mergeMask(c2mask, s2mask, config.factors.values, mode);
    
    % c1.mask
    % c2.mask
    
    config.mask = [c1.mask c2.mask];
    config.selectParameters(1) = [];
    config= selectParametersRecursive(config, mode);
end

function mask = mergeMask(m, s, values, mode)

if ~isempty(m) && iscell(m{1})
    mask={};
    for k=1:length(m)
        mm = mergeMask(m{k}, s, values, mode);
        if ~isempty(mm)
            mask{end+1} = mm;
        end
    end
else
    if length(m)>length(s)
        s = [s num2cell(zeros(1, length(m)-length(s)))];
    elseif length(m)<length(s)
        m = [m num2cell(zeros(1, length(s)-length(m)))];
    end
    
    for k=1:length(m)
        if  s{k}(1) == -1 || m{k}(1) == -1
            m{k} = mode;
        else
            if s{k}(1) == 0
                s{k} = 1:length(values{k});
            end
            if m{k}(1) == 0
                m{k} = 1:length(values{k});
            end
            m{k} = intersect(m{k}, s{k});
            if isempty(m{k})
                mask=[];
                return
            end
        end
        mask = m;
    end
end