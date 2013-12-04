function config = expConfigMerge(cfg)

f = fieldnames(cfg(1));
config = cfg(1);

for k=1:length(f)
    if iscell(cfg(1).(f{k}))
        for l=2:length(cfg)
            for m =1:length(cfg(l).(f{k}))
                config.(f{k})(end+1) = cfg(l).(f{k})(m);
            end
        end
    end
end