function expShowPdf(config, fileName)

cmd = [];
if ~isempty(config.pdfViewer)
    cmd=[config.pdfViewer ' ', fileName, ' &'];
else
    if ismac
        cmd=['open -a Preview ', fileName, ' &'];
    elseif isunix
        cmd=['evince ', fileName, ' &'];
    end
end
if isempty(cmd)
    open(fileName);
else
    system(cmd);
end