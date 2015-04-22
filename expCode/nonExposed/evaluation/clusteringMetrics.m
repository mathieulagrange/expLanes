function metrics = clusteringMetrics(target, prediction, noAccuracy,noRandIndex,noNmi)

if ~exist('noAccuracy', 'var')
    noAccuracy = 0;
end
if ~exist('noNmi', 'var')
    noNmi = 0;
end
if ~exist('noRandIndex', 'var')
    noRandIndex = 0;
end

target = target(:);
prediction = prediction(:);

if min(target)<1
    target = target+1+abs(min(target));
end
if min(prediction)<1
    prediction = prediction+1+abs(min(prediction));
end

if ~noNmi
    metrics.nmi= real(nmi(target, prediction));
end
if ~noRandIndex
    [metrics.adjustedRandIndex, metrics.unadjustedRandIndex, metrics.mirkinIndex, metrics.hubertsIndex] = randIndex(target, prediction);
end
if ~noAccuracy
    [metrics.accuracy, metrics.classMatching] = accuracy(target, prediction);
end

[metrics.pairwiseFmeasure, metrics.pairwisePrecision, metrics.pairwiseRecall] = pairWiseMatching(target, prediction);
[metrics.So,metrics.Su]=normCondEntropies(target,prediction);

