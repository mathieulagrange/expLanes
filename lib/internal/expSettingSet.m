function vSet = expSettingSet(vSpec, mask, currentStep)

vSet=[];
for k=1:length(mask)
    vSet = [vSet expSettingSetMask(vSpec, mask{k}, currentStep)];
end

for k=1:length(vSpec.deselectFactors)
    c = regexp(vSpec.deselectFactors{k}, '/', 'split');
    p = eval(c{1});
    s = abs(eval(c{2}));
    f = eval(c{3});
    vSet(setdiff(1:size(vSet, 1), [f p]), union(find(vSet(p, :)==0), find(vSet(p, :)==s))) =0;
end

% prune vSet for repetition
[newmat, index] = unique(vSet','rows','first');  % Finds indices of unique rows
vSet(:, setdiff(1:size(vSet,2),index))=[];
% prune for emptiness
vSet(:, sum(vSet)==0)=[];
vSet = squeeze(vSet);
end

function [vSet] = expSettingSetMask(vSpec, mask, currentStep)
% only valid for unitary mask


% build complete mask
if isempty(mask)
    mask = cell(1, size(vSpec.values, 2));
    mask(:) = {0};
elseif length(mask)<length(vSpec.names)
    mask = [mask num2cell(zeros(1, length(vSpec.names)-length(mask)))];
end


mask = expSelectFactors(vSpec, {mask});

mask = expSettingStepMask(vSpec, mask, currentStep);


vSet=[];
for k=1:length(mask)
    vSet = [vSet buildSettingSet([], vSpec.values, mask{k})];
end

% reorder vSet
vSet = flipud(vSet);

end

function set = buildSettingSet(set, values, mask)

if length(values)>1
    pvs = buildSettingSet(set, values(2:end), mask(2:end));
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



