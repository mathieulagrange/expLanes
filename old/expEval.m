function result = expEval(labels, prediction, evalType, parameter)

if nargin<3 % determine evalType from data
    
end

switch evalType
    case 'clustering'
        result.nmi = nmi(labels, prediction);
        %  int array 2 int array : nmi
        
    case 'classification'
        result.nmi = nmi(labels, prediction);
        result.precision = sum(prediction == labels)/length(labels);
        
        % TODO deal with temporal series (add tolerance, etc)
    case 'detection'
        if nargin<4, parameter = 1; end % parameter is the index of the relevant class
        [result.fpr result.tpr result.threshold result.auc] = perfcurve(labels, prediction, parameter);
        
    case 'ranking'
        if nargin<4, parameter = 5; end % parameter is r, the length of the query list
        result = rankingMetrics(prediction, labels, parameter);
        
    case 'similarity'
        prediction = prediction-min(prediction(:));
        prediction = prediction/max(prediction(:));
        
        if min(size((labels))) == 1
            labels = labels(:);
            labels = 1-(repmat(labels, 1, length(labels))==repmat(labels', length(labels), 1));
            result.frobenius = frobenius(prediction, (labels-.5)*2);
        else
            result.frobenius = frobenius(prediction, labels);
        end
        
        result.fisher = fisher(prediction, labels);
        % TODO svd eigenvector agreement
end

function res = fisher(prediction, labels)

res = trace(prediction*labels)/trace(prediction*(1-labels)+eps);

function res = frobenius(prediction, labels)

res = trace(prediction.'*labels)/sqrt(trace(prediction.'*prediction)*trace(labels.'*labels));

