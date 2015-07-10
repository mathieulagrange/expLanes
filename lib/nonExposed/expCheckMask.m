function ok = expCheckMask(vSpec, mask)

ok=1;

for k=1:length(mask)
    if length(mask{k}) > length(vSpec.values)
        ok=0;
        fprintf(2,['Mask definition: the mask ' num2str(k) ' is too long (should be at most of length ' num2str(length(vSpec.values))  ').\n'  ]);
    else
        for m=1:length(mask{k})
            for n=1:length(mask{k}{m})
                if mask{k}{m}(n) > length(vSpec.values{m})
                    ok=0;
                    fprintf(2,['Mask definition: the selection ' num2str(mask{k}{m}(n)) ' of factor ' vSpec.names{m}  ' within mask  '  num2str(k) ' is too large (should be at most ' num2str(length(vSpec.values{m}))  ').\n']);
                end
            end
        end
    end
end