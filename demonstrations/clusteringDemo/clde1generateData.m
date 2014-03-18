function [config, store, obs] = clde1generateData(config, setting, data)
% clde1generateData GENERATEDATA step of the expCode project clusteringDemo
%    [config, store, obs] = clde1generateData(config, setting, data)
%       config : expCode configuration state
%       setting: current set of parameters
%       data   : processing data stored during the previous step
%
%       store  : processing data to be saved for the other steps
%       obs: performance measures to be saved for obs

% Copyright lagrange
% Date 22-Nov-2013

if nargin==0, clusteringDemo('do', 1, 'mask', {{0 0 0 3}}); return; end

store=[];
obs=[];

switch setting.dataType
    case 'spherical'
        bandwidth = 0.1;
        data = zeros([setting.nbClasses*setting.nbElementsPerClass, 2]);
        idx = 1;
        for k = 1 : setting.nbClasses
            for n = 1 : setting.nbElementsPerClass
                theta = 2 * pi * rand;
                rho = k + randn(1) * bandwidth;
                [x, y] = pol2cart(theta, rho);
                data(idx,:) = [x, y];
                idx = idx + 1;
            end
        end
    case 'spiral'
        bandwidth = 0.1;
        data = zeros([setting.nbElementsPerClass, 2]);
        for k = 1 : setting.nbElementsPerClass
            w = k / setting.nbElementsPerClass;
            data(k,1) = (4 * w + 1) * cos(2 * pi * w) + randn(1) * bandwidth;
            data(k,2) = (4 * w + 1) * sin(2 * pi * w) + randn(1) * bandwidth;
        end
        data = [data; -data];
        setting.nbClasses = 2;
    case 'gaussian'
        data = [];
        class = [];
        for m=1:setting.nbClasses
            data = [data; repmat(m*2.5, setting.nbElementsPerClass, 2)+randn(setting.nbElementsPerClass, 2)];
        end
end

class = [];
for k = 1 : setting.nbClasses
    class = [class; k*ones(setting.nbElementsPerClass, 1)];
end

store.samples = data;
store.class = class;

% figure();
scatter(data(:, 1), data(:, 2), 20, class, 'filled')
