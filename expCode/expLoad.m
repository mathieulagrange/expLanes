function [data, loadFileInfo, config] = expLoad(config, name, stepId, extension, fieldSelector, contracting)
% expLoad load data from the repository of the specified processing step
%	[config data] = expLoad(config, name, stepId, extension, fieldSelector, contracting)
%	- config: expCode configuration
%	- name: name of the file
%	- stepId: step number
%	- extension: string appended at the end of the name
%	  shall end with '_data' to retrieve data or '_obs' to retrieve observations
%	- fieldSelector: string or cell array of strings containing the fields to be loaded
%	- contracting:
%	-- data: loaded data structure
%	-- loadFileInfo: time stamps of data
%	-- config: updated config

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.


if nargin<2 || isempty(name), name = ''; end
if nargin<3 || isempty(stepId), stepId=config.step.id-1; end
if nargin<4 || isempty(extension),
    if isempty(name)
        extension = '_data';
    else
        extension ='';
    end
else
    [p, n] = fileparts(extension); % FIXME may be fragile
    extension = ['_' n];
end
if ~exist('contracting', 'var'), contracting = 1; end
if ~exist('fieldSelector', 'var')
    fieldSelector=[];
elseif ~iscell(fieldSelector) && ~isempty(fieldSelector)
    fieldSelector = {fieldSelector};
end

if ~isempty(name)
    [p, n, e] = fileparts(name);
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
    if stepId
        if ~isempty(strfind(extension, '_obs')) && ~isempty(config.obsPath)
            path = [config.obsPath config.stepName{stepId} '/'];
        else
            path = [config.dataPath config.stepName{stepId} '/'];
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
        tv = expStepSetting(config.factors, m{1}, stepId);
        for k=1:tv.nbSettings
            settings{k} = expSetting(tv, k);
        end
    else
        settings{1} = config.step.setting;
    end
    
    %     settings{k}.infoString
    
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
else
    names{1} = name;
end

config.load={};

if config.dummy && stepId
    for k=1:length(names)
        dname = [names{k} '_dummy_' num2str(config.dummy) extension];
        config = loadFile(config, stepId, path, dname, fieldSelector);
    end
end
if isempty(config.load)
    for k=1:length(names)
        config = loadFile(config, stepId, path, [names{k} extension], fieldSelector);
    end
end

data = config.load;
loadFileInfo = config.loadFileInfo;

% end



function config = loadFile(config, stepId, path, name, fieldSelector)

config = loadFileName(config, [path name], stepId, fieldSelector);

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
        
        disp(['Attempting to fetch data from ' expGetMachineName(config, source(k))]);
        sourceConfig = expConfig(config.codePath, config.projectName, config.shortProjectName, {'host', source(k)});
        
        if stepId
            sourcePath = [sourceConfig.dataPath sourceConfig.stepName{stepId} '/'];
            %             sourcePath = sourceConfig.([config.stepName{stepId} 'Path']);
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
        if ispc % FIXME will not work on the other side
            command= strrep(command, 'C:', '/cygdrive/c'); % FIXME build regexp to fix
            command= strrep(command, '\', '/');
        end
        s = system(command);
        if s==0
            config = loadFileName(config, [path name], stepId, fieldSelector);
            disp('Success.');
            break;
        end
        config = loadFileName(config, [path name], stepId, fieldSelector);
    end
    if isempty(config.load)
        fprintf(2, 'Failure.');
    end
end




function config = loadFileName(config, fileName, stepId, fieldSelector)

% TODO handle stuff that are not mat files

try
    if strcmp(fileName(end-2:end), 'mat')
        
        if isempty(fieldSelector)
            loadData = load(fileName);
        else
            loadData = load(fileName, fieldSelector{:});
        end
        %         if isempty(config.load)
        %             if stepId
        %                 config.load.(loadData.stepName)=[];
        %             else
        %                 config.load.('input'){end+1} = [];
        %             end
        %         end
        %         if stepId
        %             config.load.(loadData.stepName) = [config.load.(loadData.stepName) loadData.data];
        %         else
        %             config.load.('input') = [config.load.('input') loadData];
        %         end
        %         loadData.setting
        if isempty(config.load)
%             if stepId
                config.load=[];
%             else
%                 config.load{end+1} = [];
%             end
        end
        if stepId
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
end

