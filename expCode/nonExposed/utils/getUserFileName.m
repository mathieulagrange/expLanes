function configFileName = getUserFileName(shortProjectName, projectName, projectPath, expCodePath)

% shortProjectName = names2shortNames(projectName);
% shortProjectName = shortProjectName{1};

if ~exist('expCodePath', 'var'), expCodePath = []; end

userName = getUserName();

configFileName = [projectPath '/config' filesep shortProjectName 'Config' [upper(userName(1)) userName(2:end)] '.txt'];

if ~exist(configFileName, 'file')
    if isempty(expCodePath)
        files = dir([projectPath '/config/*Config*.txt']);
        defaultFileName = [projectPath '/config/' files(1).name];
    else
        defaultFileName = [expCodePath '/expCodeConfig.txt'];
    end
    fprintf('Copying default config file for user %s from %s .\n', userName, defaultFileName);
    userDefaultConfigFileName = expUserDefaultConfig(defaultFileName);
    
    fid = fopen(userDefaultConfigFileName, 'rt');
    fidw = fopen(configFileName, 'w');
    while ~feof(fid)
        text = fgetl(fid);
        if line ~= -1
            text = strrep(text, '<projectPath>', projectPath);
            text = strrep(text, '<userName>', userName);
            text = strrep(text, '<projectName>', projectName);
            fprintf(fidw, '%s\n', text);
        end
    end
    fclose(fid);
    fclose(fidw);
    try
        open(configFileName);
    catch
        fprintf(2, 'Unable to open config file.');
    end
    disp(['Please update the file ' configFileName ' to suit your needs.']);
end