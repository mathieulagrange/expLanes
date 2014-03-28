function values = expFactorValues(config, factor)

index = strcmp(config.factors.names, factor);

if isempty(index)
    error(['Unable to find factor: ' factor]);
else
    values = config.factors.values{index};
end