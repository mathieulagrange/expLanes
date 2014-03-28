function config = exposeAnova(config, data, p)

nbFactors = length(data.parameterSelector);

for k=1:nbFactors
group{k} = config.step.factors.list(data.modeSelector, data.parameterSelector(k));
end

an = anovan(data.meanData, group,'model','interaction', 'display', 'off');
m = diag(an(1:nbFactors));
s=nbFactors+1;
for k=1:nbFactors
   for n=k+1:nbFactors
       m(k, n) = an(s);
       m(n, k) = an(s);
       s=s+1;
   end
end

p.columnNames = [{''}; config.step.factors.names]';
p.rowNames = config.step.factors.names(data.parameterSelector);
data.highlights = m<config.significanceThreshold;
data.meanData = m;
data.varData = [];
config = exposeTable(config, data, p);
