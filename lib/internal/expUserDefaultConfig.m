function [userDefaultConfigFileName, userDir] = expUserDefaultConfig(defaultFileName, force)

if ~exist('force', 'var'), force = 0; end

if ispc, userDir= getenv('USERPROFILE');
else userDir= getenv('HOME');
end

if ~exist([userDir filesep '.expLanes'], 'dir')
    mkdir([userDir filesep '.expLanes']);
end

if force
    userDefaultConfigFileName = defaultFileName;
else
    userDefaultConfigFileName = [userDir filesep '.expLanes' filesep getUserName() 'Config.txt'];
end

if ~exist(userDefaultConfigFileName, 'file')
    disp(['Creating default config in ' userDir filesep '.expLanes' filesep]);
    copyfile(defaultFileName, userDefaultConfigFileName);
else
    try
        expUpdateConfig(userDefaultConfigFileName);
    catch
        fprintf(2, 'Unable to update the default Config\n');
    end
end

