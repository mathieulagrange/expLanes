function data = expShowBest(data, p)

data.highlights(:)=0;
switch lower(p.total)
    case 'h'
        data.meanData(:, end) = sum(data.meanData(:, 1:end-1), 2);
    case 'v'
        data.meanData(end, :) = sum(data.meanData(1:end-1, :));
end
if strcmp(p.total, 'H')
    data.meanData = data.meanData(:, end);
end
if strcmp(p.total, 'V')
    data.meanData = data.meanData(end, :);
end