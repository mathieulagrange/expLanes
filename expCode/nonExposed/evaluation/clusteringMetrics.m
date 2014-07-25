function metrics = clusteringMetrics(target, prediction, noAccuracy)

if ~exist('noAccuracy', 'var')
    noAccuracy = 0;
end

metrics.nmi= nmi(target, prediction);

[metrics.adjustedRandIndex, metrics.unadjustedRandIndex, metrics.mirkinIndex, metrics.hubertsIndex] = randIndex(target, prediction);

if ~noAccuracy
    [metrics.accuracy, metrics.classMatching] = accuracy(target, prediction);
end

