function expSample(ori, list, dest)

if nargin<1, ori=2; end
if nargin<2, list=5; end %{'tata/d1', 'tata/d2'}; end % 0; end
if nargin<3, dest=0; end

oriConfig = expConfig('host', ori);
destConfig = expConfig('host', dest);

% TODO path could be parameter of variants for selecting database

% build path
if isnumeric(list)
    nbItems = list;
    dirLs = ['ssh ' oriConfig.machineName ' ls ' oriConfig.inputPath];
    [a list] = system(dirLs);
    list = regexp(list, '\n', 'split');
    list = list(1:end-1);
    if nbItems<length(list)
        list = list(1:nbItems);
    end
end

% send data
for k=1:length(list)
    p = fileparts(list{k});
    p = [destConfig.inputPath p];
    dirCheck = ['ssh ' destConfig.machineName ' ls ' p];
    [existDir ~]=system(dirCheck);
    if existDir
        system(['ssh ' destConfig.machineName ' mkdir -p ' p]);
    end
    toSend = ['scp -q -r ' oriConfig.machineName ':' oriConfig.inputPath list{k} ' '  p];
    system(toSend);
end
