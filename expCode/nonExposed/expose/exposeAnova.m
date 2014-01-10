function config = exposeAnova(config, data, p)

nbFactors = length(data.parameterSelector);

for k=1:nbFactors
group{k} = config.parameters.list(data.modeSelector, data.parameterSelector(k));
end

an = anovan(data.meanData, group,'model','interaction', 'display', 'off');
m = diag(an(1:3));
s=nbFactors+1;
for k=1:nbFactors
   for n=k+1:nbFactors
       m(k, n) = an(s);
       m(n, k) = an(s);
       s=s+1;
   end
end

p.columnNames = [{''}; config.parameters.names]';
p.rowNames = config.parameters.names(data.parameterSelector);
data.highlights = m<config.significanceThreshold;
data.meanData = m;
data.varData = [];
config = exposeTable(config, data, p);
