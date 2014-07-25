function s = names2shortNames(names, nbc)

if nargin<2, nbc = 2;end
if ischar(names), names = {names}; end

if max(cellfun(@length, names)) < nbc,
    s = names;
else
    for k=1:length(names)
        if length(names{k}) > nbc
            % seek for spaces
            r=regexp(names{k}, ' ', 'split');
            % seek for -
            if length(r)==1
                r=regexp(names{k}, '-', 'split');
            end
            % seek for _
            if length(r)==1
                r=regexp(names{k}, '_', 'split');
            end
            % seek for capitalized
            if length(r)==1
                [r,matchend,tokenindices,matchstring,tokenstring] =regexp(names{k}, '[A-Z]', 'split');
                if ~isempty(tokenstring)
                    if length(r)==length(tokenstring)
                        delay=0;
                    else
                        delay=1;
                    end
                    
                    for l=1:length(r)
                        if l-delay>0
                            r{l} = [tokenstring{l-delay} r{l}];
                        end
                    end
                end
            end
            if length(r)==1
                s{k} = names{k}(1:nbc);
            else
                s{k} = '';
                for l=1:length(r)
                    s{k} = [s{k} lower(r{l}(1:min(nbc, length(r{l}))))];
                end
            end
        else
            s{k} = names{k};
        end
    end
    
    match = 0;
    for k=1:length(s)
        if any(strcmp(s(k+1:end), s{k}))
            match=1;
        end
    end
    if match
        s = names2shortNames(names, nbc+1);
    end
end