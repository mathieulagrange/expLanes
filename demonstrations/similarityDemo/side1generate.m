function [config, store, obs] = side1generate(config, setting, data)
% side1generate GENERATE step of the expCode project similarityDemo
%    [config, store, obs] = side1generate(config, setting, data)
%     - config : expCode configuration state
%     - setting   : set of factors to be evaluated
%     - data   : processing data stored during the previous step
%     -- store  : processing data to be saved for the other steps
%     -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 30-Jun-2014

% Set behavior for debug mode
if nargin==0, similarityDemo('do', 1, 'mask', {0 3 1 10}, 'plot', 1); return; else store=[]; obs=[]; end

for k=1:setting.nbRealizations
    classData = [];
    class = [];
    for m=1:setting.nbClasses
        classData = [classData; repmat(m*setting.spread/20, setting.nbElementsPerClass, setting.nbDimensions)+randn(setting.nbElementsPerClass, setting.nbDimensions)];
        class = [class; m*ones(setting.nbElementsPerClass, 1)];
    end
    
    if k==1 && isfield(config, 'plot')
        scatter(classData(:, 1), classData(:, 2), 50, class, 'filled');
        config = expExpose(config, '', 'save', 'scatter');
    end
    
    store.elements{k} =  classData;
    store.class{k} = class;
end