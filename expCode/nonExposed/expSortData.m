function data = expSortData(data, p, factorSelector, config)

if ~isempty(factorSelector)
    if p.sort
        flip=0;
        if isnumeric(p.sort)
            if p.sort<0
                if abs(p.sort)>length(factorSelector)
                    error('can not find corresponding factor to sort');
                else
                    p.sort = abs(p.sort);
                end
            else
                flip=1;
                if p.sort>length(factorSelector)
                    error('can not find corresponding factor to sort');
                else
                    p.sort = p.sort+length(factorSelector);
                end
            end
        elseif ischar(p.sort)
            ind = find(strcmp(p.sort, config.step.factors.name(factorSelector)));
            if ~isempty(ind)
                p.sort = ind;
            else
                flip=1;
                ind = find(strcmp(p.sort, config.evaluation.metrics));
                if ~isempty(ind)
                    p.sort = ind;
                else
                    error('can not find corresponding factor to sort');
                end
                
            end
        else
            error('unkown sort type');
        end
        
        if p.total
            [bin ind] = sort(data(1:end-1, p.sort));
        else
            [bin ind] = sort(data(:, p.sort));
        end
        if flip
            ind = flipud(ind);
        end
        if p.total
            ind = [ind; size(data, 1)];
        end
        data = data(ind, :);
    end
end
