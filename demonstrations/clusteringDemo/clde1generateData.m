function [config, store, display] = clde1generateData(config, variant, data)
% clde1generateData GENERATEDATA task of the expCode project clusteringDemo
%    [config, store, display] = clde1generateData(config, variant, data)
%       config : expCode configuration state
%       variant: current set of parameters
%       data   : processing data stored during the previous task
%
%       store  : processing data to be saved for the other tasks
%       display: performance measures to be saved for display

% Copyright lagrange
% Date 22-Nov-2013

if nargin==0, clusteringDemo('do', 1, 'mask', {{0 0 0 3}}); return; end

disp([config.currentTaskName ' ' variant.infoString]);

store=[];
display=[];

switch variant.dataType
    case 'spherical'
        bandwidth = 0.1;
        data = zeros([variant.nbClasses*variant.nbElementsPerClass, 2]);
        idx = 1;
        for k = 1 : variant.nbClasses
            for n = 1 : variant.nbElementsPerClass
                theta = 2 * pi * rand;
                rho = k + randn(1) * bandwidth;
                [x, y] = pol2cart(theta, rho);
                data(idx,:) = [x, y];
                idx = idx + 1;
            end
        end
    case 'spiral'
        bandwidth = 0.1;
        data = zeros([variant.nbElementsPerClass, 2]);
        for k = 1 : variant.nbElementsPerClass
            w = k / variant.nbElementsPerClass;
            data(k,1) = (4 * w + 1) * cos(2 * pi * w) + randn(1) * bandwidth;
            data(k,2) = (4 * w + 1) * sin(2 * pi * w) + randn(1) * bandwidth;
        end
        data = [data; -data];
        variant.nbClasses = 2;
    case 'gaussian'
        data = [];
        class = [];
        for m=1:variant.nbClasses
            data = [data; repmat(m*2.5, variant.nbElementsPerClass, 2)+randn(variant.nbElementsPerClass, 2)];
        end
end

class = [];
for k = 1 : variant.nbClasses
    class = [class; k*ones(variant.nbElementsPerClass, 1)];
end

store.samples = data;
store.class = class;

% figure();
scatter(data(:, 1), data(:, 2), 20, class, 'filled')
