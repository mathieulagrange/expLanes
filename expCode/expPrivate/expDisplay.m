function config = expDisplay(config, p)

switch p.put
    case 0
        if ~isempty(config.displayData.data)
            disp(config.displayData.data);
            config.displayData.data = [];
        end
    case 1
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
        
        config.displayData.figureHandles(end+1) = figure();
        config.displayData.figureTaken(end+1) = 1;
        config.displayData.figureCaption{end+1} = p.caption;
        config.displayData.figureLabel{end+1} = p.label;
        set(gcf,'name', p.title);
        set(gcf,'number','off');
    case 2
        if ~isempty(config.displayData.data)
            config.displayData.latex(end+1).caption = p.caption;
            config.displayData.latex(end).multipage = p.multipage;
            config.displayData.latex(end).landscape = p.landscape;
            config.displayData.latex(end).data = [config.displayData.data];
            config.displayData.latex(end).label = p.label;
            config.displayData.data = [];
        end
end


