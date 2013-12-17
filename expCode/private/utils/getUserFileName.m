function configFileName = getUserFileName(projectName, projectPath)

% shortProjectName = names2shortNames(projectName);
% shortProjectName = shortProjectName{1};

userName = getUserName();

configFileName = [projectPath '/config' filesep projectName 'Config' [upper(userName(1)) userName(2:end)] '.txt'];

if ~exist(configFileName, 'file')
    defaultConfigFileName = [projectPath '/config' filesep projectName 'ConfigDefault.txt'];
    fprintf('Unable to find user specific Config file for user %s. Copying default one.\n', userName);
    copyfile(defaultConfigFileName, configFileName);
end


