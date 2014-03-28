function data = expSortData(data, sortType, pSelector, config)

if ~isempty(pSelector)
    if sortType
        flip=0;
        if isnumeric(sortType)
            if sortType<0
                if abs(sortType)>length(pSelector)
                    error('can not find corresponding parameters to sort');
                else
                    sortType = abs(sortType);
                end
            else
                flip=1;
                if sortType>length(pSelector)
                    error('can not find corresponding parameters to sort');
                else
                    sortType = sortType+length(pSelector);
                end
            end
        elseif ischar(sortType)
            ind = find(strcmp(sortType, config.step.factors.name(pSelector)));
            if ~isempty(ind)
                sortType = ind;
            else
                flip=1;
                ind = find(strcmp(sortType, config.evaluation.metrics));
                if ~isempty(ind)
                    sortType = ind;
                else
                    error('can not find corresponding parameters to sort');
                end
                
            end
        else
            error('unkown sort type');
        end
        
        [bin ind] = sort(data(:, sortType));
        if flip
            ind = flipud(ind);
        end
        data = data(ind, :);
    end
end
