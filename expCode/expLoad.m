function [config data] = expLoad(config, name, inputId, extension, selector, contracting)

if nargin<2 || isempty(name), name = ''; end
if nargin<3 || isempty(inputId), inputId=config.step.id-1; end
if nargin<4 || isempty(extension),
    extension = '_data';
else
    [p n] = fileparts(extension); % FIXME may be fragile
    extension = ['_' n];
end
if ~exist('contracting', 'var'), contracting = 1; end
if ~exist('selector', 'var')
    selector=[]; 
elseif ~iscell(selector) && ~isempty(selector)
    selector = {selector};
end

if ~isempty(name)
    [p n e] = fileparts(name);
    name = [p '/' n];
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
        if ~isempty(strfind(extension, '_obs')) && ~isempty(config.obsPath)
            path = [config.obsPath config.stepName{inputId} '/'];
        else
            path = [config.dataPath config.stepName{inputId} '/'];
        end
    else
        path = config.inputPath;
    end
else
    path = [];
end

if nargin<2 || isempty(name)
    if contracting % TODO detect wich step are contracting
        m = config.mask;
        m = expMergeMask(m, {num2cell(config.step.setting.infoId)}, config.factors.values, -1);
        tv = expStepSetting(config.factors, m{1}, inputId);
        for k=1:tv.nbSettings
            settings{k} = expSetting(tv, k);
        end
    else
        settings{1} = config.step.setting;
    end
    for k=1:length(settings)
        switch config.namingConventionForFiles
            case 'short'
                names{k} = settings{k}.infoShortString; % FIXME should be masked
            case 'long'
                names{k} = settings{k}.infoString; % FIXME should be masked
            case 'hash'
                names{k} = DataHash(settings{k}.infoString); % FIXME should be masked
        end
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

if isempty(config.load) && config.retrieve>-1
    if ~config.retrieve
        source = [];
        for k=1:length(config.machineNames)
            if iscell(config.machineNames{k})
                for m=1:length(config.machineNames{k})
                    source(end+1) = k+m/10;
                end
            else
                source(end+1) = k;
            end
        end
    else
        source = config.retrieve;
    end
    source(source==config.host) = [];
    for k=1:length(source)

        disp(['Attempting to fetch it from ' expGetMachineName(config, source(k))]);
        sourceConfig = expConfig(config.codePath, config.projectName, config.shortProjectName, {'host', source(k)});
        
        if inputId
            sourcePath = [sourceConfig.dataPath sourceConfig.stepName{inputId} '/'];
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
        command =  ['scp -q -r ' expGetMachineName(config, source(k)) ':"' sourceName '" '  path fileparts(name)];
        s = system(command);
        if s==0
            config = loadFileName(config, [path name], inputId, selector);
            disp('Success.');
            break;
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
%         loadData.setting
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

