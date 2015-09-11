function [values, nbValues] = expFactorValues(config, factor)
% expFactorValues retrives the modalities of a given factor
%	values = expFactorValues(config, factor)
%	- config: expLanes configuration
%	- factor: name of the factor
%	-- values: set of modalities corresponding to this factor
%	-- nbValues: size of the set of modalities

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.



index = strcmp(config.factors.names, factor);

if isempty(index)
    error(['Unable to find factor: ' factor]);
else
    values = config.factors.values{index};
end

nbValues = length(values);