function [config, store, obs] = clde1generate(config, setting, data)
% clde1generateData GENERAT step of the expLord project clusteringDemo
%    [config, store, obs] = clde1generate(config, setting, data)
%     - config : expLord configuration state
%     - setting   : set of factors to be evaluated
%     - data   : processing data stored during the previous step
%     -- store  : processing data to be saved for the other steps
%     -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date 22-Nov-2013

% Set behavior for debug mode
if nargin==0, clusteringDemonstration('do', 1, 'plot', 1); return; else store=[]; obs=[]; end

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
        for m=1:setting.nbClasses
            data = [data; repmat(m*2.5, setting.nbElementsPerClass, 2)+randn(setting.nbElementsPerClass, 2)];
        end
end

class = [];
for k = 1 : setting.nbClasses
    class = [class; k*ones(setting.nbElementsPerClass, 1)];
end

store.elements = data;
store.class = class;

if isfield(config, 'plot') 
    clf
    scatter(data(:, 1), data(:, 2), 20, class, 'filled')
    axis off
    axis tight
    config = expExpose(config, '', 'save', ['scatter' num2str(setting.infoId(1))]);
end
