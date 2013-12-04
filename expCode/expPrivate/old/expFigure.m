function config = expFigure(config, p)



for k=1:length(config.displayData.figureTaken)
    if ~config.displayData.figureTaken(k)
        config.displayData.figureTaken(k) = 1;
        config.displayData.figureCaption{k} = p.caption;
        config.displayData.figureLabel{k} = p.label;
        figure(config.displayData.figureHandles(k));
        set(gcf,'name', p.title);
        set(gcf,'number','off');
        clf
        return;
    end
end

config.displayData.figureHandles(end+1) = figure;
config.displayData.figureTaken(end+1) = 1;
config.displayData.figureCaption{end+1} = p.caption;
config.displayData.figureLabel{end+1} = p.label;
set(gcf,'name', p.title);
set(gcf,'number','off');



