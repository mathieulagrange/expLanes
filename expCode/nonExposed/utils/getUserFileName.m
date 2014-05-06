function configFileName = getUserFileName(projectName, projectPath)

% shortProjectName = names2shortNames(projectName);
% shortProjectName = shortProjectName{1};

userName = getUserName();

configFileName = [projectPath '/config' filesep projectName 'Config' [upper(userName(1)) userName(2:end)] '.txt'];

if ~exist(configFileName, 'file')
    userDefaultConfigFileName = expUserDefaultConfig();
    fprintf('Copying default config file for user %s.\n', userName);
    
    fid = fopen(userDefaultConfigFileName, 'rt');
    fidw = fopen(configFileName, 'w');
    while ~feof(fid)
        text = fgetl(fid);
        if line ~= -1
            text = strrep(text, '<<>>', projectPath);
            text = strrep(text, '<>', projectName);
            fprintf(fidw, '%s\n', text);
        end
    end
    fclose(fid);
    fclose(fidw);    
    open(configFileName);
    disp(['Please update the file ' configFileName ' to suit your needs.']);    
end

