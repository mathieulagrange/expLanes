function config = expDisplay(config, p)

switch p.put
    case 0
        if ~isempty(config.displayData.data)
            disp(config.displayData.data);
            config.displayData.prompt = config.displayData.data;
            config.displayData.data = [];
        end
    case 1
        for k=1:length(config.displayData.figure)
            if ~config.displayData.figure(k).taken
                config.displayData.figure(k).taken = 1;
                config.displayData.figure(k).caption = p.caption;
                config.displayData.figure(k).label = p.label;
                config.displayData.figure(k).report = p.report;
                figure(config.displayData.figure(k).handle);
                set(gcf,'name', p.title);
                set(gcf,'number','off');
                clf
                return;
            end
        end
        
        config.displayData.figure(end+1).handle = figure();
        config.displayData.figure(end).taken = 1;
        config.displayData.figure(end).caption = p.caption;
        config.displayData.figure(end).label = p.label;
        config.displayData.figure(end).report = p.report;
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


