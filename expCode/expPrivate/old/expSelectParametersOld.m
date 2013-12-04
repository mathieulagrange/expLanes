function mask = expSelectParametersOld(variantSpecifications, mask, mode, rec)

if ~exist('mode', 'var'), mode=-1; end
if ~exist('rec', 'var'), rec=1; end

if ~isempty(variantSpecifications.selectParameters)
    %     if rec==1
    %         mask = {mask};
    %     end
    % else
    c = regexp(variantSpecifications.selectParameters{1}, '/', 'split');
    if length(c)==3
        c{4} = '0';
    end
    p = eval(c{1});
    ps = eval(c{4});
    s = eval(c{2});
    ss = eval(c{3});
    
    for k=1:length(variantSpecifications.names)
        s1mask{k} = 0;
        s2mask{k} = 0;
    end
    
    s1mask{p}=ps;
    s1mask{s}=ss;
    
    s2mask{p} = -1;
    s2mask{s} = setxor(ss, 1:length(variantSpecifications.values{s}));
    
    c1mask = mergeMask(mask, s1mask, variantSpecifications.values, mode);
    c2mask = mergeMask(mask, s2mask, variantSpecifications.values, mode);
    mask = [c1mask c2mask];
    
    
    variantSpecifications.selectParameters(1) = [];
    rec=rec+1;
    mask= expSelectParameters(variantSpecifications, mask, mode, rec);
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