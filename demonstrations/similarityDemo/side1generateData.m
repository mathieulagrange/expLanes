function [config, store, display] = side1generateData(config, variant, data, display)

if nargin==0, similarityDemo('do', 1, 'mask', {{}}); return; end

disp([config.currentStepName ' ' variant.infoString]);

tic

for k=1:variant.nbRealizations
    classData = [];
    class = [];
    for m=1:variant.nbClasses
        classData = [classData; repmat(m*variant.spread/20, variant.nbElementsPerClass, variant.nbDimensions)+randn(variant.nbElementsPerClass, variant.nbDimensions)];
        class = [class; m*ones(variant.nbElementsPerClass, 1)];
    end
    %     scatter(classData(:, 1), classData(:, 2), 50, class, 'filled');
    
    store.observations{k} =  classData;
    store.class{k} = class;
end

display.generationTime = toc*1000;