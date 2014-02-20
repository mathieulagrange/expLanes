function [config, store, obs] = clde1generateData(config, design, data)
% clde1generateData GENERATEDATA step of the expCode project clusteringDemo
%    [config, store, obs] = clde1generateData(config, design, data)
%       config : expCode configuration state
%       design: current set of parameters
%       data   : processing data stored during the previous step
%
%       store  : processing data to be saved for the other steps
%       obs: performance measures to be saved for obs

% Copyright lagrange
% Date 22-Nov-2013

if nargin==0, clusteringDemo('do', 1, 'mask', {{0 0 0 3}}); return; end

disp([config.currentStepName ' ' design.infoString]);

store=[];
obs=[];

switch design.dataType
    case 'spherical'
        bandwidth = 0.1;
        data = zeros([design.nbClasses*design.nbElementsPerClass, 2]);
        idx = 1;
        for k = 1 : design.nbClasses
            for n = 1 : design.nbElementsPerClass
                theta = 2 * pi * rand;
                rho = k + randn(1) * bandwidth;
                [x, y] = pol2cart(theta, rho);
                data(idx,:) = [x, y];
                idx = idx + 1;
            end
        end
    case 'spiral'
        bandwidth = 0.1;
        data = zeros([design.nbElementsPerClass, 2]);
        for k = 1 : design.nbElementsPerClass
            w = k / design.nbElementsPerClass;
            data(k,1) = (4 * w + 1) * cos(2 * pi * w) + randn(1) * bandwidth;
            data(k,2) = (4 * w + 1) * sin(2 * pi * w) + randn(1) * bandwidth;
        end
        data = [data; -data];
        design.nbClasses = 2;
    case 'gaussian'
        data = [];
        class = [];
        for m=1:design.nbClasses
            data = [data; repmat(m*2.5, design.nbElementsPerClass, 2)+randn(design.nbElementsPerClass, 2)];
        end
end

class = [];
for k = 1 : design.nbClasses
    class = [class; k*ones(design.nbElementsPerClass, 1)];
end

store.samples = data;
store.class = class;

% figure();
scatter(data(:, 1), data(:, 2), 20, class, 'filled')
