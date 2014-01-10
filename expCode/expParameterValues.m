function values = expParameterValues(config, parameter)

index = strcmp(config.factors.names, parameter);

if isempty(index)
    error(['Unable to find parameter: ' parameter]);
else
    values = config.factors.values{index};
end