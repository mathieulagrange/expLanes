function config = ausedeReport(config)

if nargin==0, audioSeparationDemo('report', 1); return; end

% config = expExpose(config, 'l', 'label', 'toto', 'mask', {{1}}, 'save', 'toto');
% config = expExpose(config, 't', 'label', 'titi', 'mask', {{1}}, 'save', 'toto');
config = expExpose(config, 's', 'label', 'titi', 'mask', {{1}}, 'save', 'titi', 'metric', 1:2);

% config= expExpose(config, 'p', 'expand', 'nbIterations', 'metric', 2, 'mask', {{2, 5, 0, 5}}, 'label', 'toto');
