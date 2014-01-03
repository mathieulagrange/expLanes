function values = expParameterValues(config, parameter)

index = strcmp(config.factorSpecifications.names, parameter);

if isempty(index)
    error(['Unable to find parameter: ' parameter]);
else
    values = config.factorSpecifications.values{index};
end