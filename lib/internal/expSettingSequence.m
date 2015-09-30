function sequence = expSettingSequence(vSpec, vSet)

sequence = {};
if ~isempty(vSet)
    if size(vSet, 2)>1
        if ~isempty(vSpec.sequentialFactor)
            %         sIndex = find(strcmp(vSpec.names, vSpec.sequentialFactor));
            %         vSet(sIndex, :)=[];
            vSet(strcmp(vSpec.names, vSpec.sequentialFactor), :)=[];
            sequence = {};
            notDone=ones(1, size(vSet, 2));
            for k=1:size(vSet, 2)
                if notDone(k)
                    match = vSet==repmat(vSet(:, k), 1, size(vSet, 2));
                    if size(vSet, 1)>1
                        match = all(match);
                    end
                    notDone(match)=0;
                    sequence{end+1}=find(match);
                end
            end
        else
            sequence = num2cell(1:size(vSet, 2));
        end
    else
        sequence = {1};
    end
end
