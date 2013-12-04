function values = expParameterValues(config, parameter)

index = strcmp(config.variantSpecifications.names, parameter);

if isempty(index)
    error(['Unable to find parameter: ' parameter]);
else
    values = config.variantSpecifications.values{index};
end