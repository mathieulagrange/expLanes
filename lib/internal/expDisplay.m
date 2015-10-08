function config = expDisplay(config, p)

switch p.put
    case 0
        if ~isempty(config.displayData.cellData)
            disp(config.displayData.cellData);
            config.displayData.prompt = config.displayData.cellData;
            config.displayData.cellData = [];
        end
    case 1
        config.displayData.style(end+1)=0;
        for k=1:length(config.displayData.figure)
            if ~config.displayData.figure(k).taken
                config.displayData.figure(k).taken = 1;
                config.displayData.figure(k).caption = p.caption;
                config.displayData.figure(k).label = p.label;
                %      config.displayData.figure(k).data = config.data;
                config.displayData.figure(k).report = p.report;
                figure(config.displayData.figure(k).handle);
                if ~p.visible
                    set(gcf, 'Visible', 'off');
                end
                set(gcf,'name', p.title);
                set(gcf,'NumberTitle','off');
                clf
                return;
            end
        end
        
        if p.visible
            h = figure();
            if ~isnumeric(h)
                h=h.Number;
            end
            config.displayData.figure(end+1).handle = h;
        else
            h = figure('Visible', 'off');
            if ~isnumeric(h)
                h=h.Number;
            end
            config.displayData.figure(end+1).handle = h;
        end
        config.displayData.figure(end).taken = 1;
        config.displayData.figure(end).caption = p.caption;
        config.displayData.figure(end).label = p.label;
        %   config.displayData.figure(end).data = config.data;
        config.displayData.figure(end).report = p.report;
        set(gcf,'name', p.title);
        set(gcf,'NumberTitle','off');
    case 2
        if ~isempty(config.displayData.cellData)
            config.displayData.style(end+1)=1;
            config.displayData.table(end+1).caption = p.caption;
            config.displayData.table(end).multipage = p.multipage;
            config.displayData.table(end).landscape = p.orientation(1) == 'h';
            if length(config.displayData.table)>1 && ~isempty(p.mergeDisplay)
                previous = config.displayData.table(end-1).table;
                next = config.displayData.cellData;
                
                if size(previous, 1) > size(next, 1)
                    padding = cell(size(previous, 1)-size(next, 1), size(previous, 2));
                    padding(:) = {''};
                    next = [padding; next] ;
                elseif size(previous, 1) < size(next, 1)
                    padding = cell(size(next, 1)-size(previous, 1), size(previous, 2));
                    padding(:) = {''};
                    previous = [padding; previous] ;
                end
                if size(previous, 2) > size(next, 2)
                    padding = cell(size(previous, 1), size(previous, 2)-size(next, 2));
                    padding(:) = {''};
                    next = [padding next] ;
                elseif size(previous, 2) < size(next, 2)
                    padding = cell(size(previous, 1), size(next, 2)-size(previous, 2));
                    padding(:) = {''};
                    previous = [padding previous] ;
                end
                
                if p.mergeDisplay == 'v'
                    config.displayData.table(end).table = [previous; next];
                else
                    config.displayData.table(end).table = [previous next];
                end
            else
                config.displayData.table(end).table = config.displayData.cellData;
            end
            %    config.displayData.table(end).data = config.data;
            config.displayData.table(end).label = p.label;
            config.displayData.table(end).fontSize = p.fontSize;
            config.displayData.table(end).nbFactors = length(p.factorNames);
            config.displayData.cellData = [];
        end
end


