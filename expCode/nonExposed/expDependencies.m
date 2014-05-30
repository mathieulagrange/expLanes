function expDependencies(config)

p = fileparts(mfilename('fullpath'));
addpath(genpath(p));

if config.localDependencies == 0 || config.localDependencies == 2
    for k=1:length(config.dependencies)
        dependencyPath = config.dependencies{k};
        if dependencyPath(1) == '.'
            dependencyPath = [p filesep dependencyPath];
        elseif dependencyPath(1) == '~'
            dependencyPath = expandHomePath(dependencyPath);
        end
        addpath(genpath(dependencyPath));
    end
end

