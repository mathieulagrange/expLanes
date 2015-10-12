function config = cldaReport(config)                            
% cldaReport REPORTING of the expLanes experiment clusteringData
%    config = cldaInitReport(config)                            
%       config : expLanes configuration state                   
                                                                
% Copyright: Mathieu Lagrange                                   
% Date: 08-Oct-2015                                             
                                                                
if nargin==0, clusteringData('report', 'rcvd'); return; end        
                                                                
for k=length(expFactorValues(config, 'dataType')):-1:1
    config=expExpose(config, 't', 'mask', {k 1}, 'obs', [1 2], ...
        'fontSize', 'small', 'percent', 0, 'uncertainty', 1);
end

config=expExpose(config, 't', 'obs', 3, 'integrate', [1 2 4 5 6], 'highlight', -1, 'sort', 1, ...
    'caption', 'Execution time in seconds');

