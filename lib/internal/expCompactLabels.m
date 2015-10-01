function p = expCompactLabels(p)

fields = fieldnames(p);

for k=1:length(fields)
    pf = p.(fields{k});
    if iscell(pf) && length(pf)>1 && iscellstr(pf)
        mLength = min(cellfun('length', pf));
        mLength = mLength(1);
        m = 1;
       while m<mLength+1 && length(unique(cellfun(@(x) x(1:m), pf, 'UniformOutput', false)))==1
           m=m+1;
       end
       p.(fields{k}) = cellfun(@(x) x(m:end), pf, 'UniformOutput', false);
    end
end

