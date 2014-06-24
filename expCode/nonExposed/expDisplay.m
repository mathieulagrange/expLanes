function config = expDisplay(config, p)

switch p.put
    case 0
        if ~isempty(config.displayData.cellData)
            disp(config.displayData.cellData);
            config.displayData.prompt = config.displayData.cellData;
            config.displayData.cellData = [];
        end
    case 1
        for k=1:length(config.displayData.figure)
            if ~config.displayData.figure(k).taken
                config.displayData.figure(k).taken = 1;
                config.displayData.figure(k).caption = p.caption;
                config.displayData.figure(k).label = p.label;
                config.displayData.figure(k).data = config.data;
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
        config.displayData.figure(end).data = config.data;
        config.displayData.figure(end).report = p.report;
        set(gcf,'name', p.title);
        set(gcf,'number','off');
    case 2
        if ~isempty(config.displayData.cellData)
            config.displayData.table(end+1).caption = p.caption;
            config.displayData.table(end).multipage = p.multipage;
            config.displayData.table(end).landscape = p.landscape;
            config.displayData.table(end).table = config.displayData.cellData;
            config.displayData.table(end).data = config.data;
            config.displayData.table(end).label = p.label;
            config.displayData.table(end).fontSize = p.fontSize;
            config.displayData.cellData = [];
        end
end


