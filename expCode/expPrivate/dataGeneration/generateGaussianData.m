function [ points, labels ] = generateGaussianData( nbPoints, nbClasses, overlapFactor, sizeVariation, minX, maxX, minY, maxY )
% Generates nbPoints random points belonging to nbClasses classes
% Each class follows a gaussian pdf whose parameters are randomly chosen
% The points for each class are generated based on that pdf. 'labels' gives
% the ground truth, which is based on the generation process. 'overlapFactor'
% controls how "fuzzy" the classes are, and therefore how much they may overlap.
% An overlapFactor of zero means classes are reduced to a point. The
% default value of 1 gives reasonably readable classes. 'sizeVariation'
% controls how much the size of classes varies -- if <1, they all have the
% exact same number of elements, if >1, the sizes are uniformly distributed
% in the range 1/sizeVariation to sizeVariation.
% Note that due to the randomness of generated data, minX, maxX, etc., are
% not strictly enforced boundaries.

if (nargin < 1) nbPoints = 1000; end;
if (nargin < 2) nbClasses = ceil(nbPoints/100); end;
if (nargin < 3) overlapFactor = 1; end;
if (nargin < 4) sizeVariation = 1; end;
if (nargin < 5) minX = 0; end;
if (nargin < 6) maxX = 10; end;
if (nargin < 7) minY = 0; end;
if (nargin < 8) maxY = 10; end;

if (maxX < minX) tmp = minX; minX = maxX; maxX = tmp; end;
if (maxY < minY) tmp = minY; minY = maxY; maxY = tmp; end;

area = (maxX-minX)*(maxY-minY);
meanStdDev = overlapFactor*sqrt(area/nbClasses)/4;

% Generate class centroids
means(1,1) = minX+meanStdDev+(maxX-minX-2*meanStdDev)*rand();
means(1,2) = minY+meanStdDev+(maxY-minY-2*meanStdDev)*rand();
for i=2:nbClasses
    % Generate 10 potential class centroids, choose the one that is most
    % distant from existing centroids
    proposals = rand (10, 2);
    proposals(:,1) = minX+meanStdDev+(maxX-minX-2*meanStdDev)*proposals(:,1);
    proposals(:,2) = minY+meanStdDev+(maxY-minY-2*meanStdDev)*proposals(:,2);
    % Next line generates a distance matrix -- OK, I'll admit I copied it
    dists = squeeze(sqrt( sum( bsxfun(@minus,means, reshape(proposals.',1,2,[]) ).^2 ,2)));
    [~,ind] = max(min(dists));
    means(i,:) = proposals(ind,:);
end

stdDevs = meanStdDev/2 + rand(nbClasses,2)*meanStdDev;

% Class sizes
classSizes = 1/sizeVariation + rand(nbClasses,1)*(sizeVariation-1/sizeVariation);
classSizes = floor(classSizes*nbPoints / sum(classSizes));
classSizes(1) = classSizes(1) + nbPoints - sum(classSizes); % Difference should be a few units at most

% Label generation
labels = [];
for i=1:nbClasses
    labels = horzcat(labels, zeros(1,classSizes(i))+i);
end

% Label shuffling
p = randperm(nbPoints);
labels = labels(p);

% Random coordinates
points = randn(nbPoints, 2);

% translate and scale according to class
points = points.*stdDevs(labels,:) + means(labels,:);

end
