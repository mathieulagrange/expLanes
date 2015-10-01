function mask = expMergeMask(m, s, values, setting)

if ~isempty(m) && all(cellfun(@iscell, m))
    mask={};
    for k=1:length(m)
        mm = expMergeMask(m{k}, s, values, setting);
        if ~isempty(mm)
            mask{end+1} = mm;
        end
    end
elseif ~isempty(s) && all(cellfun(@iscell, s))
    mask={};
    for k=1:length(s)
        ss = expMergeMask(m, s{k}, values, setting);
        if ~isempty(ss)
            mask{end+1} = ss;
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
            m{k} = setting;
        else
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