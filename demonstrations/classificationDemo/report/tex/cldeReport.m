function config = cldeReport(config)

if nargin==0, classificationDemo('show', -1, 'report', 1); return; end

config = expExpose(config, 'confusionMatrix', 'mask', {1 1 1 1 1 1:2}, 'put', 0);