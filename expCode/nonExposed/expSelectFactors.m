function mask = expSelectFactors(factors, mask, mode, rec)

if ~exist('mode', 'var'), mode=-1; end
if ~exist('rec', 'var'), rec=1; end

if ~isempty(factors.selectFactors)
    % TODO iterate over same factors filters ?
    k=1;
    doit=0;
    c1mask = {};
    while ~isempty(factors.selectFactors) && (k==1 || p == str2num(factors.selectFactors{1}(1))) %#ok<NODEF>
        c = regexp(factors.selectFactors{1}, '/', 'split');
        if length(c)==3
            c{4} = '0';
        end
        p = eval(c{1});
        ps = eval(c{4});
        s = eval(c{2});
        ss = eval(c{3});
        doit=0; % FIXME maybe
        if ss==0
            doit=1;
        end
        
        for m=1:length(factors.names)
            s1mask{m} = 0;
            s2mask{m} = 0;
        end
        
        if mask{1}{s} == -1 % s ?? %FIXME was commented
            s1mask{p}=-1; %FIXME was commented
        else %FIXME was commented
            s1mask{p}=ps;
        end %FIXME was commented
        s1mask{s}=ss;
        
        myMask = expMergeMask(mask, s1mask, factors.values, mode);
        if ~isempty(myMask)
            c1mask = [c1mask myMask];
            
        end
        k=k+1;
        factors.selectFactors(1) = [];
    end
    
    s2mask{p} = -1;
    s2mask{s} = setxor(ss, 1:length(factors.values{s}));
    
    %     c2mask=c1mask;
    c2mask = expMergeMask(mask, s2mask, factors.values, mode);
    
    
    for k=1:length(c1mask)
        if isMyEqual(c1mask(k), c2mask)
            %             disp('true');
            doit=1;
        end
    end
    
    if doit
        mask = c1mask;
    else
        mask = [c1mask c2mask];
    end
    
    rec=rec+1;
    m={};
    for k=1:length(mask)
        m = [m expSelectFactors(factors, mask(k), mode, rec)];
    end
    mask = m;
end

function v = isMyEqual(m1, m2)

% m1
% m2
if isempty(m1) || isempty(m2)
    v=0;
    return;
end

m1=m1{1};
m2=m2{1};

v=1;
for k=1:length(m1)
    if ~all(ismember(m2{k}, m1{k})) && (m2{k}(1) ~= -1 && m1{k}(1) ~= -1)
        v=0;
        return;
    end
end

