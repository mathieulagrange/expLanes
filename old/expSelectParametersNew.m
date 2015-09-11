function mask = expSelectFactorsNew(factorSpecifications, mask, mode, rec)

if ~exist('mode', 'var'), mode=-1; end
if ~exist('rec', 'var'), rec=1; end

if ~isempty(factorSpecifications.selectFactors)
    % TODO iterate over same parameters filters ?
    l=1;
    c1mask = {};
    while ~isempty(factorSpecifications.selectFactors) && (l==1 || p == str2num(factorSpecifications.selectFactors{1}(1)))
        c = regexp(factorSpecifications.selectFactors{1}, '/', 'split');
        if length(c)==3
            c{4} = '0';
        end
        p = eval(c{1});
        ps = eval(c{4});
        s = eval(c{2});
        ss = eval(c{3});
        
        for k=1:length(factorSpecifications.names)
            s1mask{k} = 0;
            s2mask{k} = 0;
        end
        
        if mask{1}{s} == -1
            s1mask{p}=-1;
        else
            s1mask{p}=ps;
        end
        s1mask{s}=ss;
        
        myMask = mergeMask(mask, s1mask, factorSpecifications.values, mode);
        if ~isempty(myMask)
            c1mask = [c1mask myMask];

        end
                    l=l+1;
        factorSpecifications.selectFactors(1) = [];
    end
    s2mask{p} = -1;
    s2mask{s} = setxor(ss, 1:length(factorSpecifications.values{s}));
    
%     c2mask=c1mask;
    c2mask = mergeMask(mask, s2mask, factorSpecifications.values, mode);
    
    doit=0;
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
    mask= expSelectFactorsNew(factorSpecifications, mask, mode, rec);
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


function mask = mergeMask(m, s, values, mode)

if ~isempty(m) && all(cellfun(@iscell, m))
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
            %             if 0 %% TODO does it do the same thing ? SEEM SO
            if m{k}(1) ~= 0 && s{k}(1) ~= 0
                m{k} = intersect(m{k}, s{k});
            elseif m{k}(1) == 0 && s{k}(1) ~= 0
                m{k} = s{k};
            elseif m{k}(1) == 0
                m{k} = 1:length(values{k});
            end
            %             else
            %                 if s{k}(1) == 0
            %                     s{k} = 1:length(values{k});
            %                 end
            %                 if m{k}(1) == 0
            %                     m{k} = 1:length(values{k});
            %                 end
            %                 m{k} = intersect(m{k}, s{k});
            %             end
            if isempty(m{k})
                mask=[];
                return
            end
        end
        mask = m;
    end
end