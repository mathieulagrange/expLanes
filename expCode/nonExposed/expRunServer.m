function expRunServer(configMatName, codePath)

if ispc
    homePath= getenv('USERPROFILE');
else
    homePath= getenv('HOME');
end

codePath = strrep(codePath, '~', homePath); 
cd(strrep(codePath, '\', '/'));

configMatName = strrep(configMatName, '~', homePath);
load(configMatName);
delete(configMatName);
eval([config.projectName '(config)']);