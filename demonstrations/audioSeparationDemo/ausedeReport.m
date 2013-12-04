function config = ausedeReport(config)

if nargin==0, audioSeparationDemo('report', 1); return; end

% config = expExpose(config, 'l', 'label', 'toto');
config = expExpose(config, 't', 'label', 'titi', 'mask', {{0, 5, 0, 5, 6}}, 'save', 'toto');

% config= expExpose(config, 'p', 'expand', 'nbIterations', 'metric', 2, 'mask', {{2, 5, 0, 5}}, 'label', 'toto');
