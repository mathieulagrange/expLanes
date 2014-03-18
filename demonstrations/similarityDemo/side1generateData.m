function [config, store, obs] = side1generateData(config, setting, data, obs)

if nargin==0, similarityDemo('do', 1, 'mask', {{}}); return; end

store=[];
obs=[];

for k=1:setting.nbRealizations
    classData = [];
    class = [];
    for m=1:setting.nbClasses
        classData = [classData; repmat(m*setting.spread/20, setting.nbElementsPerClass, setting.nbDimensions)+randn(setting.nbElementsPerClass, setting.nbDimensions)];
        class = [class; m*ones(setting.nbElementsPerClass, 1)];
    end
    %     scatter(classData(:, 1), classData(:, 2), 50, class, 'filled');
    
    store.observations{k} =  classData;
    store.class{k} = class;
end
