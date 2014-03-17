function [config, store, obs] = side1generateData(config, design, data, obs)

if nargin==0, similarityDemo('do', 1, 'mask', {{}}); return; end

store=[];
obs=[];

for k=1:design.nbRealizations
    classData = [];
    class = [];
    for m=1:design.nbClasses
        classData = [classData; repmat(m*design.spread/20, design.nbElementsPerClass, design.nbDimensions)+randn(design.nbElementsPerClass, design.nbDimensions)];
        class = [class; m*ones(design.nbElementsPerClass, 1)];
    end
    %     scatter(classData(:, 1), classData(:, 2), 50, class, 'filled');
    
    store.observations{k} =  classData;
    store.class{k} = class;
end
