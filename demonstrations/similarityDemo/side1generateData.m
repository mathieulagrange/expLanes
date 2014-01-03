function [config, store, display] = side1generateData(config, mode, data, display)

if nargin==0, similarityDemo('do', 1, 'mask', {{}}); return; end

disp([config.currentStepName ' ' mode.infoString]);

tic

for k=1:mode.nbRealizations
    classData = [];
    class = [];
    for m=1:mode.nbClasses
        classData = [classData; repmat(m*mode.spread/20, mode.nbElementsPerClass, mode.nbDimensions)+randn(mode.nbElementsPerClass, mode.nbDimensions)];
        class = [class; m*ones(mode.nbElementsPerClass, 1)];
    end
    %     scatter(classData(:, 1), classData(:, 2), 50, class, 'filled');
    
    store.observations{k} =  classData;
    store.class{k} = class;
end

display.generationTime = toc*1000;