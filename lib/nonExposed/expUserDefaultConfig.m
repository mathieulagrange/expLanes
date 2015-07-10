function [userDefaultConfigFileName, userDir] = expUserDefaultConfig(defaultFileName)

% if ~exist(expLordPath, 'dir'), return; end % FIXME

if ispc, userDir= getenv('USERPROFILE');
else userDir= getenv('HOME');
end

if ~exist([userDir filesep '.expLord'], 'dir')
    mkdir([userDir filesep '.expLord']);
end

userDefaultConfigFileName = [userDir filesep '.expLord' filesep getUserName() 'Config.txt'];
if ~exist(userDefaultConfigFileName, 'file')
    disp(['Creating default config in ' userDir filesep '.expLord' filesep]);
    copyfile(defaultFileName, userDefaultConfigFileName);
else
    try
        expUpdateConfig(userDefaultConfigFileName);
    catch
        fprintf(2, 'Unable to update the default Config\n');
    end
end

