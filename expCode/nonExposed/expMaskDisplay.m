function s = expMaskDisplay(mask)

s=['{'];
for k=1:length(mask)
    s(end+1)= '{';
    for m=1:length(mask{k})
        e = mask{k}{m};
        if length(e) > 1
            s = [s '[' num2str(e) '], '];
        else
            s = [s num2str(e) ', '];
        end
    end
    if m>0, s(end-1:end)=[]; end
    s = [s '}, '];
end
    if k>0, s(end-1:end)=[]; end
s = [s '}'];