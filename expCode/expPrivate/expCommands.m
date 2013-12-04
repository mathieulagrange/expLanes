function [commandNames shortCommandNames] = expCommands(id)

commandNames = {'Process', 'Evaluate', 'Display'};
shortCommandNames =  {'p', 'e', 'd'};

if nargin>0
    if ischar(id)
        id =  strfind(lower(cellfun(@(v) v(1), commandNames(1,:))), id);
    end
    commandNames = commandNames{id};
    shortCommandNames = shortCommandNames{id};
end