function [userDefaultConfigFileName userDir] = expUserDefaultConfig(expCodePath)

if ispc, userDir= getenv('USERPROFILE');
else userDir= getenv('HOME');
end

if ~exist([userDir filesep '.expCode'], 'dir')
    mkdir([userDir filesep '.expCode']);
end

userDefaultConfigFileName = [userDir filesep '.expCode' filesep getUserName() 'Config.txt'];
if ~exist(userDefaultConfigFileName, 'file')
    disp(['Creating default config in ' userDir filesep '.expCode' filesep]);
    copyfile([expCodePath '/expCodeConfig.txt'], userDefaultConfigFileName);
else
    expUpdateConfig(userDefaultConfigFileName);
end

