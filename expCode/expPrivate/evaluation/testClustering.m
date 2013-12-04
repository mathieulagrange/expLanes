
nbRuns = 50;
nbElts = 100;
nbClasses = 10;
nbClusters = 100:-10:10;

labels = ceil(rand(1, nbElts)*nbClasses);
clear d
for k=1:length(nbClusters)
    for j=1:nbRuns
        ind =  ceil(rand(1, nbElts)*nbClusters(k));
        ind = labels;
        indr = rand(1, length(ind))>j/nbRuns;
        ind(indr) = ceil(rand(1, sum(indr))*nbClusters(k));
        d(k, 1, j) = nmi(labels, ind);
        [d(k, 2, j), d(k, 3, j), d(k, 4, j), d(k, 5, j)] = randIndex(labels, ind);
    end
end

% d = squeeze(mean(d*100, 1));

plot(squeeze(d(:, :, end/2)))
xlabel('nbClusters')
set(gca, 'xTickLabel', nbClusters)
legend('nmi', 'adjusted rand', 'unadjusted rand', 'mirkin index', 'huberts index')