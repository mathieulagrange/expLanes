function config = exposeConfusionMatrix(config, data, p)
% this function assumes that the following information is provided within
% data as fields :
%   prediction: the prediction of the classifier
%   class: the actual target (ground truth)
%   classeNames: the ids of the classes in numeric or string format


classNames = data(1).classNames;
if ~ischar(classNames(1))
    classNames = cellfun(@num2str, classNames, 'UniformOutput', false)';
end

for k=1:length(data)
    
    c = zeros(length(data(1).classNames), length(data(1).classNames));
    for m=1:size(c, 1)
        for n=1:size(c, 2)
            c(m, n) = sum((data(k).prediction==n).*(data(k).class==m));
        end
    end
    c = (1-c./sum(c(1, :)))*64;
    
    switch p.put
        case 0
            disp(data(k).setting.infoStringMasked);
            numCell = expNumToCell(c);
            if ~ischar(data(1).classNames)
                classNames = cellfun(@num2str, data(1).classNames, 'UniformOutput', false)';
            end
            config.displayData.cellData = [[{''} classNames]; classNames numCell];
            config = expDisplay(config, p);
        case 1
            p.title = data(k).setting.infoStringMasked;
            config = expDisplay(config, p);
            set(gca, 'fontsize', config.displayFontSize);
            image(c);
            set(gca, 'xtick', 1:length(classNames));
            set(gca, 'ytick', 1:length(classNames));
            set(gca, 'xticklabel', classNames);
            set(gca, 'yticklabel', classNames);
            set(gca, 'fontsize', config.displayFontSize);
            xlabel('Classes');
            ylabel('Predictions');
            colormap('gray');
        case 2
            numCell = expNumToCell(c, [], 0, 1, eye(length(classNames)));
            %             config.displayData.cellData = [{'' classNames{:}}; classNames numCell];
            config.displayData.cellData = [[{''} classNames]; classNames numCell];
            config = expDisplay(config, p);
    end
    
end