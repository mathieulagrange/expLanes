function config = geshReport(config)                           
% geshReport REPORTING of the expCode experiment geometricShape
%    config = geshInitReport(config)                           
%       config : expCode configuration state                   
                                                               
% Copyright: Mathieu Lagrange                                  
% Date: 16-Jun-2015                                            
                                                               
if nargin==0, geometricShape('report', 'r'); return; end       
                                                               
config = expExpose(config, 't');                               
