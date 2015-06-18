function [data, ind] = expSortData(data, p, factorSelector, config, numData)

if ~exist('numData', 'var'), numData = []; end

if ~isempty(factorSelector)
    if p.sort
        flip=0;
        if isnumeric(p.sort)
            if iscell(data)
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
            end
        elseif ischar(p.sort)
            ind = find(strcmp(p.sort, config.step.factors.name(factorSelector)));
            if ~isempty(ind)
                p.sort = ind;
            else
                flip=1;
                ind = find(strcmp(p.sort, config.evaluation.observations));
                if ~isempty(ind)
                    p.sort = ind+length(factorSelector);
                else
                    error('can not find corresponding factor to sort');
                end
                
            end
        else
            error('unkown sort type');
        end
        if p.sort > length(factorSelector)
            col = numData.meanData(:, p.sort-length(factorSelector));
        else
            col = data(:, p.sort);            
        end
        if iscell(col)
            for k=1:length(col)
                c = regexp(col{k}, '(', 'split');
                %             col{k} = strtrim(c{1});
                col{k} = c{1};
%                 c = regexp(col{k}, '\$\\pm\$', 'split');
%                 %             col{k} = strtrim(c{1});
%                 col{k} = c{1};
%                 c = regexp(col{k}, '{', 'split');
%                 %             col{k} = strtrim(c{1});
%                 col{k} = strtrim(c{end});
            end
        end
        if lower(p.total) ==  'v'
            [bin, ind] = sort(col(1:end-1));
        else
            [bin, ind] = sort(col);
        end
        if ~strcmp(p.show, 'data')
            flip=1;
        end
        if flip
            ind = flipud(ind);
        end
        if lower(p.total) == 'v'
            ind = [ind; size(data, 1)];
        end
        data = data(ind, :);
    end
end
