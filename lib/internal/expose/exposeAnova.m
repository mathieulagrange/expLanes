function config = exposeAnova(config, data, p)

if size(data, 2)>2, error('Please choose one observation'); end

nbFactors = length(data.factorSelector);

for k=1:nbFactors
    group{k} = config.step.factors.list(data.settingSelector, data.factorSelector(k));
end

an = anovan(data.meanData(:, 1), group,'model','interaction', 'display', 'off');
m = diag(an(1:nbFactors));
s=nbFactors+1;
for k=1:nbFactors
    for n=k+1:nbFactors
        m(k, n) = an(s);
        m(n, k) = an(s);
        s=s+1;
    end
end

p.columnNames = [{''}; config.step.factors.names(data.factorSelector)]';
p.factorNames = [{''}; config.step.factors.names(data.factorSelector)]';
p.rowNames = config.step.factors.names(data.factorSelector);
data.highlights = m<config.significanceThreshold;
data.meanData = m;
data.stdData = [];
config = exposeTable(config, data, p);
