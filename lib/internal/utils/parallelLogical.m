import java.lang.*;
r=Runtime.getRuntime;
ncpu=r.availableProcessors;

if ncpu>12
    ncpu=12;
end

myCluster = parcluster('local');
myCluster.NumWorkers = ncpu;  % 'Modified' property now TRUE
saveProfile(myCluster);    % 'local' profile now updated,
% 'Modified' property now FALSE