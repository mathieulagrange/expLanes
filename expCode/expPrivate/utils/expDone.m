function done = expDone(config, extension)

if ~exist('extension', 'var')
    done = exist(expSave(config), 'file');
elseif ischar(extension)
    done = exist(expSave(config, [], extension), 'file');
elseif iscell(extension)
    done =0 ;
    for k=1:length(extension)
        done = max(done, exist(expSave(config, [], extension{k}), 'file'));
    end
end

if done, disp(['skipping ' config.currentTaskName ' ' config.currentVariant.infoString]); end