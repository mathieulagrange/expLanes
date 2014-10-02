function [userDefaultConfigFileName, userDir] = expUserDefaultConfig(defaultFileName)

% if ~exist(expCodePath, 'dir'), return; end % FIXME

if ispc, userDir= getenv('USERPROFILE');
else userDir= getenv('HOME');
end

if ~exist([userDir filesep '.expCode'], 'dir')
    mkdir([userDir filesep '.expCode']);
end

userDefaultConfigFileName = [userDir filesep '.expCode' filesep getUserName() 'Config.txt'];
if ~exist(userDefaultConfigFileName, 'file')
    disp(['Creating default config in ' userDir filesep '.expCode' filesep]);
    copyfile(defaultFileName, userDefaultConfigFileName);
else
    try
        expUpdateConfig(userDefaultConfigFileName);
    end
end

