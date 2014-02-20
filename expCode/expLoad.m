function [config data] = expLoad(config, name, inputId, extension, selector)

if nargin<2 || isempty(name), name = ''; end
if nargin<3 || isempty(inputId), inputId=config.currentStep-1; end
if nargin<4 || isempty(extension),
    extension = '_data';
else
    [p n] = fileparts(extension); % FIXME may be fragile
    extension = ['_' n];
end
if ~exist('selector', 'var')
    selector=[]; 
elseif ~iscell(selector)
    selector = {selector};
end

if ~isempty(name)
    [p n e] = fileparts(name);
    name = [p filesep n];
else
    p=[];
    e=[];
end

if isempty(e)
    extension = [extension '.mat'];
else
    extension = [extension e];
end

if isempty(p) || ~any(strcmp(p(1), {'/', '\', '~'}))
    if inputId
        path = [config.dataPath config.stepName{inputId} filesep];
    else
        path = config.inputPath;
    end
else
    path = [];
end

if nargin<2 || isempty(name)
    %     design = expDesignBuild(config.factors, config.currentDesign.infoId');
    tv = expDesigns(config.factors, {num2cell(config.currentDesign.infoId)}, inputId); % TODO slow but useful, detect if data flow is contracting
    if config.useShortNamesForFiles
        names = {tv.designs(:).infoShortString}; % FIXME should be masked
    else
        names = {tv.designs(:).infoString}; % FIXME should be masked
    end
end

config.load={};

if config.dummy && inputId
    for k=1:length(names)
        dname = [names{k} '_dummy_' num2str(config.dummy) extension];
        config = loadFile(config, inputId, path, dname, selector);
    end
end
if isempty(config.load)
    for k=1:length(names)
        config = loadFile(config, inputId, path, [names{k} extension], selector);
    end
end

data = config.load;

% end



function config = loadFile(config, inputId, path, name, selector)

config = loadFileName(config, [path name], inputId, selector);

if isempty(config.load) && config.retrieve
    source = 1;
    
    while  isempty(config.load) && source<=length(config.machineNames)
        if strcmp(config.hostName, config.machineNames{source})
            source = source+1;
            continue;
        end
        disp(['Attempting to fetch it from ' config.machineNames{source}]);
        sourceConfig = expConfig(config.codePath, config.shortProjectName, {'host', source});
        
        if inputId
            sourcePath = [sourceConfig.dataPath sourceConfig.stepName{inputId} filesep];
%             sourcePath = sourceConfig.([config.stepName{inputId} 'Path']);
        else
            sourcePath = sourceConfig.inputPath;
        end
        destDir = [path fileparts(name)];
        if ~exist(destDir, 'dir')
            mkdir(destDir);
        end
        sourceName = [sourcePath name];
        sourceName = strrep(sourceName, ' ', '\ ');
        command =  ['scp -q -r ' config.machineNames{source} ':"' sourceName '" '  path fileparts(name)];
        s = system(command);
        if s==0
            config = loadFileName(config, [path name], inputId, selector);
            disp('Success.');
            break;
        else
            source = source+1;
        end
        config = loadFileName(config, [path name], inputId, selector);
    end
    if isempty(config.load)
        disp('Failure.');
    end
end




function config = loadFileName(config, fileName, inputId, selector)

% TODO handle stuff that are not mat files

try
    if strcmp(fileName(end-2:end), 'mat')
        
        if isempty(selector)
            loadData = load(fileName);
        else
            loadData = load(fileName, selector{:});
        end
        %         if isempty(config.load)
        %             if inputId
        %                 config.load.(loadData.stepName)=[];
        %             else
        %                 config.load.('input'){end+1} = [];
        %             end
        %         end
        %         if inputId
        %             config.load.(loadData.stepName) = [config.load.(loadData.stepName) loadData.data];
        %         else
        %             config.load.('input') = [config.load.('input') loadData];
        %         end
        
        if isempty(config.load)
            if inputId
                config.load=[];
            else
                config.load{end+1} = [];
            end
        end
        if inputId
            config.load = [config.load loadData.data];
        else
            config.load = [config.load loadData];
        end
        
        fileInfo = dir(fileName);
        if fileInfo.datenum<config.loadFileInfo.dateNum(1)
            config.loadFileInfo.dateNum(1) = fileInfo.datenum;
            config.loadFileInfo.date{1} = fileInfo.date;
        end
        if fileInfo.datenum>config.loadFileInfo.dateNum(2)
            config.loadFileInfo.dateNum(2) = fileInfo.datenum;
            config.loadFileInfo.date{2} = fileInfo.date;
        end
    else
        fid = fopen(fileName, 'r');
        if fid>0
            config.load.fid=fid;
        end
    end
catch err
%     disp(err.message);
end

