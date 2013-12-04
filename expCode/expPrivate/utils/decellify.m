function data = decellify(data)
try
    data = cellfun(@decellify,data,'un',0);
    if any(cellfun(@iscell,data))
        data = [data{:}];
    end
catch
    % a non-cell node, so simply return node data as-is
end