function vSet = expVariantSet(vSpec, mask, currentTask)

vSet=[];
for k=1:length(mask)
    vSet = [vSet expVariantSetMask(vSpec, mask{k}, currentTask)];
end

% prune vSet for repetition
[newmat,index] = unique(vSet','rows','first');  % Finds indices of unique rows
vSet(:, setdiff(1:size(vSet,2),index))=[];

end

function [vSet] = expVariantSetMask(vSpec, mask, currentTask)
% only valid for unitary mask


% build complete mask
if isempty(mask)
    mask = cell(1, size(vSpec.values, 2));
    mask(:) = {0};
elseif length(mask)<length(vSpec.names)
    mask = [mask num2cell(zeros(1, length(vSpec.names)-length(mask)))];
end

% complete mask according to currentTask
for k=1:length(vSpec.step)
    cp = regexp(vSpec.step{k}, ',', 'split');
    doTask=0;
    for m=1:length(cp)
        sp = regexp(cp{m}, ':', 'split');
        if ~isempty(sp{1})
            taskStepMin = str2double(sp{1});
            taskStepMax = taskStepMin;
        else
            taskStepMin = 1;
            taskStepMax = Inf;
        end
        if length(sp)>1 && ~isempty(sp{2})
            taskStepMax = str2double(sp{2});
        elseif length(sp)==2
            taskStepMax = Inf;
        end
        
        if taskStepMin<=currentTask && currentTask<=taskStepMax
            doTask = 1;
        end
    end
    if ~doTask
        mask{k} = -1;
    end
end

mask = expSelectParameters(vSpec, {mask});

vSet=[];
for k=1:length(mask)
    vSet = [vSet buildVariantSet([], vSpec.values, mask{k})];
end

% reorder vSet
vSet = flipud(vSet);

end

function set = buildVariantSet(set, values, mask)

if length(values)>1
    pvs = buildVariantSet(set, values(2:end), mask(2:end));
    if mask{1}>0
        it = mask{1};
    elseif mask{1}==-1
        it=0;
    else
        it = 1:length(values{1});
    end
    set=[];
    for k=it
        pSet=pvs;
        for l=1:size(pSet, 2)
            pSet(size(pvs, 1)+1, l) = k;
        end
        set = [set pSet];
    end
else
    if mask{1}>0
        set= mask{1};
    elseif mask{1} == 0
        set= 1:length(values{1});
    else
        set=0;
    end
end
end



